###############################################################################
# latexmk configuration for the PFE memoire template
#
# What this file does:
#   - Compiles the .tex file(s) at the project root with pdflatex + bibtex
#     (latexmk re-runs as many times as needed for refs, TOC, biblio, etc.).
#   - Puts every auxiliary/intermediate file (.aux, .log, .toc, .lof, .lot,
#     .blg, .bbl, .out, .synctex.gz, .mtc*, ...) into the   build/   folder.
#   - Copies ONLY the final .pdf into the   output/   folder.
#
# Single command to build everything:    latexmk
#
# This file is intentionally pure ASCII (latexmk requires the rc-file to be
# UTF-8/ASCII). The actual .tex source files keep their original encoding.
###############################################################################

# ---- Default file to build (so `latexmk` with no args just works) ----------
# Use a filesystem glob: this is robust even when the .tex filename contains
# accented characters, because the bytes come straight from the OS instead
# of being hard-coded in this config file.
@default_files = glob('*.tex');

# ---- Engines & modes ------------------------------------------------------
$pdf_mode    = 1;   # 1 = pdflatex
$bibtex_use  = 2;   # always run bibtex if a .bib is referenced

$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';

# ---- Where the noise goes -------------------------------------------------
# All intermediate/aux files end up in build/ (kept out of project root).
$aux_dir = 'build';
$out_dir = 'build';

# Make sure folders exist before any run.
mkdir 'build'  unless -d 'build';
mkdir 'output' unless -d 'output';

# ---- Where LaTeX looks for inputs -----------------------------------------
# Tell pdflatex / bibtex where to find chapters, .sty packages and the bib.
# Trailing "//" means "search this folder recursively".
#
# We register paths twice (./folder// and ../folder//) so that the search
# works in both possible working directories:
#   - pdflatex is invoked with cwd = project root           => "./folder//"
#   - bibtex   is invoked with cwd = build/ (the aux dir)   => "../folder//"
# This keeps the rc-file portable across OSes / shells (no absolute paths).
ensure_path('TEXINPUTS', './chapters//');
ensure_path('TEXINPUTS', './styles//');
ensure_path('TEXINPUTS', './images//');
ensure_path('TEXINPUTS', '../chapters//');
ensure_path('TEXINPUTS', '../styles//');
ensure_path('TEXINPUTS', '../images//');
ensure_path('BIBINPUTS', './bibliography//');
ensure_path('BIBINPUTS', '../bibliography//');
ensure_path('BSTINPUTS', './bibliography//');
ensure_path('BSTINPUTS', '../bibliography//');

# ---- Post-build: keep ONLY the PDF in output/ -----------------------------
# Runs once latexmk is done. Copies any .pdf from build/ into output/.
END {
    require File::Copy;
    if (-d 'build') {
        mkdir 'output' unless -d 'output';
        opendir(my $dh, 'build') or return;
        while (my $f = readdir($dh)) {
            next unless $f =~ /\.pdf$/i;
            File::Copy::copy("build/$f", "output/$f")
                or warn "Could not copy build/$f -> output/$f : $!";
        }
        closedir($dh);
    }
}
