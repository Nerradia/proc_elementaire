#!/bin/bash
if [ $# -ne 2 ]; then
    echo $0: usage: $0 inputFile outputFile
    exit 1
fi
./compiler/compiler $1 "asm_to_hex_manager/inputFile.asm"
./asm_to_hex_manager/asm_to_hex_manager "asm_to_hex_manager/inputFile.asm" "data_transfer_manager/inputFile.bytes"
./data_transfer_manager/data_transfer_manager "data_transfer_manager/inputFile.bytes" $2
