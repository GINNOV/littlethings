all:
	@for a in *; do if test -d "$$a" -a -e "$$a/Makefile"; then cd $$a ; $(MAKE) ; cd ..; fi; done

clean:
	@for a in *; do if test -d "$$a" -a -e "$$a/Makefile"; then cd $$a ; $(MAKE) clean; cd ..; fi; done

