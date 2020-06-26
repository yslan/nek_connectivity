prefix = $(bin_nek_tools)

NOBJ1 = contoco2.o byte.o
NOBJ2 = co2tocon.o byte.o 
NOBJ3 = maptoco2.o byte.o byte2.o

all: co2tocon contoco2 maptoco2

contoco2:	$(NOBJ1)
	$(FC) $(FFLAGS) -o $(prefix)/contoco2 $(NOBJ1) $(LDFLAGS)

co2tocon:	$(NOBJ2)
	$(FC) $(FFLAGS) -o $(prefix)/co2tocon $(NOBJ2) $(LDFLAGS)

maptoco2:	$(NOBJ3)
	$(FC) $(FFLAGS) -o $(prefix)/maptoco2 $(NOBJ3) $(LDFLAGS)

clean:
	@rm -f *.o

co2tocon.o  : co2tocon.f		;  $(FC) -c $(FFLAGS) co2tocon.f
contoco2.o  : contoco2.f		;  $(FC) -c $(FFLAGS) contoco2.f
maptoco2.o  : maptoco2.f		;  $(FC) -c $(FFLAGS) maptoco2.f
byte.o		: ../byte.c	;  $(CC) -c $(CFLAGS) ../byte.c
byte2.o		: ./byte2.c	;  $(CC) -c $(CFLAGS) ./byte2.c
