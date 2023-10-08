#include <common.h>

#ifdef CONFIG_MNFINFO_SUPPORT

#include <mnf_info.h>

#define MNF_INFO_SIZE 0x10000

static char mnf_cache[MNF_INFO_SIZE];

extern int mnf_flash_read(const mnf_field_t *field, char *result)
{
        memcpy(result, (void *) CFG_FLASH_BASE + OFFSET_MNF_INFO + field->offset, field->length);
        return 0;
}

extern int mnf_flash_write_init(void)
{
        memcpy(mnf_cache, (void *) CFG_FLASH_BASE + OFFSET_MNF_INFO, MNF_INFO_SIZE);
        return 0;
}

extern int mnf_flash_write(const mnf_field_t *field, const char *buf)
{
        memcpy(mnf_cache + field->offset, buf, field->length);
        return 0;
}

extern int mnf_flash_write_finalize(void)
{
        unsigned sector = OFFSET_MNF_INFO / flash_info[0].sector_size;

        if (flash_erase(&flash_info[0], sector, sector))
                return 1;

        if (write_buff(&flash_info[0], (uchar *)mnf_cache, CFG_FLASH_BASE + OFFSET_MNF_INFO, MNF_INFO_SIZE))
                return 1;

        /*
         * WORKAROUND
         *
         * So it seems like the CPU cache on atheros chips is unaware of memory mapped 
         * SPI nor flash and caches any reads/writes to that memory region. Since the flash 
         * is written through a seperate channel, the cache does not get updated and subsequent 
         * reads end up returning old values. Funnily enough, writes to said memory region do 
         * not seem to cause a cpu fault or anything, so we can just 'update' the cache ourselves...
         * 
         * And hey, it's not very critical code anyway, just don't breathe at it the wrong way.
         */
        memcpy((void *) CFG_FLASH_BASE + OFFSET_MNF_INFO, mnf_cache, MNF_INFO_SIZE);

        return 0;
}

#endif