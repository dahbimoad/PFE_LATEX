# Setup -- Fresh Windows PC, from zero to PDF

Follow these steps in order on a brand-new Windows machine. Every command
is meant to be run in a terminal (PowerShell or Git Bash). Pure ASCII so
nothing renders as garbage.

---

## 1. Install Git

Download and install: https://git-scm.com/download/win

Accept the defaults. This also installs **Git Bash**, which is what we'll
use as the terminal.

Verify:

```bash
git --version
```

---

## 2. Clone the repository

Open Git Bash, then:

```bash
cd ~/Desktop
git clone <REPO_URL> Memoire
cd Memoire
```

Replace `<REPO_URL>` with the URL of your repo
(e.g. `https://github.com/<user>/<repo>.git`).

---

## 3. Install MiKTeX (the LaTeX distribution)

Download and install: https://miktex.org/download

- Choose the **"Install MiKTeX for me only"** option (no admin rights needed).
- During install, set **"Install missing packages on the fly"** to **"Yes"**.
  This way MiKTeX will fetch any package it needs automatically the first
  time you compile.

Verify (open a NEW Git Bash window so PATH refreshes):

```bash
pdflatex --version
bibtex --version
```

---

## 4. Install Strawberry Perl (required by latexmk)

`latexmk` is a Perl script, so Windows needs a Perl runtime.

Download and install: https://strawberryperl.com

Accept the defaults. Open a NEW Git Bash window, then verify:

```bash
perl -v
```

---

## 5. Install latexmk (via MiKTeX)

Two options -- pick one.

### Option A: command line (fastest)

```bash
mpm --install=latexmk
```

### Option B: MiKTeX Console (GUI)

1. Open **MiKTeX Console** from the Start menu.
2. Go to **Packages**.
3. In the search bar, type `latexmk`.
4. Select it and click **Install** (the `+` button).

Verify:

```bash
latexmk --version
```

You should see something like `Latexmk, John Collins, ... Version 4.xx`.

---

## 6. Build the report (the ONE command)

From the project root (`cd` into the cloned folder):

```bash
latexmk
```

That's it. Wait for it to finish (it runs `pdflatex` + `bibtex` + reruns
`pdflatex` until cross-refs and TOC stabilize). The first run takes longer
because MiKTeX downloads any missing packages on the fly.

When it's done:

```bash
ls output/
```

You'll see exactly one file: the compiled PDF.

Open it:

```bash
start output/*.pdf
```

(`start` is the Windows command to open a file with its default viewer.)

---

## 7. Day-to-day workflow

| Goal                                | Command                              |
|-------------------------------------|--------------------------------------|
| Build the report                    | `latexmk`                            |
| Live rebuild on every save + viewer | `latexmk -pvc`                       |
| Force a full rebuild                | `latexmk -gg`                        |
| Clean intermediate files            | `latexmk -c`                         |
| Clean EVERYTHING (including PDFs)   | `latexmk -C`                         |
| Hard reset of build/ and output/    | `rm -rf build output`                |

---

## 8. Troubleshooting (Windows specifics)

| Symptom                                          | Fix                                                                 |
|--------------------------------------------------|---------------------------------------------------------------------|
| `latexmk: command not found`                     | MiKTeX not on PATH. Reopen Git Bash, or run step 5 again.           |
| `Can't locate File/Copy.pm`                      | Strawberry Perl not installed (step 4) or PATH not refreshed.       |
| MiKTeX keeps asking permission to install pkgs   | MiKTeX Console -> Settings -> "Always install missing packages: Yes". |
| `pdflatex` blocks on a missing package prompt    | Open MiKTeX Console -> Settings, set the install policy to Yes.     |
| Citations show as `[?]`                          | Run `latexmk -gg` once so bibtex regenerates `.bbl`.                |
| Stuck after restructuring / weird errors         | `latexmk -C && rm -rf build output && latexmk`                      |

---

## TL;DR (copy/paste, fresh machine, end-to-end)

```bash
# 1. Install: Git, MiKTeX, Strawberry Perl (download + run installers)
# 2. Then in Git Bash:
cd ~/Desktop
git clone https://github.com/dahbimoad/PFE_LATEX.git PFE
cd Memoire
mpm --install=latexmk
latexmk
start output/*.pdf
```

Done. The PDF lives in `output/`.
