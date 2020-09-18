include ../makefile.defs

CPPFLAGS = -I../melder -I/usr/include/luajit-2.0
OBJECTS = luapraat.o

.PHONY: all clean

all: libluapraat.a main.o
	$(LINK) -o main main.o libluapraat.a -lluajit-5.1

clean:
	$(RM) $(OBJECTS)
	$(RM) libluapraat.a
	$(RM) main.o
	$(RM) main

libluapraat.a: $(OBJECTS)
	touch libluapraat.a
	rm libluapraat.a
	$(AR) cq libluapraat.a $(OBJECTS)
	$(RANLIB) libluapraat.a

main.o: main.cpp

$(OBJECTS): *.h
