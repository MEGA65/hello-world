COPT=	-Wall -g -std=gnu99
CC=	gcc
OPHIS=	Ophis/bin/ophis
OPHISOPT=	-4
OPHIS_MON= Ophis/bin/ophis -c

CC65=	cc65/bin/cc65
CL65=	cc65/bin/cl65

CA65=	cc65/bin/ca65 --cpu 4510
LD65=	cc65/bin/ld65 -t none

CBMCONVERT=	cbmconvert/cbmconvert


COPTS=	-t c64 -O -Or -Oi -Os --cpu 65c02
LOPTS=	-C c64-m65.cfg

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

%.s:	%.c $(HEADERS) $(DATAFILES) $(CC65)
	$(CC65) $(COPTS) -o $@ $<

hello.prg:	$(CC65) $(ASSFILES) c64-m65.cfg
	$(CL65) $(COPTS) $(LOPTS) -vm -m hello.map -o hello.prg $(ASSFILES)

clean:
	rm *.s *.prg *.o *.D81 *.map *.mem

test:	DISK.D81
	../xemu/build/bin/xc65.native -8 DISK.D81
