#!/usr/bin/env python

import os
import sys
import numpy as np
import struct

try:
    import gmsh
except ImportError:
    print('ERR: Cannot import gmsh. Please install gmsh')
    exit(1)

verbose = int(os.getenv('VERBOSE','1').strip() or 1) # 1=default, 2=more checks

###################### user inputs ###############################
msg1='Input the gmsh filename [case.msh]:\n'
msg2='Input the output case name [case]:\n'
msg3='Do you want to patch connectivity? [0=no/1=yes]:\n'
msg4='Enter the tol for patching (default=1e-2):\n'

fname_in = input(msg1)
fname_out = input(msg2)
iftol = int(input(msg3).strip() or 0)   # default = 0
if iftol:
    gencon_tol = float(input(msg4).strip() or 1e-2) # defailt = 1e-2

###################### util func ###############################
def scan_gmsh_entities(elementType):
  entities = gmsh.model.getEntities()
  numMatchedEntities = 0
  for e in entities:
      # Dimension and tag of the entity:
      eDim = e[0]
      eTag = e[1]
  
      if verbose>1:
          # * Type and name of the entity:
          eType = gmsh.model.getType(eDim, eTag)
          eName = gmsh.model.getEntityName(eDim, eTag)
          if len(eName): eName += ' '
          print('Entity ' + eName + str(e) + ' of type ' + eType)
  
      eElemTypes = gmsh.model.mesh.getElementTypes(eDim, eTag)
  
      # * List all types of elements making up the mesh of the entity:
      for t in eElemTypes:
          if t == elementType:
              numMatchedEntities += 1
          if verbose>1:
              Ename, Edim, Eorder, _, _, _ = gmsh.model.mesh.getElementProperties(t)
              print(' - Element type: ' + Ename + ', order ' + str(Eorder))
  elementTypeName,_,_,_,_,_ = gmsh.model.mesh.getElementProperties(elementType)
  print('Found %d entities matching the type %d (%s)'\
        %(numMatchedEntities,elementType,elementTypeName))

def uniquetol(pts, tol):
    npts0 = pts.shape[0]
    assert dim==pts.shape[1], 'invalid size'

    tol = 0.5 * tol / dim;
    toli = 1.0/tol
    pts_out = np.int64(np.round(toli * pts))
    _, uid = np.unique(pts_out, axis=0, return_inverse=True)

    npts1 = np.max(uid)+1
    print('\nPatching connnectivity vi uniquetol')
    print('Number of vertices: bfr/aft/diff = %d %d %d'%(npts0,npts1,npts1-npts0))
    return pts_out, uid

def chk_vtx(arr):
  uarr=np.unique(arr[:]); n=len(uarr); ierr=0
  uarr=uarr.reshape((1,n));uref=np.array(range(n))
  if np.sum(abs(uarr-uref))>0:
    ierr=1
  if n!=np.max(arr[:]+1)>0:
    ierr=ierr+10
  return n,ierr 

def write_co2(fname, con):
    fext='.co2' 
    nv = 2**dim
    nE = con.shape[0]
    nVtx = np.max(con)

    data = np.zeros((nE, nv+1), dtype=np.int32)
    data[:,0] = np.arange(1,nE+1)
    data[:,1:] = connectivity
    data = data.reshape((-1,))

    print('\nWriting %s ... (E,V,Nvtx)=(%d,%d,%d)'%(fname+fext,nE,nv,nVtx))
    with open(fname+fext,'wb') as f:
      s = '#v001%12d%12d%12d'%(nE,nE,nv)
      s = s.ljust(132)
      f.write(s.encode())

      etag=np.float32(6.54321); 
      if sys.byteorder == 'little':
        emode = '<'
      else:
        emode = '>'
      f.write(struct.pack(emode+'1f', etag)) 
      f.write(struct.pack(emode+'%si'%(nE*(nv+1)),*data.T))

    return 0

###################### Main Code ###############################
print('\nLoad mesh (%s)'%(fname_in))
gmsh.initialize()
gmsh.option.setNumber('General.Verbosity', 5)
gmsh.open(fname_in)

if iftol:
    print('\nPatching connectivity via gmsh')
    gmsh.model.mesh.removeDuplicateNodes()
    gmsh.model.geo.removeAllDuplicates()

dim = gmsh.model.getDimension()
order = 2
if dim == 3:
    elementType = gmsh.model.mesh.getElementType('Hexahedron', order)
    primaryNodeId = np.array([0,1,3,2,4,5,7,6],dtype=np.int8)
elif dim == 2:
    elementType = gmsh.model.mesh.getElementType('Quadrangle', order)
    primaryNodeId = np.array([0,1,3,2],dtype=np.int8)
else:
    print('Invalid dim %d'%dim)
    exit(1)

# check 2nd order mesh
_, _, _, numv, _, _ = gmsh.model.mesh.getElementProperties(elementType)
assert numv==(3**dim), 'ERR: Wrong elementType, only supports order=2 gmsh'

# Scan entities (just for checking)
if verbose>0:
    scan_gmsh_entities(elementType)

# extract Quad/Hex elements
elementTags, elemNodeTags = gmsh.model.mesh.getElementsByType(elementType)
Nelements = len(elementTags)
elemNodeTags = elemNodeTags-1 # 1-base to 0-base

elemNodeTags = elemNodeTags.reshape((Nelements,numv))
elemPrimaryNodeTags = elemNodeTags[:,primaryNodeId]

_, uniqElemPrimaryNodeTags = np.unique(elemPrimaryNodeTags, return_inverse=True)

# Patch connectivity via tol (not recommanded in general)
if iftol:
    tag, nodeCoord, _ = gmsh.model.mesh.getNodes(-1, -1, includeBoundary=True)
    nodeCoord = nodeCoord.reshape((tag.shape[0], dim))

    elemPrimaryNodeTags = elemPrimaryNodeTags.reshape((-1,))
    elemVtxCoord = nodeCoord[elemPrimaryNodeTags,:] # already uniq via gmsh?

    _, NodeMap = uniquetol(elemVtxCoord, gencon_tol) # unify based on tol
    uniqElemPrimaryNodeTags = NodeMap

connectivity = uniqElemPrimaryNodeTags.reshape((Nelements, 2**dim)) + 1

# check connectivity
nvtx, ierr = chk_vtx(connectivity-1)
assert ierr==0, 'ERR: con is invalid %d'%ierr

# dump co2
write_co2(fname_out, connectivity)
print('Complete successfully!')

#gmsh.fltk.run()
