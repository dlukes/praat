include ../makefile.defs

CPPFLAGS = -I../melder -I/usr/include/luajit-2.0
OBJECTS = luapraat.o

.PHONY: all clean

all: libluapraat.a

clean:
	$(RM) $(OBJECTS)
	$(RM) libluapraat.a

libluapraat.a: $(OBJECTS)
	touch libluapraat.a
	rm libluapraat.a
	$(AR) cq libluapraat.a $(OBJECTS)
	$(RANLIB) libluapraat.a

$(OBJECTS): *.h
