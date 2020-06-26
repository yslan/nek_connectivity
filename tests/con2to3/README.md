- usage: `./run.sh`
  - This will call `gen_ref_msh.sh` to use gencon generating referenced con/co2 files   
  - Then it will call the con2to3 to generate new con/co2.    
  - To compare two con files under same mesh (the ordering or elements must be the same), there is a `compare.py` called in `run.sh`. This will read two con/co2 and con should be the same up to a permutation.

 **Note:** Please modify the path in `gen_ref_msh.sh` and `run.sh` if the script complains.
