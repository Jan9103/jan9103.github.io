nu_files := $(shell ls *.nu)
generated_htmls := $(patsubst %.nu,%.html,$(nu_files))

all: index.html

index.html: index.nu $(generated_html)
	nu index.nu

%.html: %.nu
	nu $<

.PHONY: all
