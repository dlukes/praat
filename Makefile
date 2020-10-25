# File: Makefile

# Makefile for Praat.
# Paul Boersma, 24 May 2020

# System-dependent definitions of CC, LIBS, ICON and MAIN_ICON should be in
# makefile.defs, which has to be copied and renamed
# from a suitable makefile.defs.XXX file in the makefiles directory,
# Perhaps that file requires some editing.
include makefile.defs

.PHONY: all clean install

# Makes the Praat executable in the source directory.
all: LuaJIT
	$(MAKE) -C external/clapack
	$(MAKE) -C external/gsl
	$(MAKE) -C external/glpk
	$(MAKE) -C external/mp3
	$(MAKE) -C external/flac
	$(MAKE) -C external/portaudio
	$(MAKE) -C external/espeak
	$(MAKE) -C kar
	$(MAKE) -C melder
	$(MAKE) -C lua
	$(MAKE) -C sys
	$(MAKE) -C dwsys
	$(MAKE) -C stat
	$(MAKE) -C fon
	$(MAKE) -C dwtools
	$(MAKE) -C LPC
	$(MAKE) -C EEG
	$(MAKE) -C gram
	$(MAKE) -C FFNet
	$(MAKE) -C artsynth
	$(MAKE) -C LuaJIT amalg
	$(MAKE) -C LuaJIT install PREFIX=$(PWD)/LuaJIT
	$(MAKE) -C main main_Praat.o $(ICON)
	$(LINK) -o $(EXECUTABLE) main/main_Praat.o $(MAIN_ICON) fon/libfon.a \
		artsynth/libartsynth.a FFNet/libFFNet.a \
		gram/libgram.a EEG/libEEG.a \
		LPC/libLPC.a dwtools/libdwtools.a \
		fon/libfon.a stat/libstat.a dwsys/libdwsys.a \
		sys/libsys.a melder/libmelder.a kar/libkar.a \
		external/espeak/libespeak.a \
		external/portaudio/libportaudio.a \
		external/flac/libflac.a external/mp3/libmp3.a \
		external/glpk/libglpk.a \
		external/clapack/libclapack.a \
		external/gsl/libgsl.a \
		lua/libLuaPraat.a \
		$(LIBS)

LuaJIT:
	curl --proto '=https' --tlsv1.2 -sSfLO https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
	tar xvzf LuaJIT-2.1.0-beta3.tar.gz
	rm LuaJIT-2.1.0-beta3.tar.gz
	mv LuaJIT-2.1.0-beta3 LuaJIT

clean:
	$(MAKE) -C external/clapack clean
	$(MAKE) -C external/gsl clean
	$(MAKE) -C external/glpk clean
	$(MAKE) -C external/mp3 clean
	$(MAKE) -C external/flac clean
	$(MAKE) -C external/portaudio clean
	$(MAKE) -C external/espeak clean
	$(MAKE) -C kar clean
	$(MAKE) -C melder clean
	$(MAKE) -C lua clean
	$(MAKE) -C sys clean
	$(MAKE) -C dwsys clean
	$(MAKE) -C stat clean
	$(MAKE) -C fon clean
	$(MAKE) -C dwtools clean
	$(MAKE) -C LPC clean
	$(MAKE) -C EEG clean
	$(MAKE) -C gram clean
	$(MAKE) -C FFNet clean
	$(MAKE) -C artsynth clean
	$(MAKE) -C LuaJIT clean
	$(MAKE) -C main clean
	$(RM) praat

install:
	$(INSTALL)
