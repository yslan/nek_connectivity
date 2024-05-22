import sys
import struct
import numpy as np

nargv=len(sys.argv)-1
if nargv!=4 or sys.argv[1]=='-h':
  print('Help page')
  print('Usage:')
  print('  - python3 compare_con.py -h: show this page')
  print('  - python3 compare_con.py <f1> <f2> <f1_ifco2> <f2_ifco2>')
  print('    python3 compare_con.py c1 c2 0 1 (for c1.con vs c2.co2)\n')
  print('Output type:')
  print('  - NA:   comparison is not valid')
  print('  - NEQ:  con files are different')
  print('  - PASS: con files are same (up to a permutation)')
  quit()

fname1 = sys.argv[1]
fname2 = sys.argv[2] 

f1tp = int(sys.argv[3])
f2tp = int(sys.argv[4])

if(f1tp!=f2tp):
  print('NA: Mismatched type is not tested',f1tp,f2tp)
  quit()

def read_co2(fname):
  try:
    fext='.co2'
    with open(fname+fext,'rb') as f:
      header = f.read(132).split()
      if (not header[0]==b'#v001'):
        print('ABORT: only support #v001, ',header[0].decode('utf-8'))
      nelt=int(header[1]); nelv=int(header[2]); nv=int(header[3]); nel=nelt
      print('Open '+fname+fext,', hdr:',nelt,nelv,nv)

      etagb = f.read(4)
      etagL = struct.unpack('<f', etagb)[0]; etagL = int(etagL*1e5)/1e5
      etagB = struct.unpack('>f', etagb)[0]; etagB = int(etagB*1e5)/1e5
      if (etagL == 6.54321):
#        print('Reading little-endian file\n')
        emode = '<'
      elif (etagB == 6.54321):
#        print('Reading big-endian file\n')
        emode = '>'
      else:
        print('invalid endian mode:', etagL, etagB)

      con=np.zeros((nv,nel),dtype=int)
      byte = f.read(4*(nv+1)); i=0
      while byte != b"":
        iwrk = np.array(list(struct.unpack(emode+(nv+1)*'i', byte)))
        con[:,i] = iwrk[1:]
        byte = f.read(4*(nv+1)); i+=1
  except:
    print('NA: file not read properly (read_co2), ',fname+fext)
    quit()
  return con.T,nel,nv

def read_con(fname):
  try:
    fext='.con'
    with open(fname+fext,'r') as f:
      header = f.readline().split()
      if (not header[0]=='#v001'):
        print('ABORT: only support #v001, ',header[0])
      nelt=int(header[1]); nelv=int(header[2]); nv=int(header[3]); nel=nelt
      print('Open '+fname+fext,', hdr:',nelt,nelv,nv)

      con=np.zeros((nv,nel),dtype=int)
      byte = f.readline(); i=0
      while byte != "":
        iwrk = np.array([int(s) for s in byte.split() if s.isdigit()])
        con[:,i] = iwrk[1:]
        byte = f.readline(); i+=1
  except:
    print('NA: file not read properly (read_con), ',fname+fext)
    quit()
  return con.T,nel,nv

def chk_vtx(arr):
  uarr=np.unique(arr[:]); n=len(uarr); ierr=0
  uarr=uarr.reshape((1,n));uref=np.array(range(n))
  if np.sum(abs(uarr-uref))>0:
    ierr=1
  if n!=np.max(arr[:]+1)>0:
    ierr=2
  return n,ierr 


if (f1tp==1):
  con1,nel1,nv1=read_co2(fname1)
else:
  con1,nel1,nv1=read_con(fname1)
if (f2tp==1):
  con2,nel2,nv2=read_co2(fname2)
else:
  con2,nel2,nv2=read_con(fname2)

if (nv1!=nv2):
  print('NEQ: nv',nv1,nv2)
  quit()
if (nel1!=nel2):
  print('NEQ: nel',nel1,nel2)
  quit()

rcon1=con1.reshape((nel1*nv1,1))-1
rcon2=con2.reshape((nel2*nv2,1))-1
nvtx1,ierr1 = chk_vtx(rcon1)
nvtx2,ierr2 = chk_vtx(rcon2)

if(ierr1>0):
  print('NA: con is invalid: ',fname1,ierr1) 
  quit()
if(ierr2>0):
  print('NA: con is invalid: ',fname2,ierr2) 
  quit()
if (nvtx1!=nvtx2):
  print('NEQ: nvtx',nvtx1,nvtx2)
  quit()


ind_1to2=np.zeros((nvtx1,1),dtype=int)
for i in range(nel1*nv1):
  ind_1to2[rcon1[i]]=rcon2[i]
ind_1to2=ind_1to2.T

n,ierr=chk_vtx(ind_1to2)
#print(ind_1to2)

if(ierr>0):
  print('NEQ: con are different after perm. ',fname1,fname2) 
  quit()

if (np.sum(abs(ind_1to2-np.array(range(nvtx1))))>0):
  print('PASS after perm')
else:
  print('PASS without perm')
