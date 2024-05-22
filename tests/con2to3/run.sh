#!/bin/bash
#set -o xtrace
set -x
Nek5000_src="/home/sean/Nek5000_repo_main"

src="../../bin/"
con2to3=$src"con2to3"

base="eddy2d"
bbase="eddy2db"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'


# Check path
if [ ! -f "$con2to3" ];then
  echo $con2to3" file not exists!"
  exit 1
fi

# Clean output
rm *23*co* 2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  ./gen_ref_msh.sh clean
  exit 0
fi


# Generate ref mesh (by gencon)
echo -e 'Generate ref con files (via gencon)...'
rm log_ref 2> /dev/null
Nek5000_src=$Nek5000_src ./gen_ref_msh.sh > log_ref
if [ $? -eq 1 ]; then
   echo "./gen_ref_msh.sh error, see log_ref"
   cat log_ref
   exit 1
fi

itest=0; ntest=8
# util func: Compare con files via python3 (numpy)
function compare {
  rm log_tmp 2> /dev/null
  itest=$(($itest+1))
  python3 compare_con.py $1 $2 $3 $4 > log_tmp
  set +x; echo -e '\n'; cat log_tmp
  err1=`grep NA log_tmp`
  err2=`grep NEQ log_tmp`
  ok=`grep PASS log_tmp`
  tt=$1"  vs "$2
  if [ ! -z "$err1" ]; then
    echo -e "\nTest: $tt ${RED}FAILED (NA) ($itest/$ntest)${NC}\n\n"
    exit 1
  elif [ ! -z "$err2" ]; then
    echo -e "\nTest: $tt ${RED}FAILED (NEQ) ($itest/$ntest)${NC}\n\n"
    exit 1
  elif [ ! -z "$ok" ]; then
    echo -e "\nTest: $tt ${GREEN}PASSED ($itest/$ntest) ${NC}\n\n"
  fi; set -x
}


echo 'Start tests'
# Test 1: vO
case="eddy23_vO_3lv"
$con2to3 << EOF
$base
$case
0   # ascii
3   # nlevel
0   # periodic
EOF
ref="eddy3d_vO_3lv"
compare $case $ref 0 0

case="eddy23_vO_3lvb"
$con2to3 << EOF
$base
$case
1   # ascii
3   # nlevel
0   # periodic
EOF
ref="eddy3d_vO_3lvb"
compare $case $ref 1 1

case="eddyb23_vO_3lv"
$con2to3 << EOF
$bbase
$case
0   # ascii
3   # nlevel
0   # periodic
EOF
ref="eddy3d_vO_3lv"
compare $case $ref 0 0

case="eddyb23_vO_3lvb"
$con2to3 << EOF
$bbase
$case
1   # ascii
3   # nlevel
0   # periodic
EOF
ref="eddy3d_vO_3lvb"
compare $case $ref 1 1

# Test 2: per
case="eddy23_per_3lv"
$con2to3 << EOF
$base
$case
0   # ascii
3   # nlevel
1   # periodic
EOF
ref="eddy3d_per_3lv"
compare $case $ref 0 0

case="eddy23_per_3lvb"
$con2to3 << EOF
$base
$case
1   # ascii
3   # nlevel
1   # periodic
EOF
ref="eddy3d_per_3lvb"
compare $case $ref 1 1

case="eddyb23_per_3lv"
$con2to3 << EOF
$bbase
$case
0   # ascii
3   # nlevel
1   # periodic
EOF
ref="eddy3d_per_3lv"
compare $case $ref 0 0

case="eddyb23_per_3lvb"
$con2to3 << EOF
$bbase
$case
1   # ascii
3   # nlevel
1   # periodic
EOF
ref="eddy3d_per_3lvb"
compare $case $ref 1 1

