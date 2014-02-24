%{

/* Rely on vasprintf (GNU extension) instead of vsnprintf if
   possible... */
#ifdef HAVE_VASPRINTF
#define _GNU_SOURCE
#include <stdio.h>
#endif

#include <xcb/xcb.h>
#include <stdlib.h>
#include <stdarg.h>
#include "xcb_atom.h"

%}

%readonly-tables
%pic
%null-strings
%enum
%includes
%compare-strncmp

%struct-type
struct atom_map { int name; xcb_atom_t value; };
%%
define(`COUNT', 0)dnl
define(`DO', `$1,define(`COUNT', incr(COUNT))COUNT')dnl
include(atomlist.m4)`'dnl
%%

static const char atom_names[] =
define(`DO', `	"$1\0"')dnl
include(atomlist.m4);

static const uint16_t atom_name_offsets[] = {
define(`OFFSET', 0)dnl
define(`DO', `	OFFSET,define(`OFFSET', eval(OFFSET+1+len($1)))')dnl
include(atomlist.m4)`'dnl
};

xcb_atom_t xcb_atom_get_predefined(uint16_t name_len, const char *name)
{
	const struct atom_map *value = in_word_set(name, name_len);
	xcb_atom_t ret = XCB_NONE;
	if(value)
		ret = value->value;
	return ret;
}

const char *xcb_atom_get_name_predefined(xcb_atom_t atom)
{
	if(atom <= 0 || atom > (sizeof(atom_name_offsets) / sizeof(*atom_name_offsets)))
		return 0;
	return atom_names + atom_name_offsets[atom - 1];
}

static char *makename(const char *fmt, ...)
{
	char *ret;
	int n;
	va_list ap;

#ifndef HAVE_VASPRINTF
	char *np;
	int size = 64;

	/* First allocate 'size' bytes, should be enough usually */
	if((ret = malloc(size)) == NULL)
		return NULL;

	while(1)
	{
		va_start(ap, fmt);
		n = vsnprintf(ret, size, fmt, ap);
		va_end(ap);

		if(n < 0)
			return NULL;

		if(n < size)
			return ret;

		size = n + 1;
		if((np = realloc(ret, size)) == NULL)
		{
			free(ret);
			return NULL;
		}

		ret = np;
	}
#else
	va_start(ap, fmt);
	n = vasprintf(&ret, fmt, ap);
	va_end(ap);

	if(n < 0)
		return NULL;

	return ret;
#endif
}

char *xcb_atom_name_by_screen(const char *base, uint8_t screen)
{
	return makename("%s_S%u", base, screen);
}

char *xcb_atom_name_by_resource(const char *base, uint32_t resource)
{
	return makename("%s_R%08X", base, resource);
}

char *xcb_atom_name_unique(const char *base, uint32_t id)
{
	if(base)
		return makename("%s_U%lu", base, id);
	else
		return makename("U%lu", id);
}
