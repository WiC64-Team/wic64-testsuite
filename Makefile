ASM = acme
ASMFLAGS = -f cbm -l main.sym -v3 --color -Wno-label-indent
INCLUDES = -I../wic64-library
SOURCES = *.asm tests/*.asm ../wic64-library/wic64.asm
EMU ?= x64sc
EMUFLAGS ?=

.PHONY: all clean

all: testsuite.prg

%.prg: %.asm $(SOURCES)
	$(ASM) $(ASMFLAGS) $(INCLUDES) -l $*.sym -o $*.prg  $*.asm

test: testsuite.prg
	$(EMU) $(EMUFLAGS) testsuite.prg

clean:
	rm -f *.{prg,sym,bin}
