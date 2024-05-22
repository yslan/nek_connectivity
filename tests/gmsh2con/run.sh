#!/bin/bash
#set -o xtrace
set -x

Nek5000_src="/home/sean/Nek5000_repo_main"

src="../../bin"
gmsh2con=$src"/gmsh2con"
gmsh2nek=$Nek5000_src"/bin/gmsh2nek"
gencon=$Nek5000_src"/bin/gencon"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'

# Check path
if [ ! -f "$gmsh2con" ];then
  echo $gmsh2con" file not exists!"
  exit 1
fi
if [ ! -f "$gmsh2nek" ];then
  echo $gmsh2nek" file not exists!"
  exit 1
fi
if [ ! -f "$gencon" ];then
  echo $gencon" file not exists!"
  exit 1
fi

# generate ref
$gmsh2nek << EOF
3
pipe
0
0
ref
EOF

$gencon << EOF
ref

EOF

# test
$gmsh2con << EOF
pipe.msh
new
0
EOF
if [ $? -eq 1 ]; then
   echo "gmsh2con produce error"
   exit 1
fi

# test
itest=1; ntest=1
function compare {
  rm log_tmp 2> /dev/null
  python3 compare_con.py $1 $2 1 1 > log_tmp
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
compare ref new
