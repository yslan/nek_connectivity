
: ${Nek5000_src:="~/Nek5000"}

gencon="$Nek5000_src/bin/gencon"
genmap="$Nek5000_src/bin/genmap"

src="../../bin/"
contoco2=$src"contoco2"

# Check path
if [ ! -f "$genmap" ];then
  echo $genmap" file not exists!"
  exit 1
fi
if [ ! -f "$gencon" ];then
  echo $gencon" file not exists!"
  exit 1
fi
if [ ! -f "$contoco2" ];then
  echo $contoco2" file not exists!"
  exit 1
fi

# Clean output
rm *map  2> /dev/null
rm *ma2  2> /dev/null
rm *con  2> /dev/null
rm *co2  2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  exit 0
fi

case="eddy3d_per_3lvb"
$genmap << EOF
$case
0.01
EOF
mv $case".ma2" case1.ma2
$gencon << EOF
$case
0.01
EOF
mv $case".co2" ref1.co2

case="eddy3d_per_3lv"
$genmap << EOF
$case
0.01
EOF
mv $case".map" case2.map
$gencon << EOF
$case
0.01
EOF
mv $case".con" ref2.con
$contoco2 << EOF
ref2
EOF

case="conj_htb"
$genmap << EOF
$case
0.01
EOF
mv $case".ma2" case3.ma2
$gencon << EOF
$case
0.01
EOF
mv $case".co2" ref3.co2

