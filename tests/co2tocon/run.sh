src="../../bin/"
co2tocon=$src"co2tocon"
contoco2=$src"contoco2"

RED='\033[0;31m'
GREEN='\033[;32m'
NC='\033[0m'


# Check path
if [ ! -f "$co2tocon" ];then
  echo $co2tocon" file not exists!"
  exit 1
fi
if [ ! -f "$contoco2" ];then
  echo $contoco2" file not exists!"
  exit 1
fi


# Clean output
rm eddy_uvb.con eddy_uv.co2  2> /dev/null
if [ "$1" == "clean" ]; then # clean only
  exit 0
fi


# Test 1
$co2tocon << EOF
eddy_uvb
EOF

err1=`diff eddy_uvb.con eddy_uv.con`
test1="eddy_uvb.co2 -> eddy_uvb.con"
if [ -z "$err1" ]; then
  echo -e "\nTest 1: $test1 ${GREEN}PASSED${NC}\n\n"
else
  echo -e "\nTest 1: $test1 ${RED}FAILED${NC}\n\n"
fi


# Test 2
$contoco2 << EOF
eddy_uv
EOF

err2=`diff eddy_uvb.co2 eddy_uv.co2`
test2="eddy_uv.con -> eddy_uv.co2"
if [ -z "$err2" ]; then
  echo -e "\nTest 2: $test1 ${GREEN}PASSED${NC}\n\n"
else
  echo -e "\nTest 2: $test2 ${RED}FAILED${NC}\n\n"
fi
