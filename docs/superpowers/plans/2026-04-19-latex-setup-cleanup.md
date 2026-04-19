# LaTeX Setup Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up the LaTeX build configuration to remove dead code, fix broken tooling, prevent gitignore conflicts, and deduplicate CI workflows.

**Architecture:** Five independent config edits across `.latexmkrc`, `.gitignore`, `.vscode/settings.json`, and `.github/workflows/`. Each task is self-contained and can be committed independently.

**Tech Stack:** latexmk, GitHub Actions (reusable workflows), VSCode LaTeX Workshop

---

### Task 1: Remove dead biber config from `.latexmkrc`

**Files:**
- Modify: `.latexmkrc:6`

- [ ] **Step 1: Delete the biber line**

Remove line 6 from `.latexmkrc`. The file should go from:

```perl
$latex = 'latex -interaction=nonstopmode -shell-escape';
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape';

$out_dir = 'build';

$biber = 'biber --input-directory build --output-directory build %O %S';

$ENV{'TEXINPUTS'} = './fonts//:' . ($ENV{'TEXINPUTS'} // '');
```

To:

```perl
$latex = 'latex -interaction=nonstopmode -shell-escape';
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape';

$out_dir = 'build';

$ENV{'TEXINPUTS'} = './fonts//:' . ($ENV{'TEXINPUTS'} // '');
```

- [ ] **Step 2: Verify latexmk still parses the config**

Run: `latexmk -pdf -f -n $PWD/main.tex 2>&1 | head -5`

Expected: No perl syntax errors. The `-n` flag does a dry run without actually compiling.

- [ ] **Step 3: Commit**

```bash
git add .latexmkrc
git commit -m "fix(build): remove dead biber config from latexmkrc"
```

---

### Task 2: Extract reusable CI compile workflow

**Files:**
- Create: `.github/workflows/compile.yml`
- Modify: `.github/workflows/build.yml`
- Modify: `.github/workflows/release.yml`

- [ ] **Step 1: Create the reusable compile workflow**

Create `.github/workflows/compile.yml`:

```yaml
name: Compile LaTeX

on:
  workflow_call:
    inputs:
      artifact-name:
        description: Name for the uploaded PDF artifact
        required: false
        default: build-pdf
        type: string

jobs:
  compile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: xu-cheng/latex-action@v3
        name: "Compile document"
        with:
          root_file: main.tex
          latexmk_use_lualatex: false
          latexmk_shell_escape: true
          args: -pdf -f
          extra_fonts: |
            ./fonts/*
          post_compile: "cp build/main.pdf main.pdf"

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ inputs.artifact-name }}
          path: ./main.pdf
```

- [ ] **Step 2: Update `build.yml` to call the reusable workflow**

Replace the full contents of `.github/workflows/build.yml` with:

```yaml
name: Build
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:

  compile:
    uses: ./.github/workflows/compile.yml

  upload:
    runs-on: ubuntu-latest
    needs: compile
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: build-pdf

      - name: Rename main.pdf
        run: |
          r=$(git describe --tags --always)
          mv main.pdf ${r}.pdf

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-pdf-renamed
          path: ./*.pdf
```

Note: The original `build.yml` uploaded as `build-pdf` but overwrote the compile artifact name. The new version uses `build-pdf-renamed` for the final artifact to avoid name collision with the compile step's artifact.

- [ ] **Step 3: Update `release.yml` to call the reusable workflow**

In `.github/workflows/release.yml`, replace the `build` job (lines 78-101) with:

```yaml
  build:
    name: Build document
    needs: [create-tag, setup-envs]
    if: needs.create-tag.outputs.skip == 'false'
    uses: ./.github/workflows/compile.yml
    with:
      artifact-name: main-pdf-release
```

The `publish-github` job remains unchanged — it already downloads `main-pdf-release`.

- [ ] **Step 4: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/compile.yml')); yaml.safe_load(open('.github/workflows/build.yml')); yaml.safe_load(open('.github/workflows/release.yml')); print('All valid')"` 

Expected: `All valid`

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/compile.yml .github/workflows/build.yml .github/workflows/release.yml
git commit -m "refactor(ci): extract reusable compile workflow"
```

---

### Task 3: Fix VSCode clean command

**Files:**
- Modify: `.vscode/settings.json`

- [ ] **Step 1: Add outdir to clean args**

In `.vscode/settings.json`, change:

```json
"latex-workshop.latex.clean.args": [
    "-C"
],
```

To:

```json
"latex-workshop.latex.clean.args": [
    "-C",
    "-outdir=%OUTDIR%"
],
```

- [ ] **Step 2: Commit**

```bash
git add .vscode/settings.json
git commit -m "fix(vscode): add outdir to clean command args"
```

---

### Task 4: Fix `*.tfm` gitignore vs tracked fonts

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add negation rule for fonts directory**

In `.gitignore`, find the `*.tfm` line (line 109) and add a negation rule after it:

```gitignore
*.tfm
!fonts/*.tfm
```

- [ ] **Step 2: Verify font files are not ignored**

Run: `git check-ignore -v fonts/t1-formata-regular.tfm; echo "exit: $?"`

Expected: Exit code 1 (not ignored) — the negation rule should override the `*.tfm` pattern. If exit code is 0, the negation isn't working.

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "fix(gitignore): allow fonts/*.tfm through ignore rules"
```

---

### Task 5: Remove redundant `-interaction=nonstopmode` from VSCode tool

**Files:**
- Modify: `.vscode/settings.json`

- [ ] **Step 1: Remove the redundant flag**

In `.vscode/settings.json`, change the latexmk tool args from:

```json
"args": [
    "-synctex=1",
    "-interaction=nonstopmode",
    "-file-line-error",
    "-pdf",
    "-f",
    "%DOCFILE_EXT%"
]
```

To:

```json
"args": [
    "-synctex=1",
    "-file-line-error",
    "-pdf",
    "-f",
    "%DOCFILE_EXT%"
]
```

- [ ] **Step 2: Commit**

```bash
git add .vscode/settings.json
git commit -m "refactor(vscode): remove redundant latexmk flag"
```
