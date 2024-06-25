#!/bin/bash
set -e

NEK5000_HOME="$HOME/Nek5000_repo_main"
py_chkcon="./compare_con.py"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'


# Clean
if [[ "$1" == "clean" ]]; then
  NEK5000_HOME=$NEK5000_HOME ./gen_ref_msh.sh clean
  exit 0
fi

# Generate ref mesh (by gencon)
echo -e 'Generate ref co2 files (./gen_ref_msh.sh)...'
set +e; rm log_ref 2> /dev/null; set -e
NEK5000_HOME=$NEK5000_HOME ./gen_ref_msh.sh > log_ref
if [ $? -eq 1 ]; then
   echo "./gen_ref_msh.sh error, see log_ref"
   cat log_ref
   exit 1
fi

set -e
# comparison
itest=0; ntest=4
function compare {
  set +e
  rm log_tmp 2> /dev/null
  itest=$(($itest+1))
  python3 $py_chkcon $1 $2 $3 $4 > log_tmp
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
  fi; set -x;
  rm log_tmp 2> /dev/null; set -e
}

#compare m2e1 m3e1 1 1
compare m2e2 m3e2 1 1
compare m1e2 m3e2 1 1
compare m2e3 m3e3 1 1
compare m1e3 m3e3 1 1
