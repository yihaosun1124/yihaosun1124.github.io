# Blog Author Byline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render a centered `By Yihao Sun` line between every blog post title and date, with per-post author metadata and a site-name fallback.

**Architecture:** Extend the existing post front matter/layout contract instead of introducing a separate author data system. The layout reads `page.author | default: site.name`, the current post demonstrates the `author` field, and one small SCSS rule controls byline spacing. Preserve the user's current uncommitted blog-body edits by changing only front matter and staging only that front-matter hunk from the post file.

**Tech Stack:** Jekyll 3.10, Liquid, YAML front matter, SCSS, Kramdown, Minitest, GitHub Actions/GitHub Pages.

## Global Constraints

- The post header order must be title → `By <author>` → publication date.
- Title, byline, and date remain centered through `.post-header`.
- The byline uses normal text color; the date remains muted.
- `page.author` overrides the global author, and missing `page.author` falls back to `_config.yml` `site.name`.
- The current post explicitly declares `author: Yihao Sun`.
- The current post body after YAML front matter must retain SHA-256 `54cc49a95e2e5a655e95da3a60dd7b485a836b02da481b7761fe442eaa856d85` and byte length `23665`.
- The user's existing uncommitted blog-body edits must remain unstaged and uncommitted.
- Existing title, date, Markdown heading alignment, MathJax rendering, `1040px` post width, cache-version URLs, canonical URL, homepage order, and mobile behavior remain unchanged.
- README blog instructions document `author` and the `site.name` fallback.
- The final tracked tree must not retain planning documents or temporary tests.

---

### Task 1: Render and style the author byline

**Files:**
- Create temporarily: `tmp/blog_author_test.rb`
- Modify: `_layouts/post.html`
- Modify: `_posts/2026-07-31-wm.md` front matter only
- Modify: `assets/css/style.scss`
- Modify: `README.md`

**Interfaces:**
- Consumes: `page.author` from post front matter and `site.name` from `_config.yml`.
- Produces: `<p class="post-author">By …</p>` between the post title and date.

- [ ] **Step 1: Write the failing rendered-output contract**

Create `tmp/blog_author_test.rb` with:

```ruby
# frozen_string_literal: true

require "digest"
require "minitest/autorun"

ROOT = File.expand_path("..", __dir__)
EXPECTED_BODY_SHA256 = "54cc49a95e2e5a655e95da3a60dd7b485a836b02da481b7761fe442eaa856d85"
EXPECTED_BODY_BYTES = 23_665

class BlogAuthorTest < Minitest::Test
  def setup
    @source = File.read(File.join(ROOT, "_posts/2026-07-31-wm.md"))
    @style = File.read(File.join(ROOT, "_site/assets/css/style.css"))
    @post = File.read(File.join(ROOT, "_site/blog/2026/07/31/wm/index.html"))
  end

  def test_title_author_and_date_render_in_order
    title = '<h1>Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents</h1>'
    author = '<p class="post-author">By Yihao Sun</p>'
    date = '<p class="post-date">July 31, 2026</p>'

    title_position = @post.index(title)
    author_position = @post.index(author)
    date_position = @post.index(date)

    refute_nil title_position
    refute_nil author_position
    refute_nil date_position
    assert title_position < author_position
    assert author_position < date_position
  end

  def test_byline_style_preserves_header_alignment
    assert_match(/\.post-header\s*\{[^}]*text-align:\s*center;/m, @style)
    assert_match(/\.post-author\s*\{[^}]*margin-bottom:\s*0\.25rem;[^}]*color:\s*var\(--text\);/m, @style)
    assert_match(/\.post-list time,\s*\.post-date\s*\{[^}]*color:\s*var\(--muted\);/m, @style)
    assert_match(/\.post-content\s+h1\s*\{[^}]*text-align:\s*left;/m, @style)
  end

  def test_post_body_and_existing_rendering_remain_intact
    parts = @source.split(/^---\s*$\n/, 3)
    assert_equal 3, parts.length
    assert_equal EXPECTED_BODY_SHA256, Digest::SHA256.hexdigest(parts[2])
    assert_equal EXPECTED_BODY_BYTES, parts[2].bytesize
    assert_match(/\.post\s*\{[^}]*max-width:\s*1040px;/m, @style)
    assert_includes @post, "mathjax@4/tex-chtml.js"
    assert_includes @post, '$\\pi_E$'
    assert_includes @post, '\\[\\begin{aligned}'
    assert_includes @post, '<link rel="canonical" href="https://www.yihaosun.cn/blog/2026/07/31/wm/">'
  end
end
```

The test catches these regressions: missing/misordered byline, changed byline styling, overwritten user body edits, lost MathJax delimiters, changed post width, or changed canonical URL.

- [ ] **Step 2: Build and run the contract to verify RED**

Run:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
ruby -Itest tmp/blog_author_test.rb
```

Expected: the title/author/date test and `.post-author` style test fail because no byline exists. The body hash, MathJax, post width, canonical, date-color, header-alignment, and content-H1 assertions pass.

- [ ] **Step 3: Add the author to the post layout**

In `_layouts/post.html`, change the header to exactly:

```liquid
  <header class="post-header">
    <h1>{{ page.title }}</h1>
    <p class="post-author">By {{ page.author | default: site.name }}</p>
    <p class="post-date">{{ page.date | date: "%B %-d, %Y" }}</p>
  </header>
```

Do not change the back link or `.post-content` wrapper.

- [ ] **Step 4: Add only author metadata to the current post**

Use `apply_patch` to add one line inside `_posts/2026-07-31-wm.md` front matter:

```yaml
---
layout: post
title: "Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents"
math: true
author: Yihao Sun
---
```

Do not edit any content after the second `---`. Immediately verify:

```bash
ruby -rdigest -e 'text=File.read("_posts/2026-07-31-wm.md"); parts=text.split(/^---\s*$\n/, 3); abort unless parts.length == 3; abort unless Digest::SHA256.hexdigest(parts[2]) == "54cc49a95e2e5a655e95da3a60dd7b485a836b02da481b7761fe442eaa856d85"; abort unless parts[2].bytesize == 23665; puts "Post body preserved"'
```

Expected: `Post body preserved`.

- [ ] **Step 5: Style the byline**

Add immediately after `.post-header` in `assets/css/style.scss`:

```scss
.post-author {
  margin-bottom: 0.25rem;
  color: var(--text);
}
```

Do not add a link style or change `.post-date`.

- [ ] **Step 6: Document author editing**

Change the README example to:

```yaml
---
layout: post
title: Your Post Title
author: Your Name
---
```

Immediately after that code block add:

```markdown
The `author` field controls the `By ...` line below the post title. If it is omitted, the site uses the `name` value in `_config.yml`.
```

- [ ] **Step 7: Rebuild and run the contract to verify GREEN**

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
ruby -Itest tmp/blog_author_test.rb
git diff --check
```

Expected: clean Jekyll build and 3 Minitest runs with no failures or errors.

### Task 2: Commit only task-scoped changes

**Files:**
- Stage normally: `_layouts/post.html`
- Stage normally: `assets/css/style.scss`
- Stage normally: `README.md`
- Stage partially: `_posts/2026-07-31-wm.md` author front-matter line only

**Interfaces:**
- Consumes: Green Task 1 implementation plus the user's pre-existing body edits.
- Produces: One production commit that excludes the user's body edits.

- [ ] **Step 1: Stage the clean files**

```bash
git add _layouts/post.html assets/css/style.scss README.md
```

- [ ] **Step 2: Stage only the author line from the dirty post**

Apply this exact index-only patch; it does not rewrite the working file:

```bash
git apply --cached <<'PATCH'
diff --git a/_posts/2026-07-31-wm.md b/_posts/2026-07-31-wm.md
--- a/_posts/2026-07-31-wm.md
+++ b/_posts/2026-07-31-wm.md
@@ -2,4 +2,5 @@
 layout: post
 title: "Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents"
 math: true
+author: Yihao Sun
 ---
PATCH
```

- [ ] **Step 3: Audit the index before committing**

Run:

```bash
git diff --cached --check
git diff --cached --name-only
git diff --cached -- _posts/2026-07-31-wm.md
git diff -- _posts/2026-07-31-wm.md
```

Expected:

- cached names are exactly `_layouts/post.html`, `_posts/2026-07-31-wm.md`, `README.md`, and `assets/css/style.scss`;
- cached post diff contains only `+author: Yihao Sun`;
- unstaged post diff still contains the user's heading-number edits and does not contain the author line;
- body hash and byte length remain the values in Global Constraints.

- [ ] **Step 4: Commit the production change**

```bash
git commit -m "feat: add author byline to blog posts"
```

Expected: the commit contains only task-scoped changes; `_posts/2026-07-31-wm.md` remains modified in the worktree because the user's body edits are preserved.

### Task 3: Browser verification, cleanup, and deployment

**Files:**
- Delete: `docs/superpowers/specs/2026-08-04-blog-author-byline-design.md`
- Delete: `docs/superpowers/plans/2026-08-04-blog-author-byline.md`
- Delete locally: `tmp/blog_author_test.rb`

**Interfaces:**
- Consumes: The committed byline implementation and the existing Pages workflow.
- Produces: A verified `master` deployment while leaving the user's pre-existing body edits local and uncommitted.

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
ruby -Itest tmp/blog_author_test.rb
ruby -rdigest -e 'text=File.read("_posts/2026-07-31-wm.md"); parts=text.split(/^---\s*$\n/, 3); abort unless parts.length == 3; abort unless Digest::SHA256.hexdigest(parts[2]) == "54cc49a95e2e5a655e95da3a60dd7b485a836b02da481b7761fe442eaa856d85"; abort unless parts[2].bytesize == 23665; puts "Post body preserved"'
git diff --check
test "$(git status --porcelain)" = " M _posts/2026-07-31-wm.md"
```

Expected: all commands exit 0 and the only unstaged path is `_posts/2026-07-31-wm.md`.

- [ ] **Step 2: Verify desktop and mobile behavior in a real browser**

Serve the site on `127.0.0.1:4106` with no watch. Using the in-app browser:

1. At `1440×1000`, verify the post header text sequence is title → `By Yihao Sun` → `July 31, 2026`.
2. Verify title, `.post-author`, and `.post-date` compute to centered alignment, while every `.post-content h1` computes to left alignment.
3. Confirm `.post-author` uses the normal text color, MathJax produces inline containers and one display container, `.post` keeps `max-width: 1040px`, and there are no console errors.
4. At `390×844`, verify the same alignment and `document.documentElement.scrollWidth <= innerWidth`.
5. Reset the temporary viewport override and finalize browser tabs.

Expected: author placement, styling, formulas, heading alignment, width, and mobile overflow checks pass.

- [ ] **Step 3: Remove temporary and planning artifacts**

Use `apply_patch` to delete the two tracked planning documents and `tmp/blog_author_test.rb`. Stage only the tracked planning deletions:

```bash
git add -u -- docs/superpowers
git diff --cached --check
git diff --cached --name-only
git commit -m "chore: remove author byline planning artifacts"
```

Expected: the staged names are exactly the two planning files; the user's post body edits remain unstaged.

- [ ] **Step 4: Run final verification and push**

Run a fresh Jekyll clean/build, then execute this non-persistent contract:

```bash
ruby <<'RUBY'
require "digest"

source = File.read("_posts/2026-07-31-wm.md")
style = File.read("_site/assets/css/style.css")
home = File.read("_site/index.html")
post = File.read("_site/blog/2026/07/31/wm/index.html")

title = '<h1>Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents</h1>'
author = '<p class="post-author">By Yihao Sun</p>'
date = '<p class="post-date">July 31, 2026</p>'
title_position = post.index(title)
author_position = post.index(author)
date_position = post.index(date)
parts = source.split(/^---\s*$\n/, 3)
home_css = home.match(%r{/assets/css/style\.css\?v=(\d+)})
home_post = home.match(%r{/blog/2026/07/31/wm/\?v=(\d+)})
post_css = post.match(%r{/assets/css/style\.css\?v=(\d+)})

checks = {
  "header nodes" => title_position && author_position && date_position,
  "header order" => title_position && author_position && date_position && title_position < author_position && author_position < date_position,
  "centered header" => style.match?(/\.post-header\s*\{[^}]*text-align:\s*center;/m),
  "author style" => style.match?(/\.post-author\s*\{[^}]*margin-bottom:\s*0\.25rem;[^}]*color:\s*var\(--text\);/m),
  "muted date" => style.match?(/\.post-list time,\s*\.post-date\s*\{[^}]*color:\s*var\(--muted\);/m),
  "left content H1" => style.match?(/\.post-content\s+h1\s*\{[^}]*text-align:\s*left;/m),
  "body hash" => parts.length == 3 && Digest::SHA256.hexdigest(parts[2]) == "54cc49a95e2e5a655e95da3a60dd7b485a836b02da481b7761fe442eaa856d85",
  "body bytes" => parts.length == 3 && parts[2].bytesize == 23_665,
  "post width" => style.match?(/\.post\s*\{[^}]*max-width:\s*1040px;/m),
  "MathJax" => post.include?("mathjax@4/tex-chtml.js"),
  "inline TeX" => post.include?('$\\pi_E$'),
  "display TeX" => post.include?('\\[\\begin{aligned}'),
  "clean canonical" => post.include?('<link rel="canonical" href="https://www.yihaosun.cn/blog/2026/07/31/wm/">'),
  "versioned URLs" => home_css && home_post && post_css,
  "shared version" => home_css && home_post && post_css && home_css[1] == home_post[1] && home_css[1] == post_css[1]
}

failures = checks.reject { |_name, passed| passed }.keys
abort "Final contract failures: #{failures.join(', ')}" unless failures.empty?
puts "Final contract checks: #{checks.length}/#{checks.length} passed"
RUBY
```

Then verify:

```bash
git diff --check
git diff --cached --quiet
test -z "$(git ls-files docs test)"
test "$(git status --porcelain)" = " M _posts/2026-07-31-wm.md"
git fetch origin master
test "$(git rev-list --left-only --count origin/master...master)" = "0"
git push origin master
```

Expected: all contracts pass, only the preserved user body edit remains unstaged, remote has not diverged, and `master` pushes without force.

- [ ] **Step 5: Verify the matching Pages deployment and live site**

Wait for the `Publish GitHub Pages` workflow whose `head_sha` equals `git rev-parse HEAD` to complete successfully. Follow the versioned Blog URL generated by the live homepage and verify:

- HTTP responses return 200;
- the live header contains title → `By Yihao Sun` → date;
- live CSS contains `.post-author`, centered `.post-header`, muted `.post-date`, left-aligned `.post-content h1`, and `1040px` `.post`;
- the post still contains MathJax, surviving inline/display TeX, and the clean canonical URL;
- `git rev-parse HEAD` equals `git rev-parse origin/master`;
- the only local worktree modification is the user's preserved `_posts/2026-07-31-wm.md` body edit.

Expected: Pages workflow succeeds and all live checks pass after any GitHub edge-cache propagation delay.
