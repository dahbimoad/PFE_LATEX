# PFE Memoire -- LaTeX Template

A clean, ready-to-use LaTeX template for the Projet de Fin d'Etudes (PFE)
report of Ecole Nationale des Sciences Appliquees de Tanger -- Universite
Abdelmalek Essaadi.

> One command builds the entire memoire and drops a single, clean PDF in
> `output/`. Every intermediate file (.aux, .log, .toc, .bbl, .synctex.gz, ...)
> stays hidden inside `build/`.

NOTE: this README is intentionally written in pure ASCII so it renders the
same on every editor, terminal and OS. The actual report source files
(Memoire.tex, chapters, etc.) keep their original Latin-1 / ansinew encoding
- nothing was changed there.

---

## 1. TL;DR -- the ONE command

> First time on a brand-new Windows PC? Read **[SETUP.md](SETUP.md)** for the
> full from-zero install (Git + MiKTeX + Strawberry Perl + latexmk + clone +
> first build). Otherwise stick to this section.

From the project root, just run:

```bash
latexmk
```

That's it. After it finishes:

- The compiled report is at `output/Memoire.pdf` (the actual file name on disk
  is `Memoire.tex` -> `Memoire.pdf`, with the original accent on the "e";
  the README spells it without the accent only to stay ASCII-safe).
- All temporary files are inside `build/` -- you can delete that folder any
  time without touching your sources.

To wipe every build artifact (and the output PDF) and start fresh:

```bash
latexmk -C
rm -rf build output
```

---

## 2. Project layout

```
.
|-- Memoire.tex            # main document (entry point) -- DO NOT RENAME
|-- .latexmkrc             # build configuration (read automatically by latexmk)
|-- .gitignore             # ignores build/, aux files, OS junk, etc.
|-- README.md              # this file
|-- SETUP.md               # from-zero install guide for a fresh Windows PC
|
|-- chapters/              # all written content (.tex)
|   |-- Abstract.tex       # Resume + Abstract (FR/EN)
|   |-- Dedicace.tex       # dedicace
|   |-- Remerciement.tex   # remerciements
|   |-- Introduction.tex   # introduction generale
|   |-- Chapitre-1.tex     # presentation entreprise / contexte
|   |-- Chapitre-2.tex     # chapitre 2
|   |-- Chapitre-3.tex     # chapitre 3
|   |-- Chapitre-4.tex     # chapitre 4
|   |-- Conclusion.tex     # conclusion generale
|   |-- Annexe-1.tex       # annexe A
|   `-- Annexe-2.tex       # annexe B
|
|-- styles/                # bundled LaTeX packages (.sty) the template needs
|   |-- algorithm.sty
|   |-- algorithme.sty     # French keywords for algorithms
|   |-- algorithmic.sty
|   |-- breakcites.sty
|   |-- fancyhdr.sty
|   `-- framed.sty
|
|-- bibliography/          # bibliography sources & styles
|   |-- Bibliographie.bib  # <-- add / edit your BibTeX entries here
|   |-- apalike-fr.bst     # alternative French style
|   `-- plainnatfrench.bst # alternative French style
|
|-- images/                # all figures (.png .jpg .pdf ...)
|
|-- build/                 # auto-generated, ALL aux/log/toc/synctex files
`-- output/                # auto-generated, contains ONLY the final PDF
```

### Why this layout?

| Folder          | Purpose                                                                  |
|-----------------|--------------------------------------------------------------------------|
| `chapters/`     | Anything you actually WRITE. One file per logical part of the report.    |
| `styles/`       | Third-party `.sty` shipped with the template -- you almost never touch.  |
| `bibliography/` | Your `.bib` references and the BibTeX style files.                       |
| `images/`       | All figures referenced from chapters via `\includegraphics{images/...}`. |
| `build/`        | Latexmk dumps every intermediate file here. Safe to delete any time.     |
| `output/`       | Final deliverable PDF, and NOTHING ELSE. Hand this to your jury.         |

---

## 3. Requirements & install

> On a brand-new Windows machine, follow **[SETUP.md](SETUP.md)** instead of
> this section -- it's a step-by-step guide (Git, MiKTeX, Strawberry Perl,
> latexmk, clone, first build). The summary below is for everyone else.

You need a TeX distribution and `latexmk`.

### 3.1 Install a TeX distribution (one of)

- MiKTeX (Windows)         : https://miktex.org/download
- TeX Live (cross-platform): https://tug.org/texlive/
- MacTeX (macOS)           : https://tug.org/mactex/

Make sure `pdflatex` and `bibtex` are on your PATH:

```bash
pdflatex --version
bibtex --version
```

### 3.2 Install `latexmk`

`latexmk` is a Perl script that automates running pdflatex / bibtex the
right number of times.

- MiKTeX (Windows): open the MiKTeX Console -> Packages -> search `latexmk`
  -> install. You also need Perl. Easiest options:
    * install Strawberry Perl: https://strawberryperl.com   (recommended on Windows)
    * or use Git for Windows / Git Bash, which already ships a Perl.
- TeX Live / MacTeX: `latexmk` is included by default. Otherwise:
  ```bash
  tlmgr install latexmk
  ```
- Linux (Debian / Ubuntu):
  ```bash
  sudo apt-get install latexmk
  ```

Verify the install:

```bash
latexmk --version
```

---

## 4. How the build works (so the AI / you can reason about it)

The whole behavior is configured in `.latexmkrc` at the project root.
Latexmk reads that file automatically; you don't pass any flags.

Key things `.latexmkrc` does:

1. Picks the entry file -- `@default_files = glob('*.tex')` grabs the .tex
   file at the project root, which is why running `latexmk` with no
   arguments just works.
2. Sets the engine -- `$pdf_mode = 1` => pdflatex, `$bibtex_use = 2`
   => always run bibtex.
3. Routes outputs -- `$aux_dir = $out_dir = 'build'` makes pdflatex write
   everything (including the intermediate .pdf) inside `build/`.
4. Tells LaTeX where files live via TEXINPUTS / BIBINPUTS / BSTINPUTS:
     - `chapters/`, `styles/`, `images/` are searched recursively for
       `\input` / `\include` / `\usepackage` / `\includegraphics`.
     - `bibliography/` is searched for `.bib` and `.bst`.
   Each path is added twice (`./folder//` and `../folder//`) so that
   pdflatex (cwd = project root) AND bibtex (cwd = build/) both find
   their files.
   This is why the source files were moved into subfolders without
   changing a single line of the main `.tex`.
5. Post-build hook (`END { ... }`) -- copies the produced .pdf from
   `build/` into `output/`, so `output/` only ever contains the final PDF.

### Build flow, step by step

```
   latexmk
      |
      |-- reads .latexmkrc
      |-- finds the main .tex via glob('*.tex')
      |-- runs pdflatex   (writes .aux/.toc/.log/.pdf into build/)
      |-- runs bibtex     (writes .bbl/.blg into build/)
      |-- re-runs pdflatex 1-2x until cross-refs & TOC stabilize
      `-- END hook -> copies build/<name>.pdf -> output/<name>.pdf
```

---

## 5. Common tasks

### Build the report
```bash
latexmk
```

### Force a full rebuild from scratch
```bash
latexmk -gg
```

### Continuous mode (rebuild on every save, opens a PDF viewer)
```bash
latexmk -pvc
```

### Clean intermediate files (keeps the PDF)
```bash
latexmk -c
```

### Clean EVERYTHING (including PDFs)
```bash
latexmk -C
```

### Hard reset of build/ and output/
```bash
rm -rf build output
```

---

## 6. Editing the report

| Task                              | Where                                                             |
|-----------------------------------|-------------------------------------------------------------------|
| Change title / author / jury      | titlepage block in the main .tex file                             |
| Edit a chapter                    | `chapters/Chapitre-N.tex`                                         |
| Edit intro / conclusion           | `chapters/Introduction.tex` / `chapters/Conclusion.tex`           |
| Add an annex                      | Add `chapters/Annexe-N.tex` and `\include{Annexe-N}` in main .tex |
| Add an image                      | Drop file in `images/`, then `\includegraphics{images/yourfile.pdf}` |
| Add a bibliography reference      | Append a BibTeX entry to `bibliography/Bibliographie.bib`, then `\cite{key}` |
| Change citation style             | `\bibliographystyle{ieeetr}` line near the bottom of the main .tex |

> The `\include{...}` calls in the main .tex use file BASENAMES only
> (e.g. `\include{Chapitre-1}`). They keep working because `.latexmkrc`
> adds `chapters/` to TEXINPUTS.

---

## 7. Troubleshooting

| Symptom                                            | Likely fix                                                                  |
|----------------------------------------------------|-----------------------------------------------------------------------------|
| `latexmk: command not found`                       | TeX not on PATH, or latexmk not installed (see section 3).                  |
| `Can't locate File/Copy.pm` or other Perl error    | Install Strawberry Perl on Windows (latexmk needs Perl).                    |
| Citations show as `[?]`                            | Run `latexmk -gg` once so bibtex regenerates `.bbl`.                        |
| Old/garbled output after restructuring             | `latexmk -C && rm -rf build output && latexmk`                              |
| `File 'images/xxx' not found`                      | Image file is missing in `images/` or path is wrong in `\includegraphics`.  |
| `! LaTeX Error: File 'something.sty' not found.`   | Missing in `styles/`, or your TeX dist doesn't have it (use `tlmgr`/MiKTeX).|

---

## 8. What was changed vs. the original template

- Reorganised loose files into `chapters/`, `styles/`, `bibliography/`.
- Removed pre-built artefacts (`Memoire.pdf`, `Memoire.synctex.gz`, `Thumbs.db`).
- Added `build/` (intermediate files) and `output/` (final PDF only).
- Added `.latexmkrc` so a single `latexmk` call does the whole pipeline.
- Source content, encoding, and the main `.tex` file were left untouched.
