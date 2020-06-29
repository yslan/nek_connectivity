- con2to3

  - read co2 
  - follow the ordering in n2to3, create cooresponding co2 in 3D (periodic)
  - dump co2

  - verification:
    - comparison: genco2 <3d mesh> should besame as n2to3\_co2 <2d mesh> up to permutation (re-ordering)
    - how?: need to make a unique re-ordering algo, so we can compare.


- note: test
  - options:
    - input format: in\_con, in\_co2  
    - output format: out\_con, out\_co2  
    - periodic: PER, v-O

  - nelt=nelv

    - in\_con, v-O, out\_con
    - in\_con, v-O, out\_co2
    - in\_con, PER, out\_con
    - in\_con, PER, out\_co2
    - in\_co2, v-O, out\_con
    - in\_co2, v-O, out\_co2
    - in\_co2, PER, out\_con
    - in\_co2, PER, out\_co2
