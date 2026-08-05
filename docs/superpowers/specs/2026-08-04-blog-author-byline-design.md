# Blog Author Byline Design

## Goal

Add a concise author byline to every blog post header while keeping author metadata editable per post and providing a safe site-wide default.

## Data Contract

- A post may define `author` in its YAML front matter, for example `author: Yihao Sun`.
- The post layout renders `page.author` when present.
- If `page.author` is missing, the layout renders the existing `_config.yml` value `site.name`.
- The current post explicitly defines `author: Yihao Sun` so the editing pattern is visible in the source.

## Rendering

The post header order is:

1. post title;
2. `By <author>`;
3. publication date.

All three remain centered through the existing `.post-header` rule. The author is plain text rather than a link. The current Markdown H1 rules affect only `.post-content h1` and remain left-aligned.

## Styling

Add a `.post-author` rule that keeps the byline in the normal text color and gives it a small bottom margin. Keep `.post-date` muted and keep the current header, post-width, MathJax, responsive, and cache-version styles unchanged.

## Documentation

Update the README blog instructions to identify the `author` front-matter field and explain that `_config.yml` `name` is used when `author` is omitted.

## Files

- Modify `_layouts/post.html` to render the byline between title and date.
- Modify `_posts/2026-07-31-wm.md` only in front matter to add the current author; preserve all existing body edits byte-for-byte.
- Modify `assets/css/style.scss` to style `.post-author`.
- Modify `README.md` to document author editing.
- Create an ignored temporary rendered-output contract during implementation and remove it before the final commit.

## Verification

1. Write a failing rendered-output contract for the title/byline/date order and byline styling.
2. Build Jekyll and confirm the generated post contains `By Yihao Sun` between the title and date.
3. Verify the current post body is unchanged by comparing everything after the front-matter closing delimiter before and after the edit.
4. In a desktop and mobile browser, verify the title, author, and date are centered; Markdown H1 headings remain left-aligned; formulas still render; and no horizontal overflow is introduced.
5. Push `master`, wait for the matching Pages workflow, and verify the live versioned blog URL.

## Non-Goals

- Author portraits, biographies, affiliations, social links, or author archive pages.
- Multiple authors on one post.
- Changes to the blog title, body, date, MathJax behavior, page widths, canonical URL, or homepage Blog ordering.
