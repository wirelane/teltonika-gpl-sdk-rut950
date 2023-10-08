WFLAGS=-Wall -Wextra -Wno-unused-parameter
DEFINES=-DREX_NOEMBEDDEDTEST -DLUA_USE_POSIX -DLUA_USE_DLOPEN -D VERSION=\"2.9.1\"
INCLUDES=-I$(STAGING_DIR)/usr/include/lua5.1 -I/usr/include/lua5.1
LLUA=-llua

LIBNAME=rex_posix.so

O_COMPILE=$(CC) $(WFLAGS) -fPIC $(DEFINES) -c -o $@ $(INCLUDES) $(CFLAGS) $<

all: $(LIBNAME)

lposix.o: ./src/posix/lposix.c
	$(O_COMPILE)

common.o: ./src/common.c
	$(O_COMPILE)

$(LIBNAME): lposix.o common.o
	$(CC) -Wall $(LLUA) -shared -fPIC $(DEFINES) -o $@ $^ $(INCLUDES)

clean:
	$(RM) ./*.o
	$(RM) ./*.so