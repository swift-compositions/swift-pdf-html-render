# swift-pdf-html-render

Use this package when you write a PDF's content as HTML views and want it laid out on paged media. Build a `PDF.Document` from HTML with `PDF.Document.init(info:configuration:generateOutline:_:)`, or use `PDF.HTML.pages(configuration:content:header:footer:)` when every page needs a header or footer that knows its page number. `PDF.HTML.render(configuration:html:)` also returns the headings and named destinations it found. Tune paper, margins, fonts and tables through `PDF.HTML.Configuration`. If you also want Markdown input and file output, use swift-pdf. If you lay out pages with `PDF.View` rather than HTML, use swift-pdf-render.

## Laws

- By default a page is A4 with 36 point margins, and text is Times at 12 points in black.
- Headings are bold at 2, 1.5, 1.17, 1, 0.83 and 0.67 times the base size. Paragraphs, block quotes, preformatted text and lists get a margin of 1 em above and below, and headings a margin from 0.67 em at `h1` rising to 2.33 em at `h6`. Vertical margins between blocks collapse to the larger of the two, and a nested list adds none.
- Lengths convert at 0.75 points per pixel. `em` is relative to the current font size and `rem` to the configured base size. Viewport units, `fr` and `calc` resolve to the current font size.
- A heading is kept on the same page as the start of what follows it, as is any element with a break-after of `avoid`. If the next block's top margin and three lines don't fit, the heading moves to a new page.
- A break-before or page-break-before of `always`, `page`, `left` or `right` starts a new page, unless the current page is still empty. A break-after of the same values starts a new page after the element.
- Rules in a `style` element apply to elements that open after it, in source order, with later rules winning. Only type selectors and `*` match. Class, id, attribute, pseudo and combinator selectors are ignored. Of the declarations, only `font-size`, `font-weight` and `line-height` are applied. Rules inside `@media print` or `@media all` apply. Screen, feature-only and other media rules are skipped, as are all other at-rules.
- The text of `style` and `title` elements is never drawn.
- Several CSS properties are accepted and have no effect, among them border radius, border spacing, display, list style, letter and word spacing, text indent and transform, orphans, widows, and minimum and maximum sizes. `text-align: justify` is set flush left. A background colour is drawn as a highlight behind the text. A font weight of 600 or more is bold.
- Table columns are sized from the first row. Content widths are used as they are when they fit, and scaled to the table's width when they don't. Percentage widths on first-row cells act as weights. A column is never narrower than its longest word.
- Table borders are off by default. A border declared on the table turns them on, with `thin`, `medium` and `thick` at 0.75, 2.25 and 3.75 points, and a style of `none` or `hidden` turns them off. Header cells are bold.
- A table row starts on the next page when not even one line of it fits, and the table's right and bottom edges are closed on each page it spans. A row is as tall as its tallest cell, not counting cells that span several rows.
- A page's section title in its header and footer is the last level 1 to 3 heading that starts on that page, and nil on a page without one. Only the first page of a header or footer is drawn, and the content area shrinks by their configured heights.
- An outline is built only when `generateOutline` is true, from headings with text, and is nil if there are none.
- Images are not drawn. They show as their alt text in brackets, or as `[image]`, in gray italics.
