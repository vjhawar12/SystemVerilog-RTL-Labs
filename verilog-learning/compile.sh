#!/bin/bash
#touch build/$2.vcd
iverilog -g2012 -o build/$1.vvp rtl/$2.sv tb/$1.sv
vvp build/$1.vvp
gtkwave build/$2.vcd