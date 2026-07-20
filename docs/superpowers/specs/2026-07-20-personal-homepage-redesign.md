# Personal Homepage Redesign

## Goal

Replace the current al-folio site on `master` with a small, maintainable Jekyll homepage that follows the layout of [leonidk/leonidk.github.io](https://github.com/leonidk/leonidk.github.io), while preserving the current site on `legacy` and keeping the custom domain.

## Branch and Deployment Safety

- Preserve the unmodified starting commit `24edefc90188b024c5b189dbb6bdde4af4e74987` as `legacy` and push it before changing `master`.
- Keep `master` as the GitHub Pages publishing branch and retain `CNAME` with the exact value `www.yihaosun.cn`.
- Use the current repository history; "clear master" means replacing the working tree contents rather than rewriting published Git history.
- Commit and push the completed site only after local build, content, link, responsive-layout, and PDF checks pass.

## Visual Design

- Match the reference template's compact academic homepage: centered page, approximately 800 px maximum width, white background, dark body text, blue links, and Lato-style typography.
- Use a roughly 60/40 biography-and-portrait header on desktop.
- Use 25/75 image-and-description rows for research and open-source entries.
- Stack columns cleanly on small screens without horizontal scrolling.
- Keep presentation deliberately minimal: no dark mode, animation, analytics, framework UI, or decorative JavaScript.

## Content

All visible copy is English. Current facts come from `/Users/yihaosun/Downloads/yihaosun_cv.pdf`, which is newer than the old homepage.

### Profile

- Name: Yihao Sun.
- Position: Ph.D. student in Computer Science at Universite de Montreal and Mila - Quebec AI Institute, from May 2025 to present.
- Supervisor: Pierre-Luc Bacon.
- Research focus: reinforcement learning for general-purpose embodied intelligence, especially world models and model-based reinforcement learning for efficient policy learning, planning, and adaptation.
- Links: `yihao.sun@mila.quebec`, GitHub, Google Scholar, and the local CV.
- Reuse the current `assets/img/avatar.jpg` portrait.

### Research

The initial homepage contains exactly one paper:

- Title: *Towards Practical World Model-based Reinforcement Learning for Vision-Language-Action Models*.
- Authors: Zhilong Zhang*, Haoxiang Ren*, Yihao Sun*, Yifei Sheng, Haonan Wang, Haoxin Lin, Zhichao Wu, Pierre-Luc Bacon, and Yang Yu.
- Venue: ICML 2026.
- Links: [paper](https://arxiv.org/abs/2603.20607) and [project page](https://rhx11111.github.io/VLA-MBPO/).
- Summary: a concise description of VLA-MBPO's unified multimodal world model, interleaved multi-view decoding, and chunk-level branched rollout.
- Image: a repository-owned SVG placeholder clearly labeled as a research-image placeholder.
- Section note, reproduced exactly: `*: equal contribution, see the CV for the full list`.

### Open Source Projects

- VLARLKit, linking to `https://github.com/VLARLKit/VLARLKit`, described as a researcher-friendly PyTorch reinforcement-learning library for Vision-Language-Action models. Reuse `assets/img/projects/vlarlkit_logo.png`.
- OfflineRL-Kit, linking to `https://github.com/yihaosun1124/OfflineRL-Kit`, described as an elegant PyTorch offline-reinforcement-learning library covering model-free and model-based methods. Reuse `assets/img/projects/offlinerl_kit_logo.png`.

### Blog

- Store normal Jekyll posts in `_posts/YYYY-MM-DD-slug.md`.
- Show the Blog section only when at least one post exists.
- Give each post its own readable page through a small post layout.
- Do not migrate the old site's blog posts into the initial homepage.

### CV and Domain

- Copy `/Users/yihaosun/Downloads/yihaosun_cv.pdf` unchanged to `CV/yihaosun_cv.pdf`.
- Confirm the copied PDF remains a readable two-page document.
- Retain `CNAME` unchanged.

## Site Architecture

- `_config.yml`: site metadata, GitHub Pages-compatible Jekyll configuration, permalink behavior, and exclusions.
- `_data/profile.yml`: editable profile, biography, affiliations, research-interest copy, and social links.
- `_data/research.yml`: a list of research records with title, authors, venue, year, summary, image, alt text, and links.
- `_data/projects.yml`: a list of project records with name, description, image, alt text, and repository link.
- `_layouts/default.html`: the shared HTML document shell and metadata.
- `_layouts/post.html`: a minimal blog-article wrapper.
- `_includes/profile.html`, `_includes/research.html`, `_includes/projects.html`, and `_includes/blog.html`: focused homepage sections.
- `index.html`: assembles the four homepage sections in reference-template order.
- `assets/css/style.scss`: all site styling and responsive rules.
- `assets/img/`: the portrait, retained project logos, and research placeholder.

Liquid loops must tolerate missing optional links and an empty `_posts` collection without producing separators, empty headings, or broken markup.

## Template Cleanup and Attribution

- Do not copy `_old_posts`, the reference author's `_posts`, Intel-specific sections, patent fields, tracking code, thumbnail-generation scripts, or reference-owned images and PDFs.
- Do not retain al-folio plugins, bibliography machinery, layouts, scripts, data files, Docker files, generated demos, or unused assets from the old `master` site.
- Retain an MIT license compatible with the reference template.
- The new README must credit both [leonidk/leonidk.github.io](https://github.com/leonidk/leonidk.github.io) and [Jon Barron's homepage](https://jonbarron.info/).

## README Requirements

The README must provide a short, explicit maintenance guide covering:

1. Where to edit profile and biography content.
2. How to add or change a research record and its image.
3. How to add or change an open-source project and its image.
4. How to create a dated Markdown blog post.
5. How to preview the site locally and what GitHub Pages publishes.
6. Where the custom domain and CV live.
7. Which upstream template inspired the design.

## Verification

- Confirm `legacy` and `origin/legacy` point to the original `master` commit.
- Build the site with a clean Jekyll destination and fail on Liquid or Sass errors.
- Verify generated HTML contains the profile, one research item, two projects, exact contribution note, working CV path, and no reference-author content.
- Check that every local image and document URL resolves to an existing file.
- Inspect the homepage and a sample post at desktop and mobile widths in a browser.
- Run `pdfinfo` on the copied CV and visually render it to confirm it remains intact.
- Confirm `CNAME` still contains only `www.yihaosun.cn`.
- Confirm the final worktree is clean and `master` is pushed to `origin/master`.
