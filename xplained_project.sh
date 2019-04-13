#!/bin/bash

while getopts ":e p:s n:s b:s a:s" opt; do
    case $opt in
	a) aflag="$OPTARG";;
	b) bflag="$OPTARG";;
        e) eflag=1;;
        p) pflag="$OPTARG";;
        n) nflag="$OPTARG";;
        ?) printf "Usage: %s -n name [-p path] [-b board] [-a microcontroller] [-e]\n\t-n naam\t\tNaam van project\n\t[-p path]\t(Optioneel) Aparte map om aan te maken (anders wordt de naam van het project gebruikt als map naam in de huidige map)\n\t[-b board]\t(Optioneel) Board om voor te compilen (default: xplainedmini)\n\t[-a uc]\t\t(Optioneel) Microcontroller om voor te compilen (default: atmega328p)\n\t[-e]\t\t(Optioneel) Maak extra Emacs .dir-locals.el voor flycheck-clang AVR checker\n" `basename $0`; exit
    esac
done

if [ -z $nflag ]; then
    echo "Gebruik op zn minst -n [naam] voordat je dit scriptje aanroept"
    exit
fi

NAME="$nflag"

if [ ! -z "$pflag" ]; then
    DIR="$pflag"
else
    DIR="$nflag"
fi

if [ -d "$DIR" ]; then
    echo "Map bestaat al..."
    exit
fi

if [ ! -z $aflag ]; then
    UC="$aflag"
else
    UC="atmega328p"
fi

if [ ! -z $bflag ]; then
    BOARD="$bflag"
else
    BOARD="xplainedmini"
fi

mkdir $DIR

printf "CC=avr-gcc
CFLAGS=-g
MMCU=$UC
BOARD=$BOARD

build:
\tmkdir bin
\t\${CC} \${CFLAGS} -Os -mmcu=\${MMCU} -c $NAME.c -o bin/$NAME.o
\t\${CC} \${CFLAGS} -mmcu=\${MMCU} -o bin/$NAME.elf bin/$NAME.o
\tavr-objcopy -j .text -j .data -O ihex bin/$NAME.elf bin/$NAME.hex

upload:
\tavrdude -p \${MMCU} -c \${BOARD} -P usb -U flash:w:bin/$NAME.hex

.PHONY: clean

clean:
\trm -f bin/$NAME.*
" > $DIR/Makefile

echo "#define F_CPU 16000000
#include <avr/io.h>

int main(void) {
}
" > $DIR/$NAME.c

if [ ! -z "$eflag" ]; then
    echo "((c-mode . ((flycheck-clang-include-path . (\"/usr/avr/include\")))))" > $DIR/.dir-locals.el
fi
