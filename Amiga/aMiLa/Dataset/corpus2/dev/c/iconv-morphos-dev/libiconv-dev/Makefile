.PHONY: all dump install install-iso clean

all:
	@cd libiconv; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;
	@cd libiconv/MorphOS; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;

dump:
	@cd libiconv/MorphOS; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;

install:
	@cd libiconv; if ! $(MAKE) all; then exit 1; fi;
	@cd libiconv/MorphOS; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;

install-iso:
	@cd libiconv; if ! $(MAKE) all; then exit 1; fi;
	@cd libiconv/MorphOS; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;

clean:
	@cd libiconv; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;
	@cd libiconv/MorphOS; if ! $(MAKE) $(MAKECMDGOALS); then exit 1; fi;
