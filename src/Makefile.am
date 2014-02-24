
lib_LTLIBRARIES = libxcb-util.la

AM_CPPFLAGS = $(XCB_CFLAGS)
AM_CFLAGS = $(CWARNFLAGS)

libxcb_util_la_LIBADD = $(XCB_LIBS)
libxcb_util_la_LDFLAGS = -version-info 0:0:0 -no-undefined
libxcb_util_la_SOURCES = \
	atoms.c		\
	event.c		\
	xcb_aux.c

xcbinclude_HEADERS =	\
	xcb_util.h	\
	xcb_atom.h	\
	xcb_aux.h	\
	xcb_bitops.h	\
	xcb_event.h

BUILT_SOURCES = atoms.c atoms.gperf xcb_atom.h
CLEANFILES = $(BUILT_SOURCES)
EXTRA_DIST = atomlist.m4  atoms.gperf.m4  xcb_atom.h.m4

atoms.c: atoms.gperf
	$(GPERF) --output-file $@ $<

atoms.gperf: $(srcdir)/atoms.gperf.m4 $(srcdir)/atomlist.m4
	$(M4) -I$(srcdir) $< >$@

xcb_atom.h: $(srcdir)/xcb_atom.h.m4 $(srcdir)/atomlist.m4
	$(M4) -I$(srcdir) $< >$@

