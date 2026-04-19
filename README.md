# Scientific Paper Latex Template
[![Build](https://github.com/iwishiwasaneagle/LatexPaperTemplate/actions/workflows/build.yml/badge.svg)](https://github.com/iwishiwasaneagle/LatexPaperTemplate/actions/workflows/build.yml)
[![Create release](https://github.com/iwishiwasaneagle/LatexPaperTemplate/actions/workflows/release.yml/badge.svg)](https://github.com/iwishiwasaneagle/LatexPaperTemplate/actions/workflows/release.yml)


A nice GitHub template for my reports and papers.

## Features

- Automatically builds the package on push to `main`
  - Prevents pushes from breaking the compilation
- Create a new release at midnight if there is new content
  - This includes a changelog, and a compiled PDF
- Some packages that I found useful
- A file structure that makes sense

## Installation

This template is designed to work with [latex-workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) in VSCode. The included `.vscode/settings.json` configures a single `latexmk` recipe that handles the full build (including `biber` and `makeindex`) automatically.

To build locally:

```sh
latexmk -pdf -f main.tex
```

Output files go to `build/` via the `.latexmkrc` configuration.

## Other Templates

- [LatexResponseToReviewersTemplate](https://github.com/iwishiwasaneagle/LatexResponseToReviewersTemplate)
