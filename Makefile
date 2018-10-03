COPT=		-Wall -g -std=gnu99
CC=			gcc

OPHISDIR=	Ophis
OPHIS=		$(OPHISDIR)/bin/ophis
OPHISOPT=	-4
OPHIS_MON= 	$(OPHISDIR)/bin/ophis -c

CC65DIR= 	cc65
CC65=		$(CC65DIR)/bin/cc65
CL65=		$(CC65DIR)/bin/cl65
CA65=		$(CC65DIR)/bin/ca65 --cpu 4510
LD65=		$(CC65DIR)/bin/ld65 -t none

CBMCONVDIR= cbmconvert
CBMCONVERT=	$(CBMCONVDIR)/cbmconvert

XEMUDIR=	../xemu
COREDIR=	../mega65-core
MONLOAD=	$(COREDIR)/src/tools/monitor_load
BITSTRM=	$(COREDIR)/bin/nexys4ddr.bit
KICKUP=		$(COREDIR)/bin/KICKUP.M65
CHARROM=	$(COREDIR)/charrom.bin
C65SYSROM=	$(XEMUDIR)/rom/c65-system.rom

COPTS=		-t c64 -O -Or -Oi -Os --cpu 65c02 -I$(CC65DIR)/include
LOPTS=		-C c64-m65.cfg --asm-include-dir $(CC65DIR)/asminc --lib-path $(CC65DIR)/lib

FILES=		hello.prg \
			autoboot.c65

SOURCES=	main.c 

ASSFILES=	main.s

HEADERS=	Makefile 

$(CBMCONVERT):
	git submodule init
	git submodule update
	( cd cbmconvert && make -f Makefile.unix )

$(CC65):
	git submodule init
	git submodule update
	( cd cc65 && make -j 8 )

$(OPHIS):
	git submodule init
	git submodule update

DISK.D81:	$(CBMCONVERT) $(FILES)
	if [ -a DISK.D81 ]; then rm -f DISK.D81; fi
	$(CBMCONVERT) -v2 -D8o DISK.D81 $(FILES)

%.s:		%.c $(HEADERS) $(DATAFILES) $(CC65)
	$(CC65) $(COPTS) -o $@ $<

hello.prg:	$(ASSFILES) c64-m65.cfg
	$(CL65) $(COPTS) $(LOPTS) -vm -m hello.map -o hello.prg $(ASSFILES)

clean:
	rm -f *.s *.prg *.o *.D81 *.map *.mem

test: 		DISK.D81
	$(XEMUDIR)/build/bin/xc65.native -8 DISK.D81

$(MONLOAD):
	make -f $(COREDIR)/Makefile $(MONLOAD)

load: 		$(MONLOAD) hello.prg
	$(MONLOAD) -b $(BITSTRM) -R $(C65SYSROM) -k $(KICKUP) -C $(CHARROM) -4 -r hello.prg
