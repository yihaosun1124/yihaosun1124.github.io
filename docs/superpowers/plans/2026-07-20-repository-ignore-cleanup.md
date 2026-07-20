# Repository Ignore Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove development-only artifacts from `master`, explicitly ignore local tooling and generated files, and publish only the personal website and its public assets.

**Architecture:** Treat the repository as three boundaries: tracked website and maintenance inputs, ignored local/development artifacts, and generated Jekyll output. Encode the first two boundaries in `.gitignore` and `_config.yml`, verify them with a temporary regression test, then remove `test/` and `docs/` from the final branch while retaining their history in Git.

**Tech Stack:** Git, Jekyll 3.9, Ruby 3.2 in GitHub Actions, Minitest for the temporary regression test, GitHub Pages.

## Global Constraints

- Keep `README.md`, `LICENSE`, `.github/workflows/pages.yml`, `Gemfile`, and `Gemfile.lock` tracked.
- Keep `CNAME`, `CV/`, the favicon, homepage assets, and future `_posts/` content publishable.
- Remove `test/` and `docs/` from the current `master` tree and ignore both root directories.
- Do not ignore PDFs, images, Markdown files, or other public website formats broadly.
- Keep local tool, editor, operating-system, Jekyll, Bundler, temporary, coverage, log, and environment files out of Git.
- Preserve the centered footer and restored `peep.png` favicon.

---

### Task 1: Encode the repository and publication boundaries

**Files:**
- Create: `test/repository_hygiene_test.rb`
- Modify: `.gitignore`
- Modify: `_config.yml`

**Interfaces:**
- Consumes: The tracked-file boundary and ignore policy from `docs/superpowers/specs/2026-07-20-repository-ignore-cleanup-design.md`.
- Produces: Root ignore rules consumed by Git and an `exclude` list consumed by Jekyll.

- [ ] **Step 1: Write the failing boundary test**

Create `test/repository_hygiene_test.rb` with:

```ruby
# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class RepositoryHygieneTest < Minitest::Test
  def test_gitignore_covers_local_and_development_artifacts
    ignore_lines = File.readlines(File.join(ROOT, ".gitignore"), chomp: true)
    expected_rules = %w[
      /.claude/
      /.codex/
      /.superpowers/
      /.idea/
      /.vscode/
      /.worktrees/
      /.ruby-lsp/
      .DS_Store
      Thumbs.db
      *.swp
      *.swo
      *~
      /.env
      /.env.*
      !/.env.example
      /_site/
      /.jekyll-cache/
      /.jekyll-metadata
      /.sass-cache/
      /.bundle/
      /vendor/
      /tmp/
      /coverage/
      *.log
      /docs/
      /test/
    ]

    expected_rules.each do |rule|
      assert_includes ignore_lines, rule
    end
  end

  def test_jekyll_excludes_repository_only_files
    config = YAML.safe_load(File.read(File.join(ROOT, "_config.yml")))
    expected_exclusions = %w[docs test Gemfile Gemfile.lock README.md LICENSE tmp vendor]

    expected_exclusions.each do |path|
      assert_includes config.fetch("exclude"), path
    end
  end
end
```

- [ ] **Step 2: Run the boundary test and verify RED**

Run:

```bash
ruby -Itest test/repository_hygiene_test.rb
```

Expected: FAIL because `.gitignore` lacks the new explicit rules and `_config.yml` does not exclude `LICENSE`.

- [ ] **Step 3: Implement the ignore rules and Jekyll exclusion**

Replace `.gitignore` with:

```gitignore
# Operating-system metadata
.DS_Store
Thumbs.db

# Editors and local agents
/.claude/
/.codex/
/.superpowers/
/.idea/
/.vscode/
/.worktrees/
/.ruby-lsp/
*.swp
*.swo
*~

# Local environment files
/.env
/.env.*
!/.env.example

# Jekyll and Sass output
/_site/
/.jekyll-cache/
/.jekyll-metadata
/.sass-cache/

# Ruby, dependency, and generated output
/.bundle/
/vendor/
/tmp/
/coverage/
*.log

# Development-only repository content
/docs/
/test/
```

Add `LICENSE` to the `_config.yml` `exclude` list so it reads:

```yaml
exclude:
  - docs
  - test
  - Gemfile
  - Gemfile.lock
  - README.md
  - LICENSE
  - tmp
  - vendor
```

- [ ] **Step 4: Run the boundary test and current regression suite**

Run:

```bash
ruby -Itest test/repository_hygiene_test.rb
for test_file in test/*_test.rb; do ruby -Itest "$test_file" || exit 1; done
```

Expected: all tests pass, including the favicon and footer regressions.

- [ ] **Step 5: Commit the boundary rules**

```bash
git add .gitignore _config.yml
git add -f test/repository_hygiene_test.rb
git commit -m "chore: tighten repository ignore rules"
```

### Task 2: Remove development-only tracked content

**Files:**
- Delete: `test/`
- Delete: `docs/`

**Interfaces:**
- Consumes: The `/test/` and `/docs/` rules added by Task 1.
- Produces: A current `master` tree containing only website, deployment, README, and license inputs.

- [ ] **Step 1: Verify the removal targets are exactly tracked development artifacts**

Run:

```bash
git ls-files docs test
```

Expected: only the planning/specification Markdown files under `docs/` and Minitest files under `test/` are listed.

- [ ] **Step 2: Remove the confirmed targets from the current tree**

Run:

```bash
git rm -r docs test
```

Expected: Git stages deletion of only `docs/` and `test/`. The committed history remains recoverable.

- [ ] **Step 3: Verify ignore behavior and tracked-file boundaries**

Run:

```bash
for ignored_path in \
  .claude/settings.local.json \
  .codex/settings.json \
  .superpowers/sdd/progress.md \
  .idea/workspace.xml \
  .vscode/settings.json \
  .ruby-lsp/state.json \
  _site/index.html \
  .jekyll-cache/cache \
  .sass-cache/cache \
  .bundle/config \
  vendor/bundle/example \
  tmp/example \
  coverage/index.html \
  debug.log \
  docs/example.md \
  test/example_test.rb \
  .env.local; do
  git check-ignore --no-index -q "$ignored_path" || exit 1
done

if git check-ignore --no-index -q .env.example; then
  exit 1
fi

test -z "$(git ls-files docs test)"
```

Expected: every development/local path is ignored, `.env.example` remains committable, and no `docs/` or `test/` file remains tracked.

- [ ] **Step 4: Build the site from the cleaned tree**

Run with the repository's configured local Bundler toolchain:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
```

Expected: Jekyll exits with status 0 and writes `_site/`.

- [ ] **Step 5: Verify the generated-site boundary and prior homepage fixes**

Run:

```bash
test -f _site/index.html
test -f _site/CNAME
test -f _site/CV/yihaosun_cv.pdf
test -f _site/assets/img/peep.png
test ! -e _site/README.md
test ! -e _site/LICENSE
test ! -e _site/docs
test ! -e _site/test
test ! -e _site/.claude
test ! -e _site/tmp
test ! -e _site/vendor
rg -q '<link rel="icon" type="image/png" href="/assets/img/peep.png">' _site/index.html
rg -q 'class="site-footer"' _site/index.html
rg -q 'justify-content: center' _site/assets/css/style.css
```

Expected: all assertions exit with status 0.

- [ ] **Step 6: Commit the development-artifact removal**

```bash
git diff --cached --check
git commit -m "chore: remove non-site development artifacts"
```

### Task 3: Publish and verify the cleaned repository

**Files:**
- No source-file changes.

**Interfaces:**
- Consumes: The cleaned `master` tree and `.github/workflows/pages.yml`.
- Produces: A successful `gh-pages` deployment at `https://www.yihaosun.cn/`.

- [ ] **Step 1: Review the final tree and commit sequence**

Run:

```bash
git status --short --branch
git ls-files | sort
git log -4 --oneline
git diff origin/master...HEAD --check
```

Expected: the tree is clean, `test/` and `docs/` are absent, and the commits show the approved design, ignore-boundary change, and artifact removal.

- [ ] **Step 2: Push `master`**

Run:

```bash
git push origin master
```

Expected: `origin/master` advances to the cleanup commit.

- [ ] **Step 3: Wait for the matching GitHub Pages workflow**

Run:

```bash
cleanup_head_sha=$(git rev-parse HEAD)
for cleanup_attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
  cleanup_run_json=$(curl -sS -H 'Accept: application/vnd.github+json' \
    'https://api.github.com/repos/yihaosun1124/yihaosun1124.github.io/actions/workflows/pages.yml/runs?branch=master&per_page=10')
  cleanup_run_state=$(printf '%s' "$cleanup_run_json" | ruby -rjson -e '
    data = JSON.parse(STDIN.read)
    target = data.fetch("workflow_runs", []).find { |run| run["head_sha"] == ARGV.fetch(0) }
    print target ? [target["status"], target["conclusion"]].compact.join(" ") : "pending"
  ' "$cleanup_head_sha")
  printf '%s\n' "$cleanup_run_state"
  if [[ "$cleanup_run_state" == "completed success" ]]; then
    break
  fi
  sleep 5
done
test "$cleanup_run_state" = "completed success"
```

Expected: the matching workflow reaches `completed success`.

- [ ] **Step 4: Verify the live site and restored UI details**

Run:

```bash
cleanup_live_html=$(curl -sS -H 'Cache-Control: no-cache' \
  "https://www.yihaosun.cn/?deploy=$cleanup_head_sha")
cleanup_live_css=$(curl -sS -H 'Cache-Control: no-cache' \
  "https://www.yihaosun.cn/assets/css/style.css?deploy=$cleanup_head_sha")

printf '%s' "$cleanup_live_html" | rg -q '<link rel="icon" type="image/png" href="/assets/img/peep.png">'
printf '%s' "$cleanup_live_html" | rg -q 'Website template from <a href="https://github.com/leonidk/leonidk.github.io">here</a>'
printf '%s' "$cleanup_live_css" | rg -q 'justify-content: center'
test "$(curl -sS -o /dev/null -w '%{http_code}' \
  "https://www.yihaosun.cn/assets/img/peep.png?deploy=$cleanup_head_sha")" = "200"
git status --short --branch
```

Expected: all live assertions pass and local `master` matches `origin/master`.
