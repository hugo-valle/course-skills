# images/Makefile -- only .svg is committed. `make preview` is for visual checks.
SRC     := $(wildcard fig*.tex)
SVG     := $(SRC:.tex=.svg)
PREVIEW := .preview
PNG     := $(patsubst %.tex,$(PREVIEW)/%.png,$(SRC))
# Paths to the course style layer and base copy (COURSE.md "Figures"), relative to this folder.
STYLE   := <style layer> <base copy>
CROP    := $(HOME)/.claude/skills/course-images/reference/crop_png.py

all: $(SVG)

%.dvi: %.tex $(STYLE)
	latex -interaction=nonstopmode -halt-on-error $< >/dev/null

%.svg: %.dvi
	dvisvgm --no-fonts $< -o $@ 2>/dev/null
	@rm -f $*.dvi $*.aux $*.log

$(PREVIEW)/%.png: %.tex $(STYLE)
	@test -f $(CROP) || { echo "$(CROP) missing: run the course-skills install.sh" >&2; exit 1; }
	@mkdir -p $(PREVIEW)
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=$(PREVIEW) $< >/dev/null
	mutool draw -q -c rgb -r 130 -o $(PREVIEW)/$*.pnm $(PREVIEW)/$*.pdf 2>/dev/null
	python3 $(CROP) $(PREVIEW)/$*.pnm $@
	@rm -f $(PREVIEW)/$*.pnm

preview: $(PNG)

# clean/distclean delete .preview/ (PDFs, PNGs): ask the user first, see the course-images skill.
clean:
	rm -rf $(PREVIEW) *.aux *.log *.dvi

distclean: clean
	rm -f $(SVG)

.PHONY: all preview clean distclean
