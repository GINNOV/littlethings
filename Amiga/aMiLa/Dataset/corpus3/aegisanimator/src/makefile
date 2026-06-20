SUBDIRS = asm c libatari libm player

all clean ALL CLEAN::
	#when using a real shell:
	#for i in $(SUBDIRS); do $(MAKE) -C $$i $@; done
	#when using mupfel:
	#for i in $(SUBDIRS) do $(MAKE) -C $$i $@
	#when using brain-damaged command.prg:
	$(MAKE) -C asm $@
	$(MAKE) -C c $@
	$(MAKE) -C libatari $@
	$(MAKE) -C libm $@
	$(MAKE) -C player $@
