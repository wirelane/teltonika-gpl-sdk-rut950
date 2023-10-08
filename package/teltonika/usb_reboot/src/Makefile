SOURCES = usb_reboot.c
LDLIBS = -lusb-1.0
INC_ROOT = -I$(STAGING_DIR)/usr/include/
INCLUDE = $(INC_ROOT)

ifeq ($(DEBUG),1)
   CFLAGS_D = -ggdb -D DEBUG=1 -o0
endif

%.o: %.c $(DEPS)
	$(CC) $(INCLUDE) $(CFLAGS) $(CFLAGS_D) -c -o $@ $<

usb_reboot: $(SOURCES)
	$(CC) $(INCLUDE) $(CFLAGS) $(LDFLAGS) $(CFLAGS_D) -o $@ $^ $(LDLIBS)
