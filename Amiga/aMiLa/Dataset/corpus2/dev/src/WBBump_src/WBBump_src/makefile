
#ECOPTS=QUIET DEBUG SYM ADDBUF 2
ECOPTS=QUIET ADDBUF 2

EC=E:Bin/EC


%.m: %.e
	$(EC) $(ECOPTS) $<
%: %.e
	$(EC) $(ECOPTS) $<

%.wbbplugin: %.wbbplugin.e plugin.m
	$(EC) $(ECOPTS) $<

%.o: %.asm
	PHXASS $< TO $@ QUIET NOEXE

%.m: %.asm
	PHXASS $< TO $*.o QUIET NOEXE
	o2m2 $*
	FlushCache


all: wbbump plugins

wbbump.version::
	VersionMan WBBump BUMPBUILD BUMPDATE


wbbump:	wbbump.e bumper.m prefs.m get_bumper.m commodity.m version.m errors.m libs.m pluginmanager.m


get_bumper.m:	get_bumper.e bumper.m bumper_cgx8.m bumper_cgx24.m chunkyimage.m errors.m plugin.m plugin_const.m pluginmanager.m
bumper.m:	bumper.e prefs.m chunkyimage.m errors.m plugin.m plugin_const.m pluginmanager.m
bumper_cgx8.m:	bumper_cgx8.e bumper.m prefs.m hmap2lut.m brighttable.m chunkyimage.m errors.m pluginmanager.m
bumper_cgx24.m:	bumper_cgx24.e bumper.m prefs.m hmap2true.m brighttable.m chunkyimage.m errors.m pluginmanager.m

prefs.m:	prefs.e errors.m notify.m

errors.m:	errors.e

hmap2lut.m:	hmap2lut.asm
#hmap2lut.m:	hmap2lut.o

hmap2true.m:	hmap2true.asm
#hmap2true.m:	hmap2true.o

brighttable.m:	brighttable.e errors.m

commodity.m:	commodity.e prefs.m version.m errors.m

libs.m:		libs.e errors.m

chunkyimage.m:	chunkyimage.e errors.m threads.m chunkytools.m

chunkytools.m:	chunkytools.e

version.m:	version.e wbbump.version errors.m

threads.m:	threads.e errors.m

notify.m:	notify.e

plugin.m:	plugin.e plugin_const.m wbbump_plugin.m errors.m

plugin_const.m:	plugin_const.e

pluginmanager.m: pluginmanager.e plugin.m plugin_const.m errors.m

wbbump_plugin.m: wbbump_plugin.e

argparser.m:	argparser.e

#plugins

plugins: plugins/null.wbbplugin plugins/image.wbbplugin plugins/invert.wbbplugin plugins/blur.wbbplugin plugins/clock.wbbplugin

plugins/null.wbbplugin:		plugins/null.wbbplugin.e plugin_const.m

plugins/image.wbbplugin:	plugins/image.wbbplugin.e plugin_const.m argparser.m chunkyimage.m errors.m

plugins/invert.wbbplugin:	plugins/invert.wbbplugin.e plugin_const.m plugins/invert_supp.m
plugins/invert_supp.m:		plugins/invert_supp.asm

plugins/blur.wbbplugin:		plugins/blur.wbbplugin.e plugin_const.m plugins/blur_supp.m argparser.m
plugins/blur_supp.m:		plugins/blur_supp.asm

plugins/clock.wbbplugin:	plugins/clock.wbbplugin.e plugins/clock.png plugin_const.m argparser.m

