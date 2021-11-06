FC=gfortran
FCFLAGS=-c -O3 -static -Wall -mtune=native -ffpe-trap=invalid,zero,overflow,underflow,denormal -fbacktrace# -fdump-parse-tree -fdump-core#-fcheck=bounds
LDFLAGS= -static -O3

OBJECTS=SCREEN3C.o  SCREEN3B.o  SCREEN3A.o

all: $(OBJECTS)
	$(FC) $(LDFLAGS) $(OBJECTS) -o SCREEN3.EXE

%.o: %.FOR
	$(FC) $(FCFLAGS) $< -o $@

clean:
	rm -rf *.o *.mod *.EXE
