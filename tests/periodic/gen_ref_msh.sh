#!/bin/bash
set -e

: ${NEK5000_HOME:="$HOME/Nek5000"}

genbox=$NEK5000_HOME"/bin/genbox"
gencon=$NEK5000_HOME"/bin/gencon"
n2to3=$NEK5000_HOME"/bin/n2to3"
n2to3co2=$NEK5000_HOME"/bin/n2to3co2"
py_chkcon="./compare_con.py"

function chk_tool() {
  flist=($1)
  for f in "${flist[@]}"; do
  if [ ! -f $f ]; then
    echo "FILE: $f does not exist!"
    exit 1
  fi
  done
}

chk_tool "$genbox $gencon $n2to3 $n2to3co2 $py_chkcon"


function do_genbox2d() {
  in=$1
  out=$2
  
  cp $in tmp.box

$genbox << EOF1
tmp.box
EOF1

  mv box.rea $out.rea

$gencon << EOF2
$out

EOF2
}

function do_genbox3d() {
  in=$1
  out=$2

  cp $in tmp.box
  nelx=`grep "nelx,nely,nelz for Box" tmp.box | tr "-" " " |awk '{print $1}'`
  nely=`grep "nelx,nely,nelz for Box" tmp.box | tr "-" " " |awk '{print $2}'`
  nelz=$3

  sed -i '/nelx,nely,nelz for Box/c\-'$nelx'  -'$nely'  -'$nelz'      nelx,nely,nelz for Box' tmp.box

$genbox << EOF1
tmp.box
EOF1

  mv box.re2 $out.re2

$gencon << EOF2
$out

EOF2
}

function do_n2to3() {
  in=$1
  out=$2
  nelz=$3

$n2to3 << EOF1
$in
$out
1   # 1=binary
$nelz   # nlv
0   # zmin
1   # zmax
1   # unif 
no  # CEM
P   # Z(5)
EOF1

$gencon << EOF2
$out

EOF2
}

function do_n2to3co2(){
  in=$1
  out=$2
  nelz=$3
$n2to3co2 <<EOF
$in
$out
1  # 1=binary
$nelz  # nlevel
1  # periodic
EOF
}


set +e
rm tmp.box 2> /dev/null
rm *.co2 2> /dev/null
rm *.con 2> /dev/null
rm m*e*.re* 2> /dev/null
rm base2d.rea 2> /dev/null
set -e
if [ "$1" == "clean" ]; then # clean only
  exit 0
fi

# generate co2
# m1: 3dbox => gencon
do_genbox3d "input3d.box" "m1e1" 1
do_genbox3d "input3d.box" "m1e2" 2
do_genbox3d "input3d.box" "m1e3" 3
#
## m2: 2dbox => n2to3 => gencon
do_genbox2d "input2d.box" "base2d"
do_n2to3 "base2d" "m2e1" 1 
do_n2to3 "base2d" "m2e2" 2 
do_n2to3 "base2d" "m2e3" 3

# m3: 2dbox/2dcon => n2to3co2
do_n2to3co2 "base2d" "m3e1" 1
do_n2to3co2 "base2d" "m3e2" 2
do_n2to3co2 "base2d" "m3e3" 3


