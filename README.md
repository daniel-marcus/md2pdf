Create PDF documents from Markdown text with LaTeX-templates

![](screenshot.png)

## Requirements

[Pandoc](https://pandoc.org) and [LaTeX](https://www.tug.org/texlive/) for text conversion, [fswatch](https://emcrisostomo.github.io/fswatch/) for the watch script.

Installation on macOS (with full MacTex distribution):

```sh
brew install pandoc fswatch && brew install --cask mactex
```

## Usage

```sh
./run/watch.sh
```

This starts the watch script: Any change of `.md` files in the `/in/` folder will trigger recompilation.

Or compile manually:

```sh
./run/compile.sh [FILENAME without .md, e.g. cv.example]
```

Generated files (`.tex` and `.pdf`) will be saved in the `/out/` folder.

## Configuration

Copy `config.example.yaml` to `config.yaml` and edit the variables that are being used in the templates (name, email, websites, ...).

> Note that `*.example.md` files will **always** use `config.example.yaml`.

In your Markdown files, you can extend or overwrite them using a YAML front matter block:

```
---
template: cv          # or "letter" or any other template that you have in your /templates/ folder
link_color: e8a9ff    # hex code for custom link color in this document
---
```

## Extras

Inline code (backtick-enclosed) will be rendered as tags (see [cv.example.pdf](out/cv.example.pdf)). If you add a hash before and you have specified a `tag_base_url` variable, it will also get a link (e.g, `https://yourwebsite.com/portfolio?tag={tag_name}`):

```
  Skills: `HTML` `CSS` `#JavaScript`
```
