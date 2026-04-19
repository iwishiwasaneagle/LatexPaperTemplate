# CLAUDE.md

## Build

Use `latexmk` to build, not `pdflatex` directly:

```sh
latexmk -pdf -f $PWD/main.tex
```

The `-f` flag is needed to force completion past non-critical warnings (e.g. overfull hboxes).

Output files (PDF, aux, log, etc.) go to `build/` via `$out_dir` in `.latexmkrc`. The built PDF is at `build/main.pdf`.

LaTeX runs inside a Docker container via the wrapper at `/opt/latex/core.sh`. Always use `$PWD/main.tex` (absolute path) when invoking.
