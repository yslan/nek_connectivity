prefix = $(bin_nek_tools)

NOBJ = con2to3.o byte.o 

all: con2to3

con2to3:	$(NOBJ)
	$(FC) $(FFLAGS) -o $(prefix)/con2to3 $(NOBJ) $(LDFLAGS)

clean:
	@rm -f *.o


con2to3.o   : con2to3.f		;  $(FC) -c $(FFLAGS) con2to3.f
byte.o		: ../byte.c	      ;  $(CC) -c $(CFLAGS) ../byte.c

