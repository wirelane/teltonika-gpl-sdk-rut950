#include <common.h>
#include <command.h>
#include <image.h>

#define SQASHFS_MAGIC 0x73717368
typedef struct squashfs_header {
	uint32_t magic;
	uint32_t _unused[9];
	uint64_t bytes_used;
} squashfs_header_t;

extern uint32_t fb_alignto_leb(uint32_t);

int firstboot_erase_overlayfs(void)
{
	uint32_t rootfs_ofs;
	uint32_t overlay_ofs;
	char cmd[256];
	image_header_t *fw_hdr;
	squashfs_header_t *squashfs_hdr;

	fw_hdr = (image_header_t *) CFG_FW_START;

	if (ntohl(fw_hdr->ih_magic) != IH_MAGIC) {
		printf_err("Firmware image not found at 0x%08x\n", CFG_FW_START);
		return 1;
	}

	rootfs_ofs   = fb_alignto_leb(ntohl(fw_hdr->ih_size));
	squashfs_hdr = (squashfs_header_t *)(CFG_FW_START + rootfs_ofs);

	if (squashfs_hdr->magic != SQASHFS_MAGIC) {
		printf_err("SquashFS not found at =x%08x\n", CFG_FW_START + rootfs_ofs);
		return 1;
	}

	overlay_ofs = fb_alignto_leb(rootfs_ofs + squashfs_hdr->bytes_used);

	sprintf(cmd, "erase %x %x", CFG_FW_START + overlay_ofs, CFG_FW_END - 1);

	if (run_command(cmd, 0) == -1) {
		printf_err("Could not erase flash\n");
		return 1;
	}

	return 0;
}