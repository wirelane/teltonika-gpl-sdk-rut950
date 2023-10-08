/*
 * Copyright 2015 Google Inc.
 *
 * SPDX-License-Identifier: GPL 2.0+ BSD-3-Clause
 */

#include <config.h>
#include <common.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/ctype.h>
#include <malloc.h>

#define likely(x)   __builtin_expect((x), 1)
#define unlikely(x) __builtin_expect((x), 0)

#ifndef __packed
#define __packed __attribute__((packed))
#endif

#define EINVAL		22 /* Invalid argument */
#define EPROTO		71 /* Protocol error */
#define ENOBUFS		105 /* No buffer space available */
#define EPROTONOSUPPORT 123 /* Unknown protocol */

static void LZ4_copy4(void *dst, const void *src)
{
	memcpy(dst, src, 4);
}

static void LZ4_copy8(void *dst, const void *src)
{
	memcpy(dst, src, 8);
}

typedef uint8_t BYTE;
typedef uint16_t U16;
typedef uint32_t U32;
typedef int32_t S32;
typedef uint64_t U64;

#define FORCE_INLINE static inline __attribute__((always_inline))

/* Unaltered (except removing unrelated code) from github.com/Cyan4973/lz4. */
#include "lz4.c" /* #include for inlining, do not link! */

#define LZ4F_MAGIC 0x184D2204

struct lz4_frame_header {
	u32 magic;
	union {
		u8 flags;
		struct {
#if BYTE_ORDER == BIG_ENDIAN
			u8 version : 2;
			u8 independent_blocks : 1;
			u8 has_block_checksum : 1;
			u8 has_content_size : 1;
			u8 has_content_checksum : 1;
			u8 reserved0 : 2;
#else
			u8 reserved0 : 2;
			u8 has_content_checksum : 1;
			u8 has_content_size : 1;
			u8 has_block_checksum : 1;
			u8 independent_blocks : 1;
			u8 version : 2;
#endif
		};
	};
	union {
		u8 block_descriptor;
		struct {
#if BYTE_ORDER == BIG_ENDIAN
			u8 reserved2 : 1;
			u8 max_block_size : 3;
			u8 reserved1 : 4;
#else
			u8 reserved1 : 4;
			u8 max_block_size : 3;
			u8 reserved2 : 1;
#endif
		};
	};
	/* + u64 content_size iff has_content_size is set */
	/* + u8 header_checksum */
} __packed;

struct lz4_block_header {
	union {
		u32 raw;
		struct {
#if BYTE_ORDER == BIG_ENDIAN
			u32 not_compressed : 1;
			u32 size : 31;
#else
			u32 size : 31;
			u32 not_compressed : 1;
#endif
		};
	};
	/* + size bytes of data */
	/* + u32 block_checksum iff has_block_checksum is set */
} __packed;

int ulz4fn(const void *src, size_t srcn, void *dst, size_t *dstn)
{
	const void *end = dst + *dstn;
	const void *in	= src;
	void *out	= dst;
	int has_block_checksum;
	int ret;
	*dstn = 0;

	{ /* With in-place decompression the header may become invalid later. */
		const struct lz4_frame_header *h = in;

		if (srcn < sizeof(*h) + sizeof(u64) + sizeof(u8)) {
			return -EINVAL; /* input overrun */
		}

		/* We assume there's always only a single, standard frame. */
		if (le32_to_cpu(h->magic) != LZ4F_MAGIC || h->version != 1) {
			return -EPROTONOSUPPORT; /* unknown format */
		}
		if (h->reserved0 || h->reserved1 || h->reserved2) {
			return -EINVAL; /* reserved must be zero */
		}
		if (!h->independent_blocks) {
			return -EPROTONOSUPPORT; /* we can't support this yet */
		}
		has_block_checksum = h->has_block_checksum;

		in += sizeof(struct lz4_frame_header);
		if (h->has_content_size)
			in += sizeof(u64);
		in += sizeof(u8);
	}

	while (1) {
		struct lz4_block_header b;
		u32 tmp;
		memcpy(&tmp, in, 4);
		b.raw = le32_to_cpu(tmp);

		in += sizeof(struct lz4_block_header);

		if (in - src + b.size > srcn) {
			ret = -EINVAL; /* input overrun */
			break;
		}

		if (!b.size) {
			ret = 0; /* decompression successful */
			break;
		}

		if (b.not_compressed) {
			size_t size = min((ptrdiff_t)b.size, end - out);

			memcpy(out, in, size);

			out += size;
			if (size < b.size) {
				ret = -ENOBUFS; /* output overrun */
				break;
			}
		} else {
			/* constant folding essential, do not touch params! */
			ret = LZ4_decompress_generic(in, out, b.size, end - out,
						     endOnInputSize, full, 0,
						     noDict, out, NULL, 0);

			if (ret < 0) {
				ret = -EPROTO; /* decompression error */
				break;
			}
			out += ret;
		}

		in += b.size;
		if (has_block_checksum) {
			in += sizeof(u32);
		}
	}

	*dstn = out - dst;
	return ret;
}