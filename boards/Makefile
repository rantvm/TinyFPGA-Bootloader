TOPTARGETS := all clean

SUBDIRS := $(patsubst %/Makefile, %, $(wildcard */Makefile))

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
