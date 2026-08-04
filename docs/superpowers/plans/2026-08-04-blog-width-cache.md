# Blog Width and Cache Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Widen desktop blog posts to `1040px` and add build-version queries so newly deployed CSS and homepage blog links do not reuse stale cached responses.

**Architecture:** Keep the existing Jekyll layout/include structure and working MathJax/H1 rules. Generate the same build version independently from `site.time` in the default layout and Blog include, append it only to generated request URLs, and leave canonical URLs unchanged. Use one ignored temporary Minitest contract for source and rendered-output coverage.

**Tech Stack:** Jekyll 3.10, Liquid, SCSS, Kramdown, Minitest, MathJax 4, GitHub Actions/GitHub Pages.

## Global Constraints

- Desktop `.post` maximum width must be exactly `1040px`.
- Homepage `.site-shell` maximum width remains exactly `1040px`.
- Mobile layout and padding remain unchanged and must not create page-level horizontal overflow.
- The post title and date remain centered; Markdown H1 headings inside `.post-content` remain left-aligned.
- The current conditional MathJax 4 loader and `$...$` / standalone `$$...$$` authoring contract remain unchanged.
- The stylesheet URL and homepage-generated post URLs receive the same numeric build-version query.
- Canonical post URLs remain clean and unversioned.
- No service worker, forced reload, custom cache header, MathJax replacement, typography change, or content change is introduced.
- The final tracked tree must not retain planning documents or temporary tests.

---

### Task 1: Version generated URLs and widen the blog

**Files:**
- Create temporarily: `tmp/blog_width_cache_test.rb`
- Modify: `_layouts/default.html`
- Modify: `_includes/blog.html`
- Modify: `assets/css/style.scss`

**Interfaces:**
- Consumes: Jekyll's build-wide `site.time`, the existing `post.url`, and the existing `.post`, `.post-header`, and `.post-content h1` selectors.
- Produces: Numeric `?v=<timestamp>` request URLs in rendered HTML and a `1040px` desktop post boundary.

- [ ] **Step 1: Write the failing source and rendered-output contract**

Create `tmp/blog_width_cache_test.rb` with:

```ruby
# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__)

class BlogWidthCacheTest < Minitest::Test
  def setup
    @layout = File.read(File.join(ROOT, "_layouts/default.html"))
    @blog_include = File.read(File.join(ROOT, "_includes/blog.html"))
    @style = File.read(File.join(ROOT, "assets/css/style.scss"))
    @home = File.read(File.join(ROOT, "_site/index.html"))
    @post = File.read(File.join(ROOT, "_site/blog/2026/07/31/wm/index.html"))
  end

  def test_post_uses_homepage_width
    assert_match(/\.site-shell\s*\{[^}]*max-width:\s*1040px;/m, @style)
    assert_match(/\.post\s*\{[^}]*max-width:\s*1040px;/m, @style)
  end

  def test_source_generates_build_versions
    assignment = 'assign cache_version = site.time | date: "%s"'

    assert_includes @layout, assignment
    assert_includes @blog_include, assignment
    assert_includes @layout, '?v={{ cache_version }}'
    assert_includes @blog_include, '?v={{ cache_version }}'
  end

  def test_rendered_urls_share_one_numeric_version
    home_css = @home.match(%r{/assets/css/style\.css\?v=(\d+)})
    home_post = @home.match(%r{/blog/2026/07/31/wm/\?v=(\d+)})
    post_css = @post.match(%r{/assets/css/style\.css\?v=(\d+)})

    refute_nil home_css
    refute_nil home_post
    refute_nil post_css
    assert_equal home_css[1], home_post[1]
    assert_equal home_css[1], post_css[1]
  end

  def test_existing_formula_and_heading_contract_remains
    assert_includes @post, "mathjax@4/tex-chtml.js"
    assert_includes @post, '$\\pi_E$'
    assert_match(/\.post-header\s*\{[^}]*text-align:\s*center;/m, @style)
    assert_match(/\.post-content\s+h1\s*\{[^}]*text-align:\s*left;/m, @style)
    assert_includes @post, '<link rel="canonical" href="https://www.yihaosun.cn/blog/2026/07/31/wm/">'
  end
end
```

- [ ] **Step 2: Build and run the contract to verify RED**

Run:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
ruby -Itest tmp/blog_width_cache_test.rb
```

Expected: the contract fails because `.post` is `900px` and the generated stylesheet/post URLs have no version queries. Existing MathJax, canonical, and heading assertions pass.

- [ ] **Step 3: Add one build version to the default layout**

Insert this as the first line of `_layouts/default.html`:

```liquid
{%- assign cache_version = site.time | date: "%s" -%}
```

Change the site stylesheet link to:

```liquid
    <link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}?v={{ cache_version }}">
```

Do not change the MathJax conditional or canonical link.

- [ ] **Step 4: Version homepage-generated blog links**

Insert this as the first line of `_includes/blog.html`:

```liquid
{%- assign cache_version = site.time | date: "%s" -%}
```

Change the post link inside the existing loop to:

```liquid
<a href="{{ post.url | relative_url }}?v={{ cache_version }}">{{ post.title }}</a>
```

Keep the post title, date, loop order, and clean `post.url` source unchanged.

- [ ] **Step 5: Widen the desktop post**

Change only the `.post` rule in `assets/css/style.scss`:

```scss
.post {
  max-width: 1040px;
  margin: 0 auto;
}
```

Do not change `.site-shell`, `.post-header`, `.post-content h1`, MathJax overflow styles, or the mobile media query.

- [ ] **Step 6: Rebuild and run the contract to verify GREEN**

Run:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll clean
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
ruby -Itest tmp/blog_width_cache_test.rb
git diff --check
```

Expected: clean Jekyll build and 4 Minitest runs with no failures or errors.

- [ ] **Step 7: Commit the production change**

```bash
git add _layouts/default.html _includes/blog.html assets/css/style.scss
git diff --cached --check
git commit -m "fix: refresh blog layout assets after deploy"
```

Do not force-add `tmp/blog_width_cache_test.rb`; it remains ignored until final cleanup.

### Task 2: Browser verification, cleanup, and deployment

**Files:**
- Delete: `docs/superpowers/specs/2026-08-04-blog-width-cache-design.md`
- Delete: `docs/superpowers/plans/2026-08-04-blog-width-cache.md`
- Delete locally: `tmp/blog_width_cache_test.rb`

**Interfaces:**
- Consumes: The Jekyll build from Task 1 and the existing Pages workflow.
- Produces: A clean `master` tree and a verified deployment at `https://www.yihaosun.cn/`.

- [ ] **Step 1: Run a fresh pre-browser verification**

Run:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" check
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll clean
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
ruby -Itest tmp/blog_width_cache_test.rb
git diff --check
```

Expected: dependency check, clean build, contract, and whitespace check exit 0.

- [ ] **Step 2: Verify desktop and mobile behavior in a real browser**

Serve the site on `127.0.0.1:4105` with no watch. Using the in-app browser:

1. At `1440×1000`, confirm `.post` computed width and max-width are `1040px`.
2. Confirm the stylesheet request contains a numeric `?v=` query and the homepage Blog link contains the same query.
3. On the post, confirm `.post-header h1` and `.post-date` are centered while every `.post-content h1` is left-aligned.
4. Confirm MathJax produces inline containers and exactly one display container without console errors.
5. At `390×844`, confirm `document.documentElement.scrollWidth <= innerWidth` and the MathJax display container retains `overflow-x: auto`.
6. Reset the temporary viewport override and finalize browser tabs.

Expected: all computed-style, version-query, MathJax, and overflow checks pass.

- [ ] **Step 3: Remove temporary and planning artifacts**

Use `apply_patch` to delete the two tracked planning documents and the ignored temporary contract file. Then run:

```bash
git add -u
git diff --cached --check
git commit -m "chore: remove blog update planning artifacts"
```

Expected: planning files are deleted from the tracked tree and the ignored test file is absent.

- [ ] **Step 4: Run final source/rendered checks and push**

Run a fresh Jekyll clean/build, then execute this non-persistent final contract:

```bash
ruby <<'RUBY'
style = File.read("assets/css/style.scss")
layout = File.read("_layouts/default.html")
blog_include = File.read("_includes/blog.html")
home = File.read("_site/index.html")
post = File.read("_site/blog/2026/07/31/wm/index.html")

home_css = home.match(%r{/assets/css/style\.css\?v=(\d+)})
home_post = home.match(%r{/blog/2026/07/31/wm/\?v=(\d+)})
post_css = post.match(%r{/assets/css/style\.css\?v=(\d+)})

checks = {
  "post width" => style.match?(/\.post\s*\{[^}]*max-width:\s*1040px;/m),
  "heading alignment" => style.match?(/\.post-content\s+h1\s*\{[^}]*text-align:\s*left;/m),
  "layout version source" => layout.include?('?v={{ cache_version }}'),
  "post-link version source" => blog_include.include?('?v={{ cache_version }}'),
  "rendered versions" => home_css && home_post && post_css,
  "shared version" => home_css && home_post && post_css && home_css[1] == home_post[1] && home_css[1] == post_css[1],
  "MathJax loader" => post.include?("mathjax@4/tex-chtml.js"),
  "inline TeX" => post.include?('$\\pi_E$'),
  "display TeX" => post.include?('\\[\\begin{aligned}'),
  "clean canonical" => post.include?('<link rel="canonical" href="https://www.yihaosun.cn/blog/2026/07/31/wm/">')
}

failures = checks.reject { |_name, passed| passed }.keys
abort "Final contract failures: #{failures.join(', ')}" unless failures.empty?
puts "Final contract checks: #{checks.length}/#{checks.length} passed"
RUBY
```

Then verify and push:

```bash
git diff --check
test -z "$(git ls-files docs test)"
test -z "$(git status --porcelain)"
git fetch origin master
test "$(git rev-list --left-only --count origin/master...master)" = "0"
git push origin master
```

The inline final contract must assert the same 4 behaviors from Task 1 without recreating a tracked or ignored test file. Expected: clean repository, remote has not diverged, and `master` pushes normally without force.

- [ ] **Step 5: Verify the matching Pages deployment and live site**

Wait for the `Publish GitHub Pages` workflow whose `head_sha` equals `git rev-parse HEAD` to complete successfully. Then request the live homepage, versioned post URL, and versioned CSS URL with unique no-cache query values and verify:

- all responses return HTTP 200;
- homepage stylesheet and Blog link contain numeric version queries with the same value;
- the live CSS has `.post { max-width: 1040px; }` and `.post-content h1 { text-align: left; }`;
- the live post contains the conditional MathJax loader, surviving inline/display TeX, and a clean canonical URL;
- `git rev-parse HEAD` equals `git rev-parse origin/master` and the worktree is clean.

Expected: Pages workflow succeeds and all live checks pass after any GitHub edge-cache propagation delay.
