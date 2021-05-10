#!/bin/bash
ARCH=$1
CARDANO=$2

echo "Configure cardano $ARCH"

for i in $( cat /patches/$CARDANO/$ARCH/index|grep -v ^# )
do 
        echo Apply patch $i 
        cat /patches/$CARDANO/$ARCH/$i |patch -p1 
done 

