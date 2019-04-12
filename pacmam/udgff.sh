#!/bin/bash

sintaxis () {
  echo "$0 bas|asm|c"
  exit
}

bas-array() {
  echo "dim udgSet(20,7) as ubyte => { _"
  sed -e 's/^[0-9][0-9]* DATA \(..*\)$/{ \1 } , _/' 
  echo "}"
}

c-array() {
  echo "unsigned char udgSet[21][8] = { _"
  sed -e 's/^[0-9][0-9]* DATA \(..*\)$/\{\1\} , _/' 
  echo "}"
}

asm-bytes() {
  echo "udgSet:"
  sed -e 's/^[0-9][0-9]* DATA \(..*\)$/db \1/' 
}


case $1 in
bas)	dos2unix | bas-array ;;
asm)	dos2unix | asm-bytes ;;
c)	dos2unix | c-array ;;
*)	sintaxis ;;
esac


