#include <common.h>
#include <tplink_image.h>
#include <flash.h>

extern uint32_t fb_alignto_leb(uint32_t);

int firstboot_erase_overlayfs()
{
	tplink_image_header_t *tpl_hdr;
	uint32_t overlay_ofs;
	char cmd[256];

	tpl_hdr = (tplink_image_header_t *) CFG_FW_START;

	overlay_ofs = fb_alignto_leb(tpl_hdr->ih_rootfs_ofs + tpl_hdr->ih_rootfs_len);

	sprintf(cmd, "erase %x %x", CFG_FW_START + overlay_ofs, CFG_FW_END - 1);

	if (run_command(cmd, 0) == -1) {
		printf_err("Could not erase flash\n");
		return 1;
	}

	return 0;
}