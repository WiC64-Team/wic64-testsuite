ASM = acme
ASMFLAGS = -f cbm -l main.sym -v3 --color -Wno-label-indent -Dwic64_build_report=1

INCLUDES = -I../wic64-library
SOURCES = *.asm tests/*.asm ../wic64-library/wic64.asm ../wic64-library/wic64.h

EMU ?= x64sc
EMUFLAGS ?=

TARGET = wic64-testsuite

.PHONY: all clean

all: $(TARGET).prg

$(TARGET).prg: $(SOURCES)
	$(ASM) $(ASMFLAGS) $(INCLUDES) -l $(TARGET).sym -o $(TARGET).prg  testsuite.asm

test: $(TARGET).prg
	$(EMU) $(EMUFLAGS) $(TARGET).prg

clean:
	rm -f *.{prg,sym}
