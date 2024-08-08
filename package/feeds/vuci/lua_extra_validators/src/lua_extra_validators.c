#include <lauxlib.h>
#include <lualib.h>
#include <stdio.h>
#include <stdbool.h>
#include <inttypes.h>
#include <errno.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX_UINT64 0xFFFFFFFFFFFFFFFF
#define MIN_INT64  0x8000000000000000
#define MAX_INT64  0x7FFFFFFFFFFFFFFF

#define RETURN_OK(L)              \
	lua_pushboolean(L, true); \
	return 1;

#define RETURN_INVALID(L, err_fmt, ...)             \
	lua_pushboolean(L, false);                  \
	lua_pushfstring(L, err_fmt, ##__VA_ARGS__); \
	return 2;

enum parse_result {
	PARSE_OK,
	PARSE_ERROR,
	PARSE_ERROR_BOUNDS,
};

static enum parse_result parse_int64(char *str, size_t str_len)
{
	if (str == NULL || str_len == 0) {
		return PARSE_ERROR;
	}

	// Check if there are any leading characters before the number
	for (size_t i = 0; i < str_len; i++) {
		if (!(isdigit(str[i]) || str[i] == '-')) {
			return PARSE_ERROR;
		}
	}

	errno = 0;
	char *end_str = NULL;
	strtoll(str, &end_str, 10);

	if (errno == ERANGE) {
		return PARSE_ERROR_BOUNDS;
	}

	// Check if some characters were not parsed
	if (end_str != (str + str_len)) {
		return PARSE_ERROR;
	}

	return PARSE_OK;
}

static enum parse_result parse_uint64(char *str, size_t str_len)
{
	if (str == NULL || str_len == 0) {
		return PARSE_ERROR;
	}

	// Check if there are any leading characters before the number
	for (size_t i = 0; i < str_len; i++) {
		if (!(isdigit(str[i]) || str[i] == '-')) {
			return PARSE_ERROR;
		}
	}

	errno = 0;
	char *end_str = NULL;
	strtoull(str, &end_str, 10);

	if (errno == ERANGE) {
		return PARSE_ERROR_BOUNDS;
	}

	// Check if some characters were not parsed
	if (end_str != (str + str_len)) {
		return PARSE_ERROR;
	}

	// Check if there is a leading minus sign, if so then this is an out of bounds error
	if (str[0] == '-') {
		return PARSE_ERROR_BOUNDS;
	}

	return PARSE_OK;
}

static int validate_int64(lua_State *L)
{
	size_t str_len = 0;
	char *str = (char *)lua_tolstring(L, 1, &str_len);

	enum parse_result result = parse_int64(str, str_len);
	if (result == PARSE_OK) {
		RETURN_OK(L);
	} else if (result == PARSE_ERROR_BOUNDS) {
		char error_msg[128] = { 0 };
		snprintf(error_msg, sizeof(error_msg), "Range of the value must be from %"PRId64" to %"PRId64, MIN_INT64, MAX_INT64);
		RETURN_INVALID(L, error_msg);
	} else {
		RETURN_INVALID(L, "Value must be a valid 64bit integer");
	}
}

static int validate_uint64(lua_State *L)
{
	size_t str_len = 0;
	char *str = (char *)lua_tolstring(L, 1, &str_len);

	enum parse_result result = parse_uint64(str, str_len);
	if (result == PARSE_OK) {
		RETURN_OK(L);
	} else if (result == PARSE_ERROR_BOUNDS) {
		char error_msg[128] = { 0 };
		snprintf(error_msg, sizeof(error_msg), "Range of the value must be from 0 to %"PRIu64, MAX_UINT64);
		RETURN_INVALID(L, error_msg);
	} else {
		RETURN_INVALID(L, "Value must be a valid unsigned 64bit integer");
	}
}

static const luaL_Reg validators_lib[] = {
	{ "integer64" , validate_int64  },
	{ "uinteger64", validate_uint64 },
	{ NULL, NULL }
};

LUALIB_API int luaopen_lua_extra_validators(lua_State *L)
{
	luaL_register(L, "lua_extra_validators", validators_lib);
	return 1;
}
