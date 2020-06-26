n2to3="/home/sean/Nek5000_v19/bin/n2to3"
gencon="/home/sean/Nek5000_v19/bin/gencon"

base="eddy2d"

# Check path
if [ ! -f "$n2to3" ];then
  echo $n2to3" file not exists!"
  exit 1
fi
if [ ! -f "$gencon" ];then
  echo $gencon" file not exists!"
  exit 1
fi
if [ ! -f "$base.rea" ];then
  echo $base".rea file not exists!"
  exit 1
fi

# Clean output
rm *3d*re*  2> /dev/null
rm *3d*co*  2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  exit 0
fi

case="eddy3d_vO_3lv"
$n2to3 << EOF
$base
$case
0   # ascii
3   # nlv
0   # zmin
3   # zmax
1   # unif
no  # CEM
v   # Z(5)
O   # Z(6)
EOF
$gencon << EOF
$case
0.01
EOF

case="eddy3d_vO_3lvb"
$n2to3 << EOF
$base
$case
1   # ascii
3   # nlv
0   # zmin
3   # zmax
1   # unif
no  # CEM
v   # Z(5)
O   # Z(6)
EOF
$gencon << EOF
$case
0.01
EOF

case=eddy3d_per_3lv
$n2to3 << EOF
$base
$case
0   # ascii
3   # nlv
0   # zmin
3   # zmax
1   # unif
no  # CEM
P   # Z(5)
EOF
$gencon << EOF
$case
0.01
EOF

case=eddy3d_per_3lvb
$n2to3 << EOF
$base
$case
1   # ascii
3   # nlv
0   # zmin
3   # zmax
1   # unif
no  # CEM
P   # Z(5)
EOF
$gencon << EOF
$case
0.01
EOF
