WFLAGS=-Wall -Wextra -Wno-unused-parameter
DEFINES=-DREX_NOEMBEDDEDTEST -DPCRE2_CODE_UNIT_WIDTH=8  -D VERSION=\"2.9.1\" 
INCLUDES=-I$(STAGING_DIR)/usr/include/lua5.1 -I/usr/include/lua5.1 -I$(STAGING_DIR)/usr/include
LLUA=-llua

LIBNAME=rex_pcre2.so

O_COMPILE=$(CC) $(WFLAGS) -fPIC $(DEFINES) -c -o $@ $(INCLUDES) $(CFLAGS) $<

all: $(LIBNAME)

lpcre2.o: ./src/pcre2/lpcre2.c
	$(O_COMPILE)

lpcre2_f.o: ./src/pcre2/lpcre2_f.c
	$(O_COMPILE)

common.o: ./src/common.c
	$(O_COMPILE)

$(LIBNAME): common.o lpcre2.o lpcre2_f.o
	$(CC) -Wall $(LLUA) -lpcre2-8  -shared -fPIC $(DEFINES) -o $@ $^ $(INCLUDES)

clean:
	$(RM) ./*.o
	$(RM) ./*.so
