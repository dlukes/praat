include ../makefile.defs

CPPFLAGS = -I../melder -I../sys -I/usr/include/luajit-2.0
OBJECTS = LuaPraat.o

.PHONY: all clean

all: libLuaPraat.a

clean:
	$(RM) LuaPraat.cpp
	$(RM) $(OBJECTS)
	$(RM) libLuaPraat.a

libLuaPraat.a: $(OBJECTS)
	touch libLuaPraat.a
	rm libLuaPraat.a
	$(AR) cq libLuaPraat.a $(OBJECTS)
	$(RANLIB) libLuaPraat.a

%.o: *.h ../melder/*.h ../sys/*.h %.cpp

LuaPraat.cpp: LuaPraat.in praat.lua
	python3 include_str.py
