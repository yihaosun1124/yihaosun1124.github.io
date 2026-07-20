# Yihao Sun - Personal Homepage

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
