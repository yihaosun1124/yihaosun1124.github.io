# Personal Homepage Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current al-folio working tree on `master` with a compact, data-driven academic homepage modeled on leonidk.github.io, while retaining the old site on `legacy`, the custom domain, and the current CV.

**Architecture:** A minimal Jekyll 3.9 site renders editable YAML profile, research, and project records through focused Liquid includes. A shared default layout provides the document shell, a post layout supports future Markdown blogs, and one SCSS entry point recreates the reference page's 800 px, image-left/content-right academic layout without its historical content or scripts.

**Tech Stack:** Jekyll 3.9, Liquid, YAML, HTML5, SCSS, Ruby Minitest, GitHub Pages.

## Global Constraints

- All visible site copy must be English.
- `legacy` and `origin/legacy` must stay at `24edefc90188b024c5b189dbb6bdde4af4e74987`.
- `CNAME` must contain exactly `www.yihaosun.cn` followed by one newline.
- The initial homepage must show exactly one research paper and exactly two open-source projects.
- The Research note must visibly read `*: equal contribution, see the CV for the full list`.
- The source CV must be copied unchanged to `CV/yihaosun_cv.pdf`.
- Do not retain al-folio plugins, bibliography machinery, old news/posts/projects, Docker files, demos, analytics, thumbnail scripts, or reference-author content.
- The visual layout must follow leonidk.github.io: approximately 800 px centered content, 60/40 profile row, and 25/75 entry rows.
- Use the existing portrait and two existing project logos; do not copy reference-owned images.

---

### Task 1: Replace the old tree with a tested minimal content model

**Files:**
- Create: `test/source_content_test.rb`
- Create: `.gitignore`
- Create: `Gemfile`
- Create: `_config.yml`
- Create: `_data/profile.yml`
- Create: `_data/research.yml`
- Create: `_data/projects.yml`
- Create: `_posts/.gitkeep`
- Delete: old al-folio directories and root configuration files listed below
- Preserve: `CNAME`, `assets/img/avatar.jpg`, `assets/img/projects/vlarlkit_logo.png`, `assets/img/projects/offlinerl_kit_logo.png`, `docs/superpowers/`, and `.git/`

**Interfaces:**
- Consumes: the approved design and retained image paths.
- Produces: `site.data.profile`, `site.data.research`, and `site.data.projects` records consumed by every homepage include.

- [ ] **Step 1: Write the failing source-content test**

Create `test/source_content_test.rb`:

```ruby
# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

ROOT = File.expand_path("..", __dir__)

class SourceContentTest < Minitest::Test
  def load_yaml(path)
    YAML.load_file(File.join(ROOT, path))
  end

  def test_custom_domain_is_preserved
    assert_equal "www.yihaosun.cn\n", File.read(File.join(ROOT, "CNAME"))
  end

  def test_profile_uses_current_information
    profile = load_yaml("_data/profile.yml")
    assert_equal "Yihao Sun", profile.fetch("name")
    assert_equal "Ph.D. Student in Computer Science", profile.fetch("role")
    assert_equal "yihao.sun@mila.quebec", profile.dig("links", "email")
    assert_equal "/CV/yihaosun_cv.pdf", profile.dig("links", "cv")
    assert_equal "/assets/img/avatar.jpg", profile.fetch("portrait")
  end

  def test_initial_research_collection_has_one_requested_paper
    research = load_yaml("_data/research.yml")
    assert_equal 1, research.length
    paper = research.first
    assert_equal "Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models", paper.fetch("title")
    assert_equal "ICML", paper.fetch("venue")
    assert_equal 2026, paper.fetch("year")
    assert_equal 3, paper.fetch("authors").count { |author| author["equal"] }
    assert paper.fetch("authors").any? { |author| author["name"] == "Yihao Sun" && author["self"] }
  end

  def test_initial_project_collection_has_two_requested_projects
    projects = load_yaml("_data/projects.yml")
    assert_equal ["VLARLKit", "OfflineRL-Kit"], projects.map { |project| project.fetch("name") }
    projects.each do |project|
      assert project.fetch("repository").start_with?("https://github.com/")
      assert File.file?(File.join(ROOT, project.fetch("image").delete_prefix("/")))
    end
  end

  def test_old_al_folio_tree_is_gone
    %w[_bibliography _news _pages _plugins _projects _sass].each do |path|
      refute Dir.exist?(File.join(ROOT, path)), "expected #{path} to be removed"
    end
    refute File.exist?(File.join(ROOT, "Dockerfile"))
    refute File.exist?(File.join(ROOT, "docker-compose.yml"))
  end
end
```

- [ ] **Step 2: Run the source-content test to verify it fails**

Run:

```bash
ruby test/source_content_test.rb
```

Expected: FAIL because `_data/profile.yml`, `_data/research.yml`, and `_data/projects.yml` do not yet provide the new schema and the old al-folio tree still exists.

- [ ] **Step 3: Remove the explicitly scoped legacy files from `master`**

First confirm `legacy` safety:

```bash
test "$(git rev-parse legacy)" = "24edefc90188b024c5b189dbb6bdde4af4e74987"
test "$(git ls-remote origin refs/heads/legacy | cut -f1)" = "24edefc90188b024c5b189dbb6bdde4af4e74987"
```

Then remove only these known old-site paths:

```bash
git rm -r -- _bibliography _data _includes _layouts _news _pages _plugins _posts _projects _sass bin blog
git rm -r -- assets/bibliography assets/css assets/js assets/pages assets/pdf assets/plotly
git rm -- 404.html CONTRIBUTING.md Dockerfile Gemfile README.md _config.yml docker-compose.yml docker-local.yml news.html robots.txt
git rm -- assets/img/avatar_old.jpg assets/img/peep.png
```

Expected: the retained portrait, both project logos, `CNAME`, `LICENSE`, and `docs/superpowers/` remain present.

- [ ] **Step 4: Add the minimal Jekyll configuration and content data**

Create `.gitignore`:

```gitignore
_site/
.jekyll-cache/
.sass-cache/
.bundle/
vendor/
tmp/
```

Create `Gemfile`:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 3.9"
gem "webrick", "~> 1.8"
```

Create `_config.yml`:

```yaml
title: Yihao Sun
name: Yihao Sun
description: Research homepage of Yihao Sun, a Ph.D. student working on reinforcement learning, world models, and embodied intelligence.
url: "https://www.yihaosun.cn"
baseurl: ""
lang: en
markdown: kramdown
permalink: /blog/:year/:month/:day/:title/

exclude:
  - docs
  - test
  - Gemfile
  - Gemfile.lock
  - README.md
  - vendor
```

Create `_data/profile.yml`:

```yaml
name: Yihao Sun
role: Ph.D. Student in Computer Science
portrait: /assets/img/avatar.jpg
portrait_alt: Portrait of Yihao Sun
affiliations:
  - name: Mila - Quebec AI Institute
    url: https://mila.quebec/en
  - name: Université de Montréal
    url: https://www.umontreal.ca/en/
advisor:
  name: Pierre-Luc Bacon
  url: https://pierrelucbacon.com/
bio: >-
  I am a Ph.D. student in Computer Science at Université de Montréal and Mila - Quebec AI Institute, advised by Prof. Pierre-Luc Bacon. Before starting my Ph.D., I completed my M.Sc. in the LAMDA Group at Nanjing University.
research_interests: >-
  My research centers on reinforcement learning for general-purpose embodied intelligence, with a particular focus on world models and model-based reinforcement learning. I am interested in building generative world models for embodied environments and developing algorithms that use them for efficient policy learning, planning, and adaptation.
links:
  email: yihao.sun@mila.quebec
  github: https://github.com/yihaosun1124
  scholar: https://scholar.google.com/citations?user=pFNG8fMAAAAJ&hl=en
  cv: /CV/yihaosun_cv.pdf
```

Create `_data/research.yml`:

```yaml
- title: Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models
  authors:
    - name: Zhilong Zhang
      equal: true
    - name: Haoxiang Ren
      equal: true
    - name: Yihao Sun
      equal: true
      self: true
    - name: Yifei Sheng
    - name: Haonan Wang
    - name: Haoxin Lin
    - name: Zhichao Wu
    - name: Pierre-Luc Bacon
    - name: Yang Yu
  venue: ICML
  year: 2026
  image: /assets/img/research/vla-mbpo-placeholder.svg
  image_alt: Placeholder illustration for the VLA-MBPO research paper
  summary: >-
    VLA-MBPO combines a unified multimodal world model, interleaved multi-view decoding, and chunk-level branched rollout to improve the practicality and sample efficiency of reinforcement learning for Vision-Language-Action models.
  links:
    - label: paper
      url: https://arxiv.org/abs/2603.20607
    - label: project page
      url: https://rhx11111.github.io/VLA-MBPO/
```

Create `_data/projects.yml`:

```yaml
- name: VLARLKit
  repository: https://github.com/VLARLKit/VLARLKit
  image: /assets/img/projects/vlarlkit_logo.png
  image_alt: VLARLKit logo
  description: >-
    A researcher-friendly PyTorch reinforcement-learning library for Vision-Language-Action models, with cleanly separated policy, rollout, runner, and model components and support for asynchronous off-policy training.

- name: OfflineRL-Kit
  repository: https://github.com/yihaosun1124/OfflineRL-Kit
  image: /assets/img/projects/offlinerl_kit_logo.png
  image_alt: OfflineRL-Kit logo
  description: >-
    An elegant PyTorch offline-reinforcement-learning library with clear, extensible implementations of model-free and model-based algorithms.
```

Create an empty `_posts/.gitkeep` so the documented blog location exists.

- [ ] **Step 5: Run the source-content test to verify it passes**

Run:

```bash
ruby test/source_content_test.rb
git diff --check
```

Expected: all source-content tests PASS and `git diff --check` prints no errors.

- [ ] **Step 6: Commit the clean content foundation**

```bash
git add -A
git commit -m "refactor: replace legacy site with minimal content model"
```

---

### Task 2: Render the profile, research, projects, and future blog

**Files:**
- Create: `test/rendered_site_test.rb`
- Create: `_layouts/default.html`
- Create: `_layouts/post.html`
- Create: `_includes/profile.html`
- Create: `_includes/research.html`
- Create: `_includes/projects.html`
- Create: `_includes/blog.html`
- Create: `index.html`

**Interfaces:**
- Consumes: the YAML keys defined in Task 1 and Jekyll's `site.posts` collection.
- Produces: a semantic homepage at `/` and dated blog pages at `/blog/:year/:month/:day/:title/`.

- [ ] **Step 1: Write the failing rendered-site test**

Create `test/rendered_site_test.rb`:

```ruby
# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class RenderedSiteTest < Minitest::Test
  def setup
    @index_path = File.join(ROOT, "_site", "index.html")
    assert File.file?(@index_path), "run bundle exec jekyll build before this test"
    @html = File.read(@index_path)
  end

  def test_homepage_contains_requested_content
    assert_includes @html, "Yihao Sun"
    assert_includes @html, "Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models"
    visible_text = @html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ")
    assert_includes visible_text, "*: equal contribution, see the CV for the full list"
    assert_includes @html, "VLARLKit"
    assert_includes @html, "OfflineRL-Kit"
    assert_includes @html, "/CV/yihaosun_cv.pdf"
  end

  def test_initial_homepage_has_one_research_entry_and_two_project_entries
    assert_equal 1, @html.scan('class="entry research-entry"').length
    assert_equal 2, @html.scan('class="entry project-entry"').length
  end

  def test_empty_blog_collection_does_not_render_an_empty_section
    refute_includes @html, "<h2>Blog</h2>"
  end

  def test_reference_author_content_is_absent
    %w[Leonid Keselman Intel RealSense al-folio].each do |legacy_text|
      refute_includes @html, legacy_text
    end
  end

end
```

- [ ] **Step 2: Run the rendered-site test to verify it fails**

Run:

```bash
ruby test/rendered_site_test.rb
```

Expected: FAIL with `run bundle exec jekyll build before this test` because no new rendered site exists.

- [ ] **Step 3: Create the shared layouts**

Create `_layouts/default.html`:

```html
<!doctype html>
<html lang="{{ site.lang | default: 'en' }}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="author" content="{{ site.name }}">
    <meta name="description" content="{{ page.description | default: site.description | escape }}">
    <title>{% if page.title %}{{ page.title }} | {% endif %}{{ site.title }}</title>
    <link rel="canonical" href="{{ page.url | replace: 'index.html', '' | absolute_url }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}">
  </head>
  <body>
    <main class="site-shell">
      {{ content }}
    </main>
  </body>
</html>
```

Create `_layouts/post.html`:

```html
---
layout: default
---
<article class="post">
  <p class="back-link"><a href="{{ '/' | relative_url }}">&larr; Back to home</a></p>
  <header class="post-header">
    <h1>{{ page.title }}</h1>
    <p class="post-date">{{ page.date | date: "%B %-d, %Y" }}</p>
  </header>
  <div class="post-content">
    {{ content }}
  </div>
</article>
```

- [ ] **Step 4: Create the homepage includes and entry loops**

Create `_includes/profile.html`:

```html
{% assign profile = site.data.profile %}
<section class="profile" aria-labelledby="profile-name">
  <div class="profile-copy">
    <h1 id="profile-name">{{ profile.name }}</h1>
    <p class="position">
      {{ profile.role }} at
      {% for affiliation in profile.affiliations %}<a href="{{ affiliation.url }}">{{ affiliation.name }}</a>{% unless forloop.last %} &amp; {% endunless %}{% endfor %}.
      Advised by Prof. <a href="{{ profile.advisor.url }}">{{ profile.advisor.name }}</a>.
    </p>
    <p>{{ profile.bio }}</p>
    <p>{{ profile.research_interests }}</p>
    <p class="profile-links">
      <a href="mailto:{{ profile.links.email }}">Email</a><span aria-hidden="true"> / </span>
      <a href="{{ profile.links.github }}">GitHub</a><span aria-hidden="true"> / </span>
      <a href="{{ profile.links.scholar }}">Google Scholar</a><span aria-hidden="true"> / </span>
      <a href="{{ profile.links.cv }}">CV</a>
    </p>
  </div>
  <div class="profile-portrait">
    <img src="{{ profile.portrait | relative_url }}" alt="{{ profile.portrait_alt }}">
  </div>
</section>
```

Create `_includes/research.html`:

```html
<section class="content-section" aria-labelledby="research-heading">
  <header class="section-header">
    <h2 id="research-heading">Research</h2>
    <p>*: equal contribution, see the <a href="{{ site.data.profile.links.cv }}">CV</a> for the full list</p>
  </header>
  <div class="entry-list">
    {% for paper in site.data.research %}
      <article class="entry research-entry">
        <div class="entry-media">
          <img src="{{ paper.image | relative_url }}" alt="{{ paper.image_alt }}">
        </div>
        <div class="entry-copy">
          <h3>{{ paper.title }}</h3>
          <p class="authors">{% for author in paper.authors %}{% if author.self %}<strong>{{ author.name }}</strong>{% else %}{{ author.name }}{% endif %}{% if author.equal %}<sup>*</sup>{% endif %}{% unless forloop.last %}, {% endunless %}{% endfor %}</p>
          <p class="venue"><em>{{ paper.venue }}</em>, {{ paper.year }}</p>
          {% if paper.links %}<p class="entry-links">{% for link in paper.links %}<a href="{{ link.url }}">{{ link.label }}</a>{% unless forloop.last %}<span aria-hidden="true"> / </span>{% endunless %}{% endfor %}</p>{% endif %}
          <p>{{ paper.summary }}</p>
        </div>
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/projects.html`:

```html
<section class="content-section" aria-labelledby="projects-heading">
  <header class="section-header">
    <h2 id="projects-heading">Open Source Projects</h2>
  </header>
  <div class="entry-list">
    {% for project in site.data.projects %}
      <article class="entry project-entry">
        <div class="entry-media">
          <img src="{{ project.image | relative_url }}" alt="{{ project.image_alt }}">
        </div>
        <div class="entry-copy">
          <h3>{{ project.name }}</h3>
          <p class="entry-links"><a href="{{ project.repository }}">code</a></p>
          <p>{{ project.description }}</p>
        </div>
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/blog.html`:

```html
{% if site.posts.size > 0 %}
  <section class="content-section" aria-labelledby="blog-heading">
    <header class="section-header"><h2 id="blog-heading">Blog</h2></header>
    <ul class="post-list">
      {% for post in site.posts %}
        <li><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time><a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
      {% endfor %}
    </ul>
  </section>
{% endif %}
```

- [ ] **Step 5: Assemble the homepage**

Create `index.html`:

```html
---
layout: default
title:
description: Yihao Sun's research homepage.
---
{% include profile.html %}
{% include research.html %}
{% include projects.html %}
{% include blog.html %}
```

- [ ] **Step 6: Install dependencies, build, and confirm the content tests pass**

Run:

```bash
bundle config set --local path vendor/bundle || bundle config path vendor/bundle
bundle install
bundle exec jekyll build --trace
ruby test/source_content_test.rb
ruby test/rendered_site_test.rb
git diff --check
```

Expected: the Jekyll build completes without Liquid errors, both test files PASS, and `git diff --check` prints no errors. Styling and the research placeholder may still be absent; they are added in Task 3.

- [ ] **Step 7: Commit the semantic site rendering**

```bash
git add Gemfile.lock _layouts _includes index.html test/rendered_site_test.rb
git commit -m "feat: render academic homepage sections"
```

---

### Task 3: Match the reference styling and add retained assets and CV

**Files:**
- Create: `test/assets_and_style_test.rb`
- Create: `assets/css/style.scss`
- Create: `assets/img/research/vla-mbpo-placeholder.svg`
- Create: `CV/yihaosun_cv.pdf` by copying the user-provided source
- Verify: `assets/img/avatar.jpg`
- Verify: `assets/img/projects/vlarlkit_logo.png`
- Verify: `assets/img/projects/offlinerl_kit_logo.png`

**Interfaces:**
- Consumes: the class names and asset URLs emitted in Task 2.
- Produces: the responsive 800 px reference layout, all local assets, and the public `/CV/yihaosun_cv.pdf` file.

- [ ] **Step 1: Write the failing asset-and-style test**

Create `test/assets_and_style_test.rb`:

```ruby
# frozen_string_literal: true

require "digest"
require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class AssetsAndStyleTest < Minitest::Test
  def test_reference_layout_rules_exist
    style = File.read(File.join(ROOT, "assets/css/style.scss"))
    assert_includes style, "max-width: 800px"
    assert_includes style, "grid-template-columns: 3fr 2fr"
    assert_includes style, "grid-template-columns: 1fr 3fr"
    assert_match(/@media \(max-width: 640px\)/, style)
  end

  def test_required_images_exist
    %w[
      assets/img/avatar.jpg
      assets/img/projects/vlarlkit_logo.png
      assets/img/projects/offlinerl_kit_logo.png
      assets/img/research/vla-mbpo-placeholder.svg
    ].each do |path|
      assert File.file?(File.join(ROOT, path)), "missing #{path}"
    end
  end

  def test_cv_is_an_unchanged_copy
    source = "/Users/yihaosun/Downloads/yihaosun_cv.pdf"
    public_copy = File.join(ROOT, "CV/yihaosun_cv.pdf")
    assert File.file?(public_copy)
    assert_equal Digest::SHA256.file(source).hexdigest, Digest::SHA256.file(public_copy).hexdigest
  end

  def test_linked_local_assets_exist_in_built_site
    html = File.read(File.join(ROOT, "_site/index.html"))
    html.scan(/(?:src|href)="(\/(?:assets|CV)\/[^"#?]+)"/).flatten.each do |url|
      assert File.file?(File.join(ROOT, "_site", url.delete_prefix("/"))), "missing built asset #{url}"
    end
  end
end
```

- [ ] **Step 2: Run the asset-and-style test to verify it fails**

Run:

```bash
ruby test/assets_and_style_test.rb
```

Expected: FAIL because the stylesheet, placeholder, and public CV do not exist.

- [ ] **Step 3: Add the reference-style SCSS**

Create `assets/css/style.scss`:

```scss
---
---

:root {
  color-scheme: light;
  --text: #222;
  --muted: #666;
  --link: #1772d0;
  --link-hover: #f09228;
}

* {
  box-sizing: border-box;
}

html {
  background: #fff;
}

body {
  margin: 0;
  color: var(--text);
  font-family: "Lato", Verdana, Helvetica, sans-serif;
  font-size: 14px;
  line-height: 1.5;
}

a {
  color: var(--link);
  text-decoration: none;
}

a:hover,
a:focus-visible {
  color: var(--link-hover);
}

img {
  display: block;
  max-width: 100%;
  height: auto;
}

h1,
h2,
h3,
p {
  margin-top: 0;
}

h1 {
  margin-bottom: 1rem;
  font-size: 32px;
  font-weight: 400;
  line-height: 1.15;
  text-align: center;
}

h2 {
  margin-bottom: 0.55rem;
  font-size: 22px;
  font-weight: 400;
}

h3 {
  margin-bottom: 0.35rem;
  font-size: 16px;
  line-height: 1.3;
}

.site-shell {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 20px 40px;
}

.profile {
  display: grid;
  grid-template-columns: 3fr 2fr;
  align-items: center;
}

.profile-copy,
.profile-portrait,
.section-header,
.entry-media,
.entry-copy {
  padding: 2.5%;
}

.profile-copy p {
  margin-bottom: 0.9rem;
}

.profile-links {
  text-align: center;
}

.profile-portrait img {
  width: 100%;
  max-width: 280px;
  margin-left: auto;
}

.content-section {
  margin-top: 12px;
}

.section-header p {
  margin-bottom: 0;
  color: var(--muted);
}

.entry {
  display: grid;
  grid-template-columns: 1fr 3fr;
  align-items: center;
}

.entry-media {
  min-width: 120px;
}

.entry-media img {
  width: 100%;
  max-height: 180px;
  object-fit: contain;
}

.authors,
.venue,
.entry-links {
  margin-bottom: 0.25rem;
}

.entry-copy > p:last-child {
  margin-bottom: 0;
}

.post-list {
  margin: 0;
  padding: 0 2.5%;
  list-style: none;
}

.post-list li {
  display: grid;
  grid-template-columns: 92px 1fr;
  gap: 12px;
  padding: 5px 0;
}

.post-list time,
.post-date {
  color: var(--muted);
}

.post {
  max-width: 720px;
  margin: 0 auto;
}

.post-header {
  margin: 32px 0;
  text-align: center;
}

.post-content {
  font-size: 16px;
}

.post-content img {
  margin: 1.5rem auto;
}

@media (max-width: 640px) {
  .site-shell {
    padding: 16px 14px 32px;
  }

  .profile {
    grid-template-columns: 1fr;
  }

  .profile-portrait {
    grid-row: 1;
  }

  .profile-portrait img {
    width: min(68vw, 240px);
    margin: 0 auto 12px;
  }

  .entry {
    grid-template-columns: 1fr;
    padding-bottom: 18px;
  }

  .entry-media {
    min-width: 0;
  }

  .entry-media img {
    width: min(76vw, 320px);
    margin: 0 auto;
  }

  .post-list li {
    grid-template-columns: 1fr;
    gap: 0;
  }
}
```

- [ ] **Step 4: Add the repository-owned paper placeholder**

Create `assets/img/research/vla-mbpo-placeholder.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 400" role="img" aria-labelledby="title desc">
  <title id="title">VLA-MBPO research placeholder</title>
  <desc id="desc">An abstract diagram connecting observations, a world model, and a policy.</desc>
  <rect width="640" height="400" rx="24" fill="#f2f5f8"/>
  <g fill="none" stroke="#1772d0" stroke-width="8" stroke-linecap="round">
    <path d="M180 200h100"/>
    <path d="M360 200h100"/>
  </g>
  <g fill="#fff" stroke="#8aa9c7" stroke-width="5">
    <rect x="45" y="130" width="135" height="140" rx="18"/>
    <rect x="280" y="105" width="80" height="190" rx="18"/>
    <rect x="460" y="130" width="135" height="140" rx="18"/>
  </g>
  <g fill="#1772d0">
    <circle cx="90" cy="180" r="18"/>
    <circle cx="135" cy="220" r="18"/>
    <circle cx="320" cy="155" r="14"/>
    <circle cx="320" cy="200" r="14"/>
    <circle cx="320" cy="245" r="14"/>
    <path d="M500 230l35-62 35 62z"/>
  </g>
  <text x="320" y="350" fill="#52606d" font-family="Arial, sans-serif" font-size="22" text-anchor="middle">Research image placeholder</text>
</svg>
```

- [ ] **Step 5: Copy and verify the CV**

Copy the exact source PDF:

```bash
mkdir -p CV
cp /Users/yihaosun/Downloads/yihaosun_cv.pdf CV/yihaosun_cv.pdf
shasum -a 256 /Users/yihaosun/Downloads/yihaosun_cv.pdf CV/yihaosun_cv.pdf
pdfinfo CV/yihaosun_cv.pdf
```

Expected: both SHA-256 hashes are identical and `pdfinfo` reports `Pages: 2` with no encryption or syntax errors.

- [ ] **Step 6: Build and run all automated checks**

```bash
bundle exec jekyll build --trace
ruby test/source_content_test.rb
ruby test/rendered_site_test.rb
ruby test/assets_and_style_test.rb
git diff --check
```

Expected: build succeeds, all tests PASS, and `git diff --check` prints no errors.

- [ ] **Step 7: Render the CV and inspect its two pages**

```bash
mkdir -p tmp/pdfs
pdftoppm -png -r 120 CV/yihaosun_cv.pdf tmp/pdfs/yihaosun_cv
```

Inspect `tmp/pdfs/yihaosun_cv-1.png` and `tmp/pdfs/yihaosun_cv-2.png`; both must remain legible and free of clipping or corruption. The `tmp/` directory stays ignored.

- [ ] **Step 8: Serve and visually inspect desktop and mobile layouts**

Run:

```bash
bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Open `http://127.0.0.1:4000/`. At 1440 px viewport width confirm the 60/40 profile row and 25/75 content rows match the reference template. At 390 px viewport width confirm the portrait and every entry stack into one column, no horizontal scroll appears, all text is readable, and all links can receive keyboard focus.

- [ ] **Step 9: Commit styling, assets, and CV**

```bash
git add assets/css/style.scss assets/img/research/vla-mbpo-placeholder.svg CV/yihaosun_cv.pdf test/assets_and_style_test.rb
git commit -m "feat: match reference layout and publish CV"
```

---

### Task 4: Add the maintenance guide, attribution, and release verification

**Files:**
- Create: `test/documentation_test.rb`
- Create: `README.md`
- Modify: `LICENSE`
- Verify: all final site files and branch refs

**Interfaces:**
- Consumes: the paths and data schemas created in Tasks 1-3.
- Produces: a concise maintenance contract for future profile, research, project, blog, CV, domain, and deployment updates.

- [ ] **Step 1: Write the failing documentation test**

Create `test/documentation_test.rb`:

```ruby
# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__) unless defined?(ROOT)

class DocumentationTest < Minitest::Test
  def test_readme_documents_every_editing_entry_point
    readme = File.read(File.join(ROOT, "README.md"))
    %w[
      _data/profile.yml
      _data/research.yml
      _data/projects.yml
      _posts/YYYY-MM-DD-slug.md
      CV/yihaosun_cv.pdf
      CNAME
      leonidk/leonidk.github.io
      jonbarron.info
    ].each do |text|
      assert_includes readme, text
    end
  end

  def test_reference_license_notice_is_retained
    license = File.read(File.join(ROOT, "LICENSE"))
    assert_includes license, "Copyright (c) 2015 Barry Clark"
    assert_includes license, "The MIT License (MIT)"
  end
end
```

- [ ] **Step 2: Run the documentation test to verify it fails**

Run:

```bash
ruby test/documentation_test.rb
```

Expected: FAIL because the new README and upstream license notice are not yet present.

- [ ] **Step 3: Write the concise maintenance README**

Create `README.md`:

````markdown
# Yihao Sun - Personal Homepage

This repository contains the Jekyll source for [www.yihaosun.cn](https://www.yihaosun.cn). GitHub Pages builds the site from the `master` branch; the previous al-folio site is preserved on `legacy`.

## Edit the site

- Personal information: edit `_data/profile.yml`. The portrait path is configured there; the current image is `assets/img/avatar.jpg`.
- Research: add or edit entries in `_data/research.yml`. Put each paper image in `assets/img/research/` and set its `image` and `image_alt` fields in the YAML record.
- Open-source projects: add or edit entries in `_data/projects.yml`. Put project images in `assets/img/projects/` and reference them from the YAML record.
- CV: replace `CV/yihaosun_cv.pdf` while keeping the filename unchanged.
- Custom domain: `CNAME` must continue to contain `www.yihaosun.cn`.

## Create a blog post

Create `_posts/YYYY-MM-DD-slug.md` with front matter like this:

```yaml
---
layout: post
title: Your Post Title
---
```

Write the post in Markdown below the front matter. The Blog section appears on the homepage automatically when at least one post exists.

## Preview locally

```bash
bundle install
bundle exec jekyll serve
```

Open `http://127.0.0.1:4000/`. Run `bundle exec jekyll build --trace` before publishing. Pushing `master` updates the GitHub Pages site.

## Design credit

The homepage layout is adapted from [leonidk/leonidk.github.io](https://github.com/leonidk/leonidk.github.io), which in turn adapts [Jon Barron's homepage](https://jonbarron.info/). The minimal Jekyll foundation derives from Jekyll Now and remains available under the MIT License.
````

- [ ] **Step 4: Retain the upstream MIT notice**

Replace `LICENSE` with:

```text
The MIT License (MIT)

Copyright (c) 2015 Barry Clark
Copyright (c) 2026 Yihao Sun

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

- [ ] **Step 5: Run complete release verification**

```bash
bundle exec jekyll build --trace
ruby test/source_content_test.rb
ruby test/rendered_site_test.rb
ruby test/assets_and_style_test.rb
ruby test/documentation_test.rb
git diff --check
test "$(git rev-parse legacy)" = "24edefc90188b024c5b189dbb6bdde4af4e74987"
test "$(git ls-remote origin refs/heads/legacy | cut -f1)" = "24edefc90188b024c5b189dbb6bdde4af4e74987"
test "$(tr -d '\r\n' < CNAME)" = "www.yihaosun.cn"
pdfinfo CV/yihaosun_cv.pdf | grep "Pages:           2"
```

Expected: build and all tests PASS, both legacy refs match the starting commit, the domain check passes, and `pdfinfo` confirms two pages.

- [ ] **Step 6: Commit the documentation and license**

```bash
git add README.md LICENSE test/documentation_test.rb docs/superpowers
git commit -m "docs: add homepage maintenance guide"
```

- [ ] **Step 7: Review the final diff and push `master`**

```bash
git status --short --branch
git diff --stat origin/master...HEAD
git log --oneline --decorate origin/master..HEAD
git push origin master
git status --short --branch
```

Expected: the diff contains only the approved redesign, the push succeeds, and final status reports clean `master` tracking `origin/master` with no ahead/behind count.
