genbox="/home/sean/Nek5000_repo/bin/genbox"
gencon="/home/sean/Nek5000_repo/bin/gencon"

src="../../gencon_box/"
srco=$src"output/"
srcn=`pwd`
gencon_box="driver_octave.m"

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


cref="ref_per"
bref=$cref".box"
function gen_ref() {
cp dummy_per.box $bref
sed -i '/nelx,nely,nelz/c\ -'$ex' -'$ey' -'$ez'                   nelx,nely,nelz' $bref
$genbox << EOF 
$bref
EOF
mv box.re2 $cref".re2"

$gencon << EOF 
$cref

EOF
}

iperx=1
ipery=0
iperz=1

cnew="new_per"
function gen_new() {
cd $src
octave $gencon_box $ex $ey $ez $iperx $ipery $iperz 3
cd $srcn
mv $srco"nelx"$ex"_nely"$ey"_nelz"$ez"_per"$iperx$ipery$iperz".co2" $cnew".co2"
}

gen_ref 
gen_new

python3 compare_con.py $cref $cnew 1 1


