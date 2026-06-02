#!/bin/bash

set -e

TEST_NAME=$1
BLOCK=$2

mkdir -p build

iverilog -g2012 -o build/${TEST_NAME}.vvp \
    rtl/${BLOCK}/${TEST_NAME}.sv \
    tb/${BLOCK}/tb_${TEST_NAME}.sv

vvp build/${TEST_NAME}.vvp

gtkwave build/${TEST_NAME}.vcd