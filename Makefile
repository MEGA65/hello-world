
CC65=	/usr/local/bin/cc65
CL65=	/usr/local/bin/cl65
COPTS=	-t c64 -O -Or -Oi -Os --cpu 65c02
LOPTS=	-C c64-m65.cfg

FILES=		hello.prg \
		autoboot.c65

SOURCES=	main.c 

ASSFILES=	main.s \

HEADERS=	Makefile 

DISK.D81:	$(FILES)
	if [ -a DISK.D81 ]; then rm -f DISK.D81; fi
	cbmconvert -v2 -D8o DISK.D81 $(FILES)

%.s:	%.c $(HEADERS) $(DATAFILES)
	$(CC65) $(COPTS) -o $@ $<

hello.prg:	$(ASSFILES) c64-m65.cfg
	$(CL65) $(COPTS) $(LOPTS) -vm -m hello.map -o hello.prg $(ASSFILES)

clean:
	rm *.s *.prg *.o *.D81 *.map *.mem

test:	DISK.D81
	../xemu/build/bin/xc65.native -8 DISK.D81
