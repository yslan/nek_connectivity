## Generate connectivity for simple box mesh

This tiny script generates the Nek5000/NekRS's co2/con file for a single but potentially large box mesh.

We have 3 implementations which is a trade-off between large memory (but 5x faster for E~1M) or triple loops.
- iversion=1: Use triple loops, it is slow when E is about 1M.
- iversion=2: (default) Use array instead of loop. This requires large memory though.
- iversion=3: (recommanded when E~300^3) The hybrid one between version 1 and 2. Loop through z to ease the memory usage. 
- iversion=-1: The debug mode, run all version and compare the difference.

### Usage 

- MATLAB
  - Main driver: `driver1.m`
  - Specify the number of elements in x, y and z direction into `nelx`, `nely`, and `nelz`
  - The code will generate the co2 file under the `output/` directory
 
- Octave:   
  `octave ./driver_octave.m <nelx> <nely> <nelz>`        
  `octave ./driver_octave.m <nelx> <nely> <nelz> <iversion>`      

### Notes
- Octave supported
- Tested with E~6000 by cross-comparing with the Nek5000's tool, gencon
- Tested with E=508^3 and E=640^3, by NekRS, it runs ok
- The scripts works with E=640^3 on a server, (5.49e+01 sec)
- The scripts works with E=806^3 on a server, (2.73e+02 sec, version3 mem=35G, dump\_co2=109GB)
- Periodic BC is not supported for now (but it's super easy, like, three lines changes. homework?)

- TODO: current `dump_nek_con.m` will expand the array with `map=[(1:nH)',Hexes];` which doubles the memory usage.
- TODO: if we need 4x larger case (E~2Bn), then we need to do a smaller chunk at a time, or in parallel.
