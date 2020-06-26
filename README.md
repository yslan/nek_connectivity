## My Extra Nektools for con/co2

- ./maketools co2tocon/
  - co2tocon: binary co2 to ascii con  
    Tested with E120M case  
  - contoco2: ascii con to binary co2  
    Tested with E120M case  
  - maptoco2: map/ma2 to co2, including IFCHT=T   
    Tested with a E6M conjugate heat transfer case

- ./maketools con2to3/
  - con2to3: follows n2to3 to extrude 2d con/co2 to 3d con/co2   
    Tested with a E175M mesh  

- (WIP) ./maketools genmap/
  - (WIP) contomap: genmap by reading con/co2

- tests/
  - co2tocon: do `./run.sh` (check path inside)  
  - con2to3: do `./run.sh` (need python3)  
    check path inside `run.sh` and `gen_ref_msh.sh`
  - maptoco2: do `./run.sh` (need python3)
    check path inside `run.sh` and `gen_ref_msh.sh`


