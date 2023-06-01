## Generate connectivity for simple box mesh

This tiny script generates the Nek5000/NekRS's co2/con file for a single but potentially large box mesh.

### Usage 

- Main driver: `driver1.m`
- Specify the number of elements in x, y and z direction into `nelx`, `nely`, and `nelz`
- The code will generate the co2 file under the `output/` directory
 

### Notes
- Octave supported. `octave ./driver_octave.m <nelx> <nely> <nelz>`
- Tested with E~6000 by cross-comparing with the Nek5000's tool, gencon
- There are two implementation in `gencon_box.m`. You can have trade off between large memory (but 5x fast for E~1M) or triple loops.
- Periodic BC is not supported for now (but it's super easy, like, three lines changes. homework?)
