
CC65=	/usr/local/bin/cc65
CL65=	/usr/local/bin/cl65
COPTS=	-t c64 -O -Or -Oi -Os --cpu 65c02
LOPTS=	-C c64-m65.cfg
XEMUBIN=../xemu/build/bin/xc65.native
#XEMUBIN=../xemu/build/bin/xmega65.native
#XEMUSDIMG=-sdimg ../mega65-core/src/utilities/mysdcardimage.img

FILES=		hello.prg \
		autoboot.c65

SOURCES=	main.c 

ASSFILES=	main.s \

HEADERS=	Makefile 

DISK.D81:	$(FILES)
	cbmconvert -v2 -D8o DISK.D81 $(FILES)

%.s:	%.c $(HEADERS) $(DATAFILES)
	$(CC65) $(COPTS) -o $@ $<

hello.prg:	$(ASSFILES) c64-m65.cfg
	$(CL65) $(COPTS) $(LOPTS) -vm -m hello.map -o hello.prg $(ASSFILES)

clean:
	rm *.s *.prg *.o *.D81 *.map *.mem

test:	DISK.D81
	${XEMUBIN} -skipunhandledmem ${XEMUSDIMG} -8 DISK.D81
