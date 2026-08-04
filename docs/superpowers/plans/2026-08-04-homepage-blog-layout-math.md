# Homepage and Blog Layout/Math Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorder the homepage, widen desktop homepage/blog layouts, left-align Markdown H1 headings without moving the centered post title/date, and render blog formulas through opt-in MathJax 4.

**Architecture:** Keep the existing Jekyll include/layout structure. Make layout changes through scoped source/CSS edits, and add a `page.math` front-matter contract so only math-enabled posts load MathJax. Use ignored temporary Minitest contract files for RED/GREEN coverage because the repository intentionally does not track `test/` or `docs/` in its final tree.

**Tech Stack:** Jekyll 3.10, Kramdown 2.5 with GFM parser, Liquid, SCSS, MathJax 4 CommonHTML, Minitest, GitHub Actions/GitHub Pages.

## Global Constraints

- Homepage order must be Profile introduction → Blog → Selected Publications → Open Source Projects → template credit footer.
- Homepage `.site-shell` maximum width must be exactly `1040px`.
- Blog `.post` maximum width must be exactly `900px`.
- The blog page title and date remain centered.
- Markdown H1 headings inside `.post-content` are left-aligned.
- The homepage profile name remains centered.
- MathJax loads only when `page.math` is true.
- Math-enabled Markdown uses `$...$` inline and standalone `$$...$$` display delimiters.
- Displayed formulas remain centered and scroll horizontally inside the post on narrow screens instead of widening the page.
- Existing mobile padding, one-column grids, favicon, footer, CNAME, CV, publications, projects, blog content, and blog image remain intact.
- The final `master` tree must not retain `docs/`, `test/`, or temporary contract files.

---

### Task 1: Homepage order, widths, and scoped heading alignment

**Files:**
- Create temporarily: `tmp/home_blog_layout_test.rb`
- Modify: `index.html`
- Modify: `assets/css/style.scss`

**Interfaces:**
- Consumes: Existing Liquid includes and `.site-shell`, `.post`, `.post-header`, `.post-content` selectors.
- Produces: The homepage section sequence and CSS width/alignment contracts used by Task 3 browser checks.

- [ ] **Step 1: Write the failing source/rendered contract**

Create `tmp/home_blog_layout_test.rb` with:

```ruby
# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__)

class HomeBlogLayoutTest < Minitest::Test
  def setup
    @index_source = File.read(File.join(ROOT, "index.html"))
    @style = File.read(File.join(ROOT, "assets/css/style.scss"))
    @home = File.read(File.join(ROOT, "_site/index.html"))
    @post = File.read(File.join(ROOT, "_site/blog/2026/07/31/wm/index.html"))
  end

  def test_homepage_include_order
    profile = @index_source.index("{% include profile.html %}")
    blog = @index_source.index("{% include blog.html %}")
    research = @index_source.index("{% include research.html %}")
    projects = @index_source.index("{% include projects.html %}")

    assert profile < blog
    assert blog < research
    assert research < projects
  end

  def test_desktop_widths
    assert_match(/\.site-shell\s*\{[^}]*max-width:\s*1040px;/m, @style)
    assert_match(/\.post\s*\{[^}]*max-width:\s*900px;/m, @style)
  end

  def test_heading_alignment_is_scoped
    assert_match(/\.post-header\s*\{[^}]*text-align:\s*center;/m, @style)
    assert_match(/\.post-content\s+h1\s*\{[^}]*text-align:\s*left;/m, @style)
  end

  def test_rendered_home_order_and_post_content
    assert @home.index('id="blog-heading"') < @home.index('id="research-heading"')
    assert_includes @post, '<h1>Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents</h1>'
    assert_includes @post, '<h1 id="bc-vs-rl-for-robot-manipulation">BC vs. RL for Robot Manipulation</h1>'
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
ruby -Itest tmp/home_blog_layout_test.rb
```

Expected: the test fails because Blog follows Projects, widths are `800px`/`720px`, and `.post-content h1` has no left-alignment rule.

- [ ] **Step 3: Implement homepage order and scoped CSS**

Change the include block in `index.html` to exactly:

```liquid
{% include profile.html %}
{% include blog.html %}
{% include research.html %}
{% include projects.html %}
```

In `assets/css/style.scss`:

```scss
.site-shell {
  width: 100%;
  max-width: 1040px;
  margin: 0 auto;
  padding: 24px 20px 40px;
}
```

```scss
.post {
  max-width: 900px;
  margin: 0 auto;
}
```

Add immediately after `.post-content`:

```scss
.post-content h1 {
  text-align: left;
}
```

Do not alter the existing `.post-header { text-align: center; }` or global `h1` rule.

- [ ] **Step 4: Rebuild and run the contract to verify GREEN**

Run:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll build --trace
ruby -Itest tmp/home_blog_layout_test.rb
```

Expected: 4 runs, all assertions pass.

- [ ] **Step 5: Commit the layout change**

```bash
git add index.html assets/css/style.scss
git diff --cached --check
git commit -m "style: refine homepage and blog layout"
```

Do not force-add `tmp/home_blog_layout_test.rb`; it remains ignored and will be removed during final cleanup.

### Task 2: Opt-in MathJax formula pipeline

**Files:**
- Create temporarily: `tmp/blog_math_test.rb`
- Modify: `_layouts/default.html`
- Modify: `_posts/2026-07-31-wm.md`
- Modify: `assets/css/style.scss`

**Interfaces:**
- Consumes: `page.math` from post front matter and Kramdown's GFM conversion.
- Produces: Conditional MathJax configuration/loader and valid inline/display TeX delimiters in rendered post HTML.

- [ ] **Step 1: Write the failing formula contract**

Create `tmp/blog_math_test.rb` with:

```ruby
# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__)

class BlogMathTest < Minitest::Test
  def setup
    @layout = File.read(File.join(ROOT, "_layouts/default.html"))
    @post_source = File.read(File.join(ROOT, "_posts/2026-07-31-wm.md"))
    @style = File.read(File.join(ROOT, "assets/css/style.scss"))
    @home = File.read(File.join(ROOT, "_site/index.html"))
    @post = File.read(File.join(ROOT, "_site/blog/2026/07/31/wm/index.html"))
  end

  def test_post_opts_into_mathjax
    assert_match(/\Amath: true$|^math: true$/m, @post_source)
    assert_includes @layout, "{% if page.math %}"
    assert_includes @layout, "https://cdn.jsdelivr.net/npm/mathjax@4/tex-chtml.js"
    assert_includes @layout, %q(inlineMath: { "[+]": [["$", "$"]] })
  end

  def test_mathjax_is_post_only
    refute_includes @home, "mathjax@4/tex-chtml.js"
    assert_includes @post, "mathjax@4/tex-chtml.js"
  end

  def test_rendered_math_delimiters_survive_markdown
    assert_includes @post, '$\\pi_E$'
    assert_includes @post, '\\[\\begin{aligned}'
    refute_includes @post, 'Let (\\pi_E) and (\\pi_{BC})'
    refute_includes @post, "<p>[\n\\begin{aligned}"
  end

  def test_display_math_has_mobile_overflow_protection
    assert_match(/mjx-container\[display="true"\]\s*\{[^}]*max-width:\s*100%;[^}]*overflow-x:\s*auto;/m, @style)
  end
end
```

- [ ] **Step 2: Run the formula contract to verify RED**

Run:

```bash
ruby -Itest tmp/blog_math_test.rb
```

Expected: FAIL because no `math: true`, conditional loader, surviving delimiters, or MathJax overflow rule exists.

- [ ] **Step 3: Add the conditional MathJax loader**

In `_layouts/default.html`, insert the following immediately before the site stylesheet link:

```liquid
    {% if page.math %}
    <script>
      window.MathJax = {
        tex: {
          inlineMath: { "[+]": [["$", "$"]] }
        }
      };
    </script>
    <script defer src="https://cdn.jsdelivr.net/npm/mathjax@4/tex-chtml.js"></script>
    {% endif %}
```

- [ ] **Step 4: Convert the current post to the math contract**

Add `math: true` to `_posts/2026-07-31-wm.md` front matter:

```yaml
---
layout: post
title: "Why World-Model-Based RL Might Be the Most Promising Path to Generalist Embodied Agents"
math: true
---
```

Change all inline formulas from `\(...\)` to `$...$`, including:

```markdown
Let $\pi_E$ and $\pi_{BC}$ denote the expert and imitation policies, respectively. For a $\gamma$-discounted MDP with rewards bounded by $R_{\max}$, the value gap can be bounded as [9]
```

```markdown
Here, $d_{\pi_E}$ is the expert's discounted state distribution and $\bar{\epsilon}_{\pi}$ upper-bounds the average KL divergence between the two policies on expert states. The factor $(1-\gamma)^{-2}$ shows how a small one-step imitation error can be amplified quadratically in the effective horizon.
```

```markdown
RL addresses this problem by reducing distribution shift. BC is trained under the expert distribution $d_{\pi_E}$ but deployed under $d_{\pi_{BC}}$; RL instead collects experience from the current policy, so its training distribution continually tracks the states that the policy actually visits.
```

Change the display equation delimiters to:

```markdown
$$
\begin{aligned}
V_{\pi_E}-V_{\pi_{BC}} \leq \frac{2\sqrt{2}R_{\max}}{(1-\gamma)^2}\sqrt{\bar{\epsilon}_{\pi}}.
\end{aligned}
$$
```

Keep all non-formula prose byte-for-byte unchanged.

- [ ] **Step 5: Add MathJax overflow protection**

Append near the post-content styles in `assets/css/style.scss`:

```scss
mjx-container[display="true"] {
  display: block;
  max-width: 100%;
  overflow-x: auto;
  overflow-y: hidden;
  padding: 0.25rem 0;
}
```

- [ ] **Step 6: Rebuild and run both contracts to verify GREEN**

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
ruby -Itest tmp/home_blog_layout_test.rb
ruby -Itest tmp/blog_math_test.rb
```

Expected: clean Jekyll build; both temporary test files pass.

- [ ] **Step 7: Commit the math change**

```bash
git add _layouts/default.html _posts/2026-07-31-wm.md assets/css/style.scss
git diff --cached --check
git commit -m "feat: render formulas in blog posts"
```

### Task 3: Browser verification, cleanup, deployment, and live checks

**Files:**
- Delete: `docs/superpowers/specs/2026-08-04-homepage-blog-layout-math-design.md`
- Delete: `docs/superpowers/plans/2026-08-04-homepage-blog-layout-math.md`
- Delete locally: `tmp/home_blog_layout_test.rb`
- Delete locally: `tmp/blog_math_test.rb`

**Interfaces:**
- Consumes: Built `_site` from Tasks 1–2 and the existing Pages workflow.
- Produces: A clean tracked tree and a verified deployment on `https://www.yihaosun.cn/`.

- [ ] **Step 1: Run a fresh production build and source assertions**

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
ruby -Itest tmp/home_blog_layout_test.rb
ruby -Itest tmp/blog_math_test.rb
git diff --check
```

Expected: dependency check, clean build, both contracts, and whitespace check exit 0.

- [ ] **Step 2: Serve and verify desktop/mobile behavior in a real browser**

Start a no-watch local server on `127.0.0.1:4104`:

```bash
GEM_HOME="$PWD/tmp/tooling-gems" \
GEM_PATH="$PWD/tmp/tooling-gems" \
RUBYOPT="-r$PWD/tmp/rbconfig_current_sdk.rb" \
"$PWD/tmp/tooling-bin/bundle" exec jekyll serve \
  --host 127.0.0.1 --port 4104 --no-watch
```

Using the in-app browser:

1. At a `1440×1000` viewport, verify `.site-shell` computed width is `1040`, `.post` width is `900`, homepage DOM order is Profile/Blog/Selected Publications/Open Source Projects, `.post-header h1` and `.post-date` are centered, and `.post-content h1` is left-aligned.
2. Wait for MathJax startup on `/blog/2026/07/31/wm/`, then verify inline `<mjx-container>` elements and one display container exist and the rendered display contains the aligned equation.
3. At a `390×844` viewport, verify `document.documentElement.scrollWidth <= innerWidth`, the equation container is internally scrollable if needed, and homepage grids remain one-column.
4. Reset the viewport override and finalize the browser tabs.

Expected: all computed-style, DOM-order, MathJax, and overflow checks pass without console errors.

- [ ] **Step 3: Remove temporary and planning artifacts**

Use `apply_patch` to delete the two tracked planning documents and the two ignored temporary contract files. Then run:

```bash
git add -u
git diff --cached --check
git commit -m "chore: remove implementation planning artifacts"
```

Expected: the two tracked planning files are deleted; temporary ignored test files are absent.

- [ ] **Step 4: Review and push the final branch**

Run:

```bash
git status --short --branch
git ls-files docs test
git log -5 --oneline
git push origin master
```

Expected: the worktree is clean, `git ls-files docs test` is empty, and `origin/master` advances through the layout, math, and planning-cleanup commits.

- [ ] **Step 5: Verify matching CI and live deployment**

Use the GitHub Actions API to wait until the Pages workflow whose `head_sha` equals `git rev-parse HEAD` reaches `completed success`. Then verify:

```bash
test "$(curl -sS -L -o /tmp/yihaosun-home-layout-live.html -w '%{http_code}' \
  'https://www.yihaosun.cn/?verify=layout-math')" = "200"
test "$(curl -sS -L -o /tmp/yihaosun-blog-math-live.html -w '%{http_code}' \
  'https://www.yihaosun.cn/blog/2026/07/31/wm/?verify=layout-math')" = "200"
rg -q 'id="blog-heading"' /tmp/yihaosun-home-layout-live.html
rg -q 'id="research-heading"' /tmp/yihaosun-home-layout-live.html
rg -q 'mathjax@4/tex-chtml.js' /tmp/yihaosun-blog-math-live.html
rg -q '\$\\pi_E\$' /tmp/yihaosun-blog-math-live.html
rg -q '\\\[\\begin\{aligned\}' /tmp/yihaosun-blog-math-live.html
test -z "$(git status --porcelain)"
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/master)"
```

Expected: both pages return 200, the live source has the ordered sections and MathJax contract, and local/remote Git state is synchronized.
