

AM_CPPFLAGS = -D_XOPEN_SOURCE -D_SVID_SOURCE -D_BSD_SOURCE -D_DEFAULT_SOURCE \
    -D_GNU_SOURCE
AM_CFLAGS = -std=c99 -pedantic -Wall -Wextra \
    -Werror-implicit-function-declaration \
    -I$(top_srcdir)/src

check_PROGRAMS = \
	access \
	bootdisk \
	bootdisk2 \
	bitmap_read_segfault \
	bitmap_recreate \
	cache_crash \
	comment \
	del_test \
	dir_test \
	dir_test2 \
	dir_test_chdir \
	dispsect \
	file_test \
	file_test2 \
	file_test3 \
	file_read_hard_link_test \
	file_seek_test \
	file_seek_test2 \
	file_seek_after_write \
	fl_test \
	fl_test2 \
	floppy_overfilling_test \
	hardfile \
	hardfile2 \
	hd_test \
	hd_test2 \
	hd_test3 \
	hd_test_a590 \
	progbar \
	readonly \
	rename \
	rename2 \
	test_update_datasize_ofs \
	undel \
	undel2

dist_check_SCRIPTS = \
	bigdev.sh \
	bootdisk.sh \
	bitmap_read_segfault.sh \
	bitmap_recreate.sh \
	cache_crash.sh \
	common.sh \
	del_test.sh \
	dir_test.sh \
	dir_test2.sh \
	dir_test_chdir.sh \
	fl_test.sh \
	fl_test2.sh \
	floppy.sh \
	file_test.sh \
	file_test2.sh \
	file_test3.sh \
	file_seek_test.sh \
	file_seek_test2.sh \
	file_read_hard_link_test.sh \
	hardfile.sh \
	hd_test.sh \
	hd_test2.sh \
	hd_test3.sh \
	hd_test_a590.sh \
	rename.sh \
	undel.sh \
	undel2.sh

TESTS = \
    floppy.sh \
    bigdev.sh \
    floppy_overfilling_test \
    test_update_datasize_ofs

ADFLIBS = $(top_builddir)/src/libadf.la

access_SOURCES = access.c common.c common.h log.c log.h
access_LDADD = $(ADFLIBS)
access_DEPENDENCIES = $(top_builddir)/src/libadf.la

bitmap_read_segfault_SOURCES = bitmap_read_segfault.c log.c log.h
bitmap_read_segfault_LDADD = $(ADFLIBS)
bitmap_read_segfault_DEPENDENCIES = $(top_builddir)/src/libadf.la

bitmap_recreate_SOURCES = bitmap_recreate.c log.c log.h
bitmap_recreate_LDADD = $(ADFLIBS)
bitmap_recreate_DEPENDENCIES = $(top_builddir)/src/libadf.la

bootdisk_SOURCES = bootdisk.c common.c common.h log.c log.h
bootdisk_LDADD = $(ADFLIBS)
bootdisk_DEPENDENCIES = $(top_builddir)/src/libadf.la

bootdisk2_SOURCES = bootdisk2.c common.c common.h log.c log.h
bootdisk2_LDADD = $(ADFLIBS)
bootdisk2_DEPENDENCIES = $(top_builddir)/src/libadf.la

cache_crash_SOURCES = cache_crash.c
cache_crash_LDADD = $(ADFLIBS)
cache_crash_DEPENDENCIES = $(top_builddir)/src/libadf.la

# an incomplete test?
#cache_test_SOURCES = cache_test.c
#cache_test_LDADD = $(ADFLIBS)
#cache_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

comment_SOURCES = comment.c common.c common.h log.c log.h
comment_LDADD = $(ADFLIBS)
comment_DEPENDENCIES = $(top_builddir)/src/libadf.la

del_test_SOURCES = del_test.c common.c common.h log.c log.h
del_test_LDADD = $(ADFLIBS)
del_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

dir_test_SOURCES = dir_test.c common.c common.h log.c log.h
dir_test_LDADD = $(ADFLIBS)
dir_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

dir_test2_SOURCES = dir_test2.c common.c common.h log.c log.h
dir_test2_LDADD = $(ADFLIBS)
dir_test2_DEPENDENCIES = $(top_builddir)/src/libadf.la

#dirc_SOURCES = dirc.c
#dirc_LDADD = $(ADFLIBS)
#dirc_DEPENDENCIES = $(top_builddir)/src/libadf.la

#dirc_test_SOURCES = dirc_test.c
#dirc_test_LDADD = $(ADFLIBS)
#dirc_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

dir_test_chdir_SOURCES = dir_test_chdir.c
dir_test_chdir_LDADD = $(ADFLIBS)
dir_test_chdir_DEPENDENCIES = $(top_builddir)/src/libadf.la

dispsect_SOURCES = dispsect.c common.c common.h log.c log.h
dispsect_LDADD = $(ADFLIBS)
dispsect_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_read_hard_link_test_SOURCES = file_read_hard_link_test.c log.c log.h
file_read_hard_link_test_LDADD = $(ADFLIBS)
file_read_hard_link_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_seek_test_SOURCES = file_seek_test.c common.c common.h log.c log.h
file_seek_test_LDADD = $(ADFLIBS)
file_seek_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_seek_test2_SOURCES = file_seek_test2.c common.c common.h log.c log.h
file_seek_test2_LDADD = $(ADFLIBS)
file_seek_test2_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_seek_after_write_SOURCES = file_seek_after_write.c log.c log.h
file_seek_after_write_LDADD = $(ADFLIBS)
file_seek_after_write_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_test_SOURCES = file_test.c common.c common.h log.c log.h
file_test_LDADD = $(ADFLIBS)
file_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_test2_SOURCES = file_test2.c common.c common.h log.c log.h
file_test2_LDADD = $(ADFLIBS)
file_test2_DEPENDENCIES = $(top_builddir)/src/libadf.la

#file_test2a_SOURCES = file_test2a.c common.c common.h log.c log.h
#file_test2a_LDADD = $(ADFLIBS)
#file_test2a_DEPENDENCIES = $(top_builddir)/src/libadf.la

file_test3_SOURCES = file_test3.c common.c common.h log.c log.h
file_test3_LDADD = $(ADFLIBS)
file_test3_DEPENDENCIES = $(top_builddir)/src/libadf.la

fl_test_SOURCES = fl_test.c common.c common.h log.c log.h
fl_test_LDADD = $(ADFLIBS)
fl_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

fl_test2_SOURCES = fl_test2.c common.c common.h log.c log.h
fl_test2_LDADD = $(ADFLIBS)
fl_test2_DEPENDENCIES = $(top_builddir)/src/libadf.la

floppy_overfilling_test_SOURCES = floppy_overfilling_test.c log.c log.h
floppy_overfilling_test_LDADD = $(ADFLIBS)
floppy_overfilling_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

hardfile_SOURCES = hardfile.c common.c common.h log.c log.h
hardfile_LDADD = $(ADFLIBS)
hardfile_DEPENDENCIES = $(top_builddir)/src/libadf.la

hardfile2_SOURCES = hardfile2.c common.c common.h log.c log.h
hardfile2_LDADD = $(ADFLIBS)
hardfile2_DEPENDENCIES = $(top_builddir)/src/libadf.la

hd_test_SOURCES = hd_test.c common.c common.h log.c log.h
hd_test_LDADD = $(ADFLIBS)
hd_test_DEPENDENCIES = $(top_builddir)/src/libadf.la

hd_test2_SOURCES = hd_test2.c common.c common.h log.c log.h
hd_test2_LDADD = $(ADFLIBS)
hd_test2_DEPENDENCIES = $(top_builddir)/src/libadf.la

hd_test3_SOURCES = hd_test3.c common.c common.h log.c log.h
hd_test3_LDADD = $(ADFLIBS)
hd_test3_DEPENDENCIES = $(top_builddir)/src/libadf.la

hd_test_a590_SOURCES = hd_test_a590.c common.c common.h log.c log.h
hd_test_a590_LDADD = $(ADFLIBS)
hd_test_a590_DEPENDENCIES = $(top_builddir)/src/libadf.la

progbar_SOURCES = progbar.c common.c common.h log.c log.h
progbar_LDADD = $(ADFLIBS)
progbar_DEPENDENCIES = $(top_builddir)/src/libadf.la

readonly_SOURCES = readonly.c common.c common.h log.c log.h
readonly_LDADD = $(ADFLIBS)
readonly_DEPENDENCIES = $(top_builddir)/src/libadf.la

rename_SOURCES = rename.c common.c common.h log.c log.h
rename_LDADD = $(ADFLIBS)
rename_DEPENDENCIES = $(top_builddir)/src/libadf.la

rename2_SOURCES = rename2.c common.c common.h log.c log.h
rename2_LDADD = $(ADFLIBS)
rename2_DEPENDENCIES = $(top_builddir)/src/libadf.la

test_update_datasize_ofs_SOURCES = test_update_datasize_ofs.c
test_update_datasize_ofs_LDADD = $(ADFLIBS)
test_update_datasize_ofs_DEPENDENCIES = $(top_builddir)/src/libadf.la

undel_SOURCES = undel.c common.c common.h log.c log.h
undel_LDADD = $(ADFLIBS)
undel_DEPENDENCIES = $(top_builddir)/src/libadf.la

undel2_SOURCES = undel2.c common.c common.h log.c log.h
undel2_LDADD = $(ADFLIBS)
undel2_DEPENDENCIES = $(top_builddir)/src/libadf.la
