#!/bin/bash
#set -o xtrace
set -x

src="../../bin/"
maptoco2=$src"maptoco2"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'


# Check path
if [ ! -f "$maptoco2" ];then
  echo $maptoco2" file not exists!"
  exit 1
fi

# Clean output
rm *.co2 2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  ./gen_ref_msh.sh clean
  exit 0
fi


# Generate ref mesh (by gencon)
echo -e 'Generate ref con files (via gencon)...'
rm log_ref 2> /dev/null
./gen_ref_msh.sh > log_ref

itest=0; ntest=3
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
# Test 1: map to co2, IFCHT=F, 3d
case="case1"
$maptoco2 << EOF
$case
0   # IFCHT
EOF
ref="ref1"
compare $case $ref 1 1

# Test 2: ma2 to co2, IFCHT=F, 3d
case="case2"
$maptoco2 << EOF
$case
0   # IFCHT
EOF
ref="ref2"
compare $case $ref 1 1

# Test 3: ma2 to co2, IFCHT=T, 2d
case="case3"
$maptoco2 << EOF
$case
1   # IFCHT
32  # nelgv
EOF
ref="ref3"
compare $case $ref 1 1
