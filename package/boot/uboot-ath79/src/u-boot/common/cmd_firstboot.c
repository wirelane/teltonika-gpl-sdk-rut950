#include <common.h>
#include <command.h>
#include <flash.h>

extern int firstboot_erase_overlayfs();

/* Allign address to the next erase-block (64KiB) */
uint32_t fb_alignto_leb(uint32_t addr)
{
	addr -= 1;
	addr &= ~0xffff;
	addr += 0x10000;
	return addr;
}

static int do_firstboot(struct cmd_tbl_s *cmdtbl, int flag, int argc, const char *argv[])
{
	printf("Erasing overlayfs...\n\n");
	if (firstboot_erase_overlayfs()) {
		printf_err("Failed to erase overlayfs\n");
		return 1;
	}
	printf("Reset complete\n\n");

	return 0;
}

U_BOOT_CMD(firstboot, 2, 0, do_firstboot, "Reset device to factory settings\n",
	   "\n"
	   "    - Reset device to factory settings\n");