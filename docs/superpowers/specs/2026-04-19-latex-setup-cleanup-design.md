# LaTeX Setup Cleanup

Proactive audit and cleanup of the LaTeX build configuration across `.latexmkrc`, CI workflows, VSCode settings, and `.gitignore`.

## Changes

### 1. Remove dead biber config from `.latexmkrc`

Delete the `$biber` line from `.latexmkrc`. The project uses BibTeX (`\usepackage{cite}` + `\bibliography{}`), not biblatex, so this config is dead code.

**File:** `.latexmkrc` line 6
**Action:** Delete `$biber = 'biber --input-directory build --output-directory build %O %S';`

### 2. Deduplicate CI compile steps

`build.yml` and `release.yml` contain identical latex-action compile blocks. Extract into a reusable workflow.

**New file:** `.github/workflows/compile.yml`
- Reusable workflow (`workflow_call`)
- Optional input `artifact-name` (default: `build-pdf`)
- Runs `xu-cheng/latex-action@v3` with: `root_file: main.tex`, `latexmk_use_lualatex: false`, `latexmk_shell_escape: true`, `args: -pdf -f`, `extra_fonts: ./fonts/*`, `post_compile: "cp build/main.pdf main.pdf"`
- Uploads `main.pdf` as artifact with the configured name

**Modified:** `.github/workflows/build.yml`
- Replace inline compile step with `uses: ./.github/workflows/compile.yml`
- Keep the git-describe rename and re-upload steps (download artifact, rename, upload with new name)

**Modified:** `.github/workflows/release.yml`
- Replace inline compile step with `uses: ./.github/workflows/compile.yml` with `artifact-name: main-pdf-release`
- Keep tag/changelog/publish logic unchanged

### 3. Fix VSCode clean command

The clean command uses `latexmk -C` without specifying the output directory, so it won't clean `build/`.

**File:** `.vscode/settings.json`
**Action:** Change `clean.args` from `["-C"]` to `["-C", "-outdir=%OUTDIR%"]`

### 4. Fix `*.tfm` gitignore vs tracked fonts

`.gitignore` has `*.tfm` which matches `fonts/*.tfm`. Add a negation rule so new font files can be added.

**File:** `.gitignore`
**Action:** Add `!fonts/*.tfm` after the `*.tfm` line

### 5. Remove redundant `-interaction=nonstopmode` from VSCode tool

`.latexmkrc` already sets this via `$pdflatex`. Remove the duplicate from the VSCode latexmk tool args.

**File:** `.vscode/settings.json`
**Action:** Remove `-interaction=nonstopmode` from `latex-workshop.latex.tools[0].args`
