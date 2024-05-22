genbox="/home/sean/Nek5000_repo_main/bin/genbox"
gencon="/home/sean/Nek5000_repo_main/bin/gencon"

src="../../gencon_box/"
srco=$src"output/"
srcn=`pwd`
gencon_box="driver_octave.m"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'

ex=40
ey=30
ez=10
if [ $# -eq 3 ]; then
  ex=$1
  ey=$2
  ez=$3
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "usage: $0"
  echo "usage: $0 -h"
  echo "usage: $0 --help"
  echo "usage: $0 <nelx> <nely> <nelz>"
  exit 0
fi


# Check path
if [ ! -f "$genbox" ];then
  echo $genbox" file not exists!"
  exit 1
fi
if [ ! -f "$gencon" ];then
  echo $gencon" file not exists!"
  exit 1
fi
if [ ! -f "$src$gencon_box" ];then
  echo $gencon_box" file not exists!"
  exit 1
fi

str_octave=`which octave`
if [ -z "$str_octave" ]; then
  echo "Cannot find octave!"
  exit 1
fi

# Clean output
rm *.re2  2> /dev/null
rm *.con  2> /dev/null
rm *.co2  2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  exit 0
fi


cref="ref"
bref=$cref".box"
function gen_ref() {
cp dummy.box $bref
sed -i '/nelx,nely,nelz/c\ -'$ex' -'$ey' -'$ez'                   nelx,nely,nelz' $bref
$genbox << EOF 
$bref
EOF
mv box.re2 $cref".re2"

$gencon << EOF 
$cref

EOF
}

cnew="new"
function gen_new() {
cd $src
octave $gencon_box $ex $ey $ez
cd $srcn
mv $srco"nelx"$ex"_nely"$ey"_nelz"$ez".co2" $cnew".co2"
}

gen_ref 
gen_new

rm log_tmp 2> /dev/null
python3 compare_con.py $cref $cnew 1 1 > log_tmp

itest=1
ntest=1
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


