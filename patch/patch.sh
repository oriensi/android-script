#!/bin/bash

if [[ 1 = ${#1} ]]; then
    OPERATOR=$1
    PATCH_DIR=$2
else
    echo "./patch <operator> <patch/path>"
    echo " <operator> c check, a apply, f am"
    exit
fi

for i in ` find $PATCH_DIR -type f -name "*.patch" | sort `; do
    TEMP_DIR=$i
    TEMP_DIR=`echo $TEMP_DIR | sed "s|$PATCH_DIR/*\(.*/\)[^/]*.patch$|\1|"`
    if [[ $OPERATOR = "c" ]]; then
        echo "git apply --check --directory=$TEMP_DIR $i"
        git apply --check --directory=$TEMP_DIR $i
    elif [[ $OPERATOR = "a" ]]; then
        echo "git apply --directory=$TEMP_DIR $i"
        git apply --directory=$TEMP_DIR $i
    elif [[ $OPERATOR = "f" ]]; then
        echo "git am --directory=$TEMP_DIR $i"
        git am --directory=$TEMP_DIR $i
    fi
    sleep 1s
done

