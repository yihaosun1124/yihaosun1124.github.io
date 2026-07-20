# Repository Ignore Cleanup Design

## Goal

Keep `master` focused on the personal website and the files required to document, build, and deploy it. Remove development-only test and planning artifacts from the current tree, prevent local tool output from being committed, and keep non-site repository metadata out of the generated website.

## Repository boundary

The following files remain tracked because they are part of the website or its maintenance path:

- Jekyll content and templates: `_config.yml`, `_data/`, `_includes/`, `_layouts/`, `_posts/`, `assets/`, and `index.html`.
- Public files: `CNAME` and `CV/`.
- Build and deployment files: `.github/workflows/pages.yml`, `Gemfile`, and `Gemfile.lock`.
- Repository documentation and licensing: `README.md` and `LICENSE`.

The current `test/` and `docs/` trees will be removed from `master` and ignored. Their prior contents, including this reviewed design, remain recoverable from Git history and the `legacy` branch where applicable.

## Ignore policy

The root `.gitignore` will use grouped, root-anchored rules where appropriate:

- Local agents and editors: `/.claude/`, `/.codex/`, `/.superpowers/`, `/.idea/`, `/.vscode/`, and `/.worktrees/`.
- Operating-system and editor noise: `.DS_Store`, `Thumbs.db`, Vim swap files, and editor backup files.
- Jekyll and Sass output: `/_site/`, `/.jekyll-cache/`, `/.jekyll-metadata`, and `/.sass-cache/`.
- Ruby/Bundler and temporary output: `/.bundle/`, `/vendor/`, `/tmp/`, `/coverage/`, and log files.
- Local environment configuration: `.env` and `.env.*`, while allowing a future `.env.example` to be committed.
- Development-only repository trees: `/test/` and `/docs/`.

No broad rule will ignore PDFs, images, Markdown files, or other formats used by the public website.

## Published-site boundary

Jekyll's `exclude` list will continue to exclude build inputs and repository documentation. `LICENSE` will be added so it remains tracked for legal clarity without being copied into `_site`. The published site must continue to contain `CNAME`, the CV, homepage assets, and future blog posts.

## Verification

Implementation is complete when:

1. `test/` and `docs/` are absent from the current `master` tree and covered by `.gitignore`.
2. Representative local-tool, editor, cache, log, and environment files are reported as ignored.
3. The Jekyll build succeeds.
4. `_site` contains the homepage, `CNAME`, CV, favicon, and site assets, but not README, LICENSE, tests, docs, local configuration, or build caches.
5. The favicon and centered footer remain present in the rendered homepage.
6. The cleanup commit is pushed and the GitHub Pages workflow succeeds.
