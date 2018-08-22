# Put this Makefile in your project directory---i.e., the directory containing
# the paper you are writing. You can use it to create .html, .docx, and .pdf
# output files (complete with bibliography, if present) from your Markdown
# file.
#
# Additional notes:
# *	Change the paths at the top of the file as needed.
#
# *	Using `make` without arguments will generate html, tex, pdf, docx,
# 	and odt output files from all of the files with the designated
#	markdown extension. The default is `.md` but you can change this.
#
# *	You can specify an output format with `make tex`, `make pdf`,
#  	`make html`, `make odt`, or `make docx`
#
# *	Running `make clean` will only remove all, .html, .pdf, .odt,
#	and .docx files in your working directory **that have the same name
#	as your Markdown files**. Other files with these extensions will be safe.
#
# *	If wanted, remove the automatic call to `clean` to rely on make's
#   timestamp checking. However, if you do this, you'll need to add all the
#   document's images, etc. as dependencies, which means it might be easier
#   to just clean and delete everything every time you rebuild.


# ----------------------
# Modifiable variables
# ----------------------
# Markdown extension (e.g. md, markdown, mdown).
MEXT = md

# Optional folder for manuscript
MS_DIR = manuscript

# Location of Pandoc support files.
PREFIX = /Users/andrew/.pandoc

# Word and HTML can choke on PDF images, so those targets use a helper script
# named replace_pdfs to replace all references to PDFs with PNGs and convert
# existing PDFs to PNG using sips. However, there are times when it's better to
# *not* convert to PNG on the fly, like when using high resolution PNGs exprted
# from R with ggsave+Cairo. To disable on-the-fly conversion and supply your
# own PNGs, uncomment PNG_CONVERT below. The script will still replace
# references to PDFs with PNGs, but will not convert the PDFs
PNG_CONVERT = --no-convert

# Location of your working bibliography file
BIB_FILE = bib/references.bib

# CSL stylesheet (located in the csl folder of the PREFIX directory).
# Common CSLs:
#	* american-political-science-association
#   * chicago-fullnote-bibliography
#	* chicago-fullnote-no-bib
#   * chicago-syllabus-no-bib
#   * apa
#   * apsa-no-bib
CSL = chicago-author-date

# LaTeX doesn't use pandoc-citeproc + CSL and instead lets biblatex handle the
# heavy lifting. There are three possible styles built in to the template:
#   * bibstyle-chicago-notes
#   * bibstyle-chicago-authordate
#   * bibstyle-apa
TEX_REF = bibstyle-chicago-authordate
TEX_DIR = tex_out

# Cross reference options
CROSSREF = --filter pandoc-crossref -M figPrefix:"Figure" -M eqnPrefix:"Equation" -M tblPrefix:"Table"

# Blinding and version control
BLINDED = FALSE
VC_ENABLE = TRUE

# Blindify stuff if needed
ifeq ($(BLINDED), TRUE)
	# BLINDIFY = | ../lib/accecare.py ../lib/replacements.csv
	BLINDIFY = 
	VC_ENABLE = FALSE
else
	BLINDIFY = 
endif

# Enable fancy version control footers if needed
ifeq ($(VC_ENABLE), TRUE)
	VC_COMMAND = ./vc
	VC_PANDOC = -V pagestyle=athgit -V vc
else
	VC_COMMAND = 
	VC_PANDOC = 
endif


#--------------------
# Color definitions
#--------------------
NO_COLOR    = \x1b[0m
BOLD_COLOR	= \x1b[37;01m
OK_COLOR    = \x1b[32;01m
WARN_COLOR  = \x1b[33;01m
ERROR_COLOR = \x1b[31;01m


# --------------------
# Target definitions
# --------------------
# All markdown files in the working directory
SRC = $(wildcard $(MS_DIR)/*.$(MEXT))
BASE = $(basename $(SRC))

ifeq ($(MS_DIR), .)
	MS_DIR_FOR_TEX = 
else
	MS_DIR_FOR_TEX = "$(MS_DIR)/"
endif

# Targets
HTML=$(SRC:.md=.html)
TEX=$(SRC:.md=.tex)
MS_TEX=$(SRC:.md=-manuscript.tex)
ODT=$(SRC:.md=.odt)
DOCX=$(SRC:.md=.docx)
MS_ODT=$(SRC:.md=-manuscript.odt)
MS_DOCX=$(SRC:.md=-manuscript.docx)
BIB=$(SRC:.md=.bib)

all:	clean $(HTML) $(ODT) $(DOCX) $(MS_ODT) $(MS_DOCX) $(TEX) $(BIB)

html:	clean $(HTML)
odt:	clean $(ODT)
docx:	clean $(DOCX)
ms: 	clean $(MS_ODT)
msdocx:	clean $(MS_DOCX)
tex:	clean $(TEX)
mstex:	clean $(MS_TEX)
bib:	$(BIB)

%.html:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to HTML using standard template...$(NO_COLOR)"
	replace_includes $< | replace_pdfs $(PNG_CONVERT) $(BLINDIFY) | \
	pandoc -r markdown+ascii_identifiers+smart -s -w html \
		$(CROSSREF) \
		--default-image-extension=png \
		--mathjax \
		--table-of-contents \
		--metadata link-citations=true \
		--metadata linkReferences=true \
		--template=$(PREFIX)/templates/html.template \
		--css=$(PREFIX)/styles/ath-clean/ath-clean.css \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
	-o $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.tex:	%.md
	$(VC_COMMAND)
	@echo "$(WARN_COLOR)Converting Markdown to TeX using hikma-article template...$(NO_COLOR)"
	replace_includes $< $(BLINDIFY) | \
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block+smart+raw_tex -w latex -s \
		$(CROSSREF) \
		--default-image-extension=pdf \
		--filter pandoc-latex-fontsize \
		--pdf-engine=xelatex \
		--table-of-contents \
		--template=$(PREFIX)/templates/xelatex.template \
		--biblatex \
		-V $(TEX_REF) \
		--bibliography=$(BIB_FILE) \
		-V chapterstyle=hikma-article \
		$(VC_PANDOC) \
		--base-header-level=1 \
	-o $@
	@echo "$(WARN_COLOR)...converting TeX to PDF with latexmk (prepare for lots of output)...$(NO_COLOR)"
	latexmk -outdir=$(MS_DIR_FOR_TEX)$(TEX_DIR) -xelatex -quiet $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%-manuscript.tex:	%.md
	$(VC_COMMAND)
	@echo "$(WARN_COLOR)Converting Markdown to TeX using hikma-article manuscript template...$(NO_COLOR)"
	replace_includes $< $(BLINDIFY) | \
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block+smart+raw_tex -w latex -s \
		$(CROSSREF) \
		--default-image-extension=pdf \
		--filter pandoc-latex-fontsize \
		--pdf-engine=xelatex \
		--table-of-contents \
		--template=$(PREFIX)/templates/xelatex-manuscript.template \
		--biblatex \
		-V $(TEX_REF) \
		--bibliography=$(BIB_FILE) \
		$(VC_PANDOC) \
		--base-header-level=1 \
	-o $@
	@echo "$(WARN_COLOR)...converting TeX to PDF with latexmk (prepare for lots of output)...$(NO_COLOR)"
	latexmk -outdir=$(MS_DIR_FOR_TEX)$(TEX_DIR) -xelatex -quiet $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.odt:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to .odt using standard template...$(NO_COLOR)"
	replace_includes $< | replace_pdfs $(PNG_CONVERT) $(BLINDIFY) | \
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block+smart -w odt \
		$(CROSSREF) \
		--default-image-extension=png \
		--template=$(PREFIX)/templates/odt.template \
		--reference-doc=$(PREFIX)/styles/reference.odt \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
	-o $@;
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.docx:	%.odt
	@echo "$(WARN_COLOR)Converting .odt to .docx...$(NO_COLOR)"
	/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to docx --outdir $(MS_DIR) $<
	@echo "$(WARN_COLOR)Removing .odt file...$(NO_COLOR)"
	rm $<
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%-manuscript.odt: %.md
	@echo "$(WARN_COLOR)Converting Markdown to .odt using manuscript template...$(NO_COLOR)"
	replace_includes $< | replace_pdfs $(PNG_CONVERT) $(BLINDIFY) | \
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block+smart -w odt \
		$(CROSSREF) \
		--default-image-extension=png \
		--template=$(PREFIX)/templates/odt-manuscript.template \
		--reference-doc=$(PREFIX)/styles/reference-manuscript.odt \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
	-o $@

%.bib: %.md
	@echo "$(WARN_COLOR)Extracing all citations into a standalone .bib file...$(NO_COLOR)"
	bib_extract --bibtex_file $(BIB_FILE) $< $@

clean:
	@echo "$(WARN_COLOR)Deleting all existing targets...$(NO_COLOR)"
	rm -f $(addsuffix .html, $(BASE)) \
		$(addsuffix .odt, $(BASE)) $(addsuffix .docx, $(BASE)) \
		$(addsuffix -manuscript.odt, $(BASE)) $(addsuffix -manuscript.docx, $(BASE)) \
		$(addsuffix .tex, $(BASE)) $(addsuffix -manuscript.tex, $(BASE)) $(addsuffix .bib, $(BASE))
