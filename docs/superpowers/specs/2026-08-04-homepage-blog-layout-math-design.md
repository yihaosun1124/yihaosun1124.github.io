# Homepage and Blog Layout/Math Design

## Goal

Improve the homepage information order and desktop width, give long-form blog posts more room, distinguish the post title from Markdown level-one headings, and render LaTeX formulas correctly without adding math assets to pages that do not need them.

## Homepage order

The homepage content order will be:

1. Profile introduction
2. Blog
3. Selected Publications
4. Open Source Projects
5. Template credit footer

Only the include order in `index.html` changes. Blog data and publication/project rendering remain unchanged.

## Widths and responsive behavior

- `.site-shell` will use `max-width: 1040px`, increasing the homepage desktop width from 800px.
- `.post` will use `max-width: 900px`, increasing blog content width from 720px while remaining narrower than the outer shell.
- Existing `width: 100%`, automatic horizontal margins, desktop padding, and the `640px` mobile breakpoint remain in place.
- On small screens, both page types continue to fit the viewport using the existing responsive padding and one-column layouts.

## Heading alignment

The two kinds of level-one headings have different roles and must remain independently styled:

- The blog page title in `.post-header h1` remains centered.
- The publication date in `.post-header .post-date` remains centered.
- Markdown `# ...` headings rendered inside `.post-content` become left-aligned through a scoped `.post-content h1` rule.
- The homepage profile name keeps its current centered alignment.

## Formula rendering

### Root cause

The current post uses `\(...\)` and `\[...\]` directly in GFM Markdown. Kramdown treats the backslashes as Markdown escapes, so the generated HTML contains plain parentheses/brackets rather than TeX delimiters. The layout also loads no browser-side math renderer.

### Selected approach

Use MathJax 4 only on pages that opt in through front matter:

- Add `math: true` to the current blog post.
- In `_layouts/default.html`, conditionally emit the MathJax configuration and deferred CDN loader only when `page.math` is true.
- Load `https://cdn.jsdelivr.net/npm/mathjax@4/tex-chtml.js`.
- Configure MathJax to add `$...$` as an inline delimiter while preserving its default `\(...\)` support.
- Author inline formulas as `$...$` and displayed formulas as standalone `$$...$$` blocks.
- Convert the current post's inline and displayed formulas to those conventions.

Kramdown leaves single-dollar inline formulas available for the browser and converts standalone double-dollar blocks into MathJax-compatible displayed delimiters. Non-math pages do not download or execute MathJax.

## Formula layout

Displayed MathJax containers will be centered and constrained to the post width. On narrow screens they may scroll horizontally, preventing a long expression from expanding the page or being clipped.

## Verification

Implementation is complete when:

1. The rendered homepage places Blog after the profile and before Selected Publications.
2. Compiled CSS contains homepage width `1040px` and blog width `900px`.
3. The blog page title and date are centered while `.post-content h1` is left-aligned.
4. The current post opts into MathJax, and non-math pages contain no MathJax loader.
5. Rendered post HTML preserves valid inline/display TeX delimiters rather than plain escaped parentheses or brackets.
6. MathJax typesets the inline variables and the displayed aligned equation in a browser at desktop and mobile widths.
7. The displayed equation does not overflow the mobile page.
8. Jekyll builds successfully and GitHub Pages deploys the matching commit successfully.
