WFLAGS=-Wall -Wextra -Wno-unused-parameter
INCLUDES=-I$(STAGING_DIR)/usr/include/lua5.1 -I/usr/include/lua5.1 -I$(STAGING_DIR)/usr/include
LLUA=-llua

LIBNAME=lua_extra_validators.so

O_COMPILE=$(CC) $(WFLAGS) -fPIC $(DEFINES) -c -o $@ $(INCLUDES) $(CFLAGS) $<

all: $(LIBNAME)

lua_extra_validators.o: ./lua_extra_validators.c
	$(O_COMPILE)

$(LIBNAME): lua_extra_validators.o
	$(CC) -Wall $(LLUA) -shared -fPIC $(DEFINES) -o $@ $^ $(INCLUDES)

clean:
	$(RM) ./*.o
	$(RM) ./*.so