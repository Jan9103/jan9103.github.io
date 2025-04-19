nu_files := $(shell ls *.nu)
generated_htmls := $(patsubst %.nu,%.html,$(nu_files))

all: $(generated_htmls)

%.html: %.nu
	nu $<


.PHONY: all
