MAIN = main

BUILD_DIR = build

LATEX = pdflatex
BIB   = bibtex

LATEX_FLAGS = -interaction=nonstopmode -halt-on-error -output-directory=$(BUILD_DIR)

BIBTEX_FLAGS = -terse

PDF = $(BUILD_DIR)/$(MAIN).pdf

all: pdf bib

check:
	@kpsewhich my-codespace.sty >/dev/null || \
	  (echo "[ERROR] Missing package: my-codespace.sty" && exit 1)

pdf:
	@echo "=== Compile LaTeX ($(MAIN).tex) ==="
	-@mkdir -p $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex | tee $(BUILD_DIR)/build.log
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex | tee -a $(BUILD_DIR)/build.log
	@echo "=== Done: $(PDF) ==="

bib:
	@echo "=== Compile with BibTeX ==="
	-@mkdir -p $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex | tee $(BUILD_DIR)/build.log
	cd $(BUILD_DIR) && $(BIB) $(MAIN) $(BIBTEX_FLAGS)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex | tee -a $(BUILD_DIR)/build.log
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex | tee -a $(BUILD_DIR)/build.log
	@echo "=== Done: $(PDF) ==="


view: $(PDF)
	@echo "=== Open PDF ==="
	@firefox $(PDF)

clean:
	@echo "=== Clean temporary files ==="
	@if [ -d "$(BUILD_DIR)" ]; then \
	    find $(BUILD_DIR) -type f ! -name "*.pdf" -delete; \
	    echo "Cleaned temporary files in $(BUILD_DIR)"; \
	else \
	    echo "$(BUILD_DIR) does not exist"; \
	fi

cleanall:
	@echo "=== Remove all build files ==="
	rm -rf $(BUILD_DIR)
