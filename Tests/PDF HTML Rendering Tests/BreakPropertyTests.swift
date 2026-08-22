import CSS
import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

@Suite
struct `PageBreakAfter Tests` {

    @Test
    func `pageBreakAfter avoid keeps header with following content`() {
        struct TestView: HTML.View {
            var body: some HTML.View {

                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H2.Element { "STICKY_HEADER" }
                    .css.pageBreakAfter(.avoid)

                HTML.Paragraph.Element { "FOLLOWING_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("STICKY_HEADER"))
        #expect(contentString.contains("FOLLOWING_CONTENT"))
    }

    @Test
    func `pageBreakAfter always forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "PAGE_ONE_CONTENT" }
                    .css.pageBreakAfter(.always)

                HTML.Paragraph.Element { "PAGE_TWO_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "Should have at least 2 pages after forced break")
    }

    @Test
    func `pageBreakAfter auto allows natural flow`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "SHORT_CONTENT" }
                    .css.pageBreakAfter(.auto)

                HTML.Paragraph.Element { "MORE_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count == 1, "Short content with auto should fit on one page")
    }
}

@Suite
struct `PageBreakBefore Tests` {

    @Test
    func `pageBreakBefore always forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "PAGE_ONE_CONTENT" }

                HTML.Paragraph.Element { "PAGE_TWO_CONTENT" }
                    .css.pageBreakBefore(.always)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "Should have at least 2 pages after forced break")
    }

    @Test
    func `pageBreakBefore auto allows natural flow`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "FIRST" }
                HTML.Paragraph.Element { "SECOND" }
                    .css.pageBreakBefore(.auto)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count == 1, "Short content with auto should fit on one page")
    }
}

@Suite
struct `PageBreakInside Tests` {

    @Test
    func `pageBreakInside avoid keeps element together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {

                for i in 1...35 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.ContentDivision.Element {
                    HTML.Paragraph.Element { "KEEP_TOGETHER_START" }
                    HTML.Paragraph.Element { "KEEP_TOGETHER_END" }
                }
                .css.pageBreakInside(.avoid)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("KEEP_TOGETHER_START"))
        #expect(contentString.contains("KEEP_TOGETHER_END"))
    }
}

@Suite
struct `BreakAfter Tests` {

    @Test
    func `breakAfter avoid keeps header with following content`() {
        struct TestView: HTML.View {
            var body: some HTML.View {

                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H2.Element { "MODERN_STICKY_HEADER" }
                    .css.breakAfter(.avoid)

                HTML.Paragraph.Element { "MODERN_FOLLOWING_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("MODERN_STICKY_HEADER"))
        #expect(contentString.contains("MODERN_FOLLOWING_CONTENT"))
    }

    @Test
    func `breakAfter avoidPage keeps header with following content`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H2.Element { "AVOID_PAGE_HEADER" }
                    .css.breakAfter(.avoidPage)

                HTML.Paragraph.Element { "AVOID_PAGE_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("AVOID_PAGE_HEADER"))
        #expect(contentString.contains("AVOID_PAGE_CONTENT"))
    }

    @Test
    func `breakAfter always forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "BEFORE_BREAK" }
                    .css.breakAfter(.always)

                HTML.Paragraph.Element { "AFTER_BREAK" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "breakAfter: always should create page break")
    }

    @Test
    func `breakAfter page forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "BEFORE_PAGE_BREAK" }
                    .css.breakAfter(.page)

                HTML.Paragraph.Element { "AFTER_PAGE_BREAK" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "breakAfter: page should create page break")
    }
}

@Suite
struct `BreakBefore Tests` {

    @Test
    func `breakBefore always forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "BEFORE_CONTENT" }

                HTML.Paragraph.Element { "AFTER_BREAK_CONTENT" }
                    .css.breakBefore(.always)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "breakBefore: always should create page break")
    }

    @Test
    func `breakBefore page forces page break`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "FIRST_PAGE" }

                HTML.Paragraph.Element { "SECOND_PAGE" }
                    .css.breakBefore(.page)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 2, "breakBefore: page should create page break")
    }

    @Test
    func `breakBefore auto allows natural flow`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "A" }
                HTML.Paragraph.Element { "B" }
                    .css.breakBefore(.auto)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count == 1)
    }
}

@Suite
struct `BreakInside Tests` {

    @Test
    func `breakInside avoid keeps element together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...35 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.ContentDivision.Element {
                    HTML.Paragraph.Element { "MODERN_KEEP_START" }
                    HTML.Paragraph.Element { "MODERN_KEEP_END" }
                }
                .css.breakInside(.avoid)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("MODERN_KEEP_START"))
        #expect(contentString.contains("MODERN_KEEP_END"))
    }

    @Test
    func `breakInside avoidPage keeps element together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...35 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.ContentDivision.Element {
                    HTML.Paragraph.Element { "AVOID_PAGE_START" }
                    HTML.Paragraph.Element { "AVOID_PAGE_END" }
                }
                .css.breakInside(.avoidPage)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("AVOID_PAGE_START"))
        #expect(contentString.contains("AVOID_PAGE_END"))
    }
}

@Suite
struct `Consecutive Sticky Headers Tests` {

    @Test
    func `Consecutive sticky headers chain together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H3.Element { "ARTICLE_HEADER" }
                    .css.pageBreakAfter(.avoid)

                HTML.H4.Element { "SECTION_HEADER" }
                    .css.pageBreakAfter(.avoid)

                HTML.Paragraph.Element { "SECTION_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("ARTICLE_HEADER"))
        #expect(contentString.contains("SECTION_HEADER"))
        #expect(contentString.contains("SECTION_CONTENT"))
    }

    @Test
    func `Modern consecutive sticky headers chain together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H3.Element { "MODERN_ARTICLE" }
                    .css.breakAfter(.avoid)

                HTML.H4.Element { "MODERN_SECTION" }
                    .css.breakAfter(.avoid)

                HTML.Paragraph.Element { "MODERN_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("MODERN_ARTICLE"))
        #expect(contentString.contains("MODERN_SECTION"))
        #expect(contentString.contains("MODERN_CONTENT"))
    }
}

@Suite
struct `Section Wrapper Tests` {

    @Test
    func `Sticky header inside Section wrapper works`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.Section.Element {
                    HTML.H3.Element { "SECTION_WRAPPED_HEADER" }
                        .css.pageBreakAfter(.avoid)

                    HTML.Paragraph.Element { "SECTION_WRAPPED_CONTENT" }
                }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("SECTION_WRAPPED_HEADER"))
        #expect(contentString.contains("SECTION_WRAPPED_CONTENT"))
    }

    @Test
    func `Modern sticky header inside Section wrapper works`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...40 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.Section.Element {
                    HTML.H3.Element { "MODERN_SECTION_HEADER" }
                        .css.breakAfter(.avoid)

                    HTML.Paragraph.Element { "MODERN_SECTION_CONTENT" }
                }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("MODERN_SECTION_HEADER"))
        #expect(contentString.contains("MODERN_SECTION_CONTENT"))
    }
}

@Suite
struct `Sticky Header with Table Tests` {

    @Test
    func `Sticky header with following table`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                for i in 1...38 {
                    HTML.Paragraph.Element { "Filler \(i)" }
                }

                HTML.H3.Element { "TABLE_HEADER" }
                    .css.pageBreakAfter(.avoid)

                HTML.Table.Element {
                    HTML.TableHead.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element { "Column A" }
                            HTML.TableHeader.Element { "Column B" }
                        }
                    }
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "DATA_A" }
                            HTML.TableDataCell.Element { "DATA_B" }
                        }
                    }
                }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("TABLE_HEADER"))
        #expect(contentString.contains("DATA_A"))
    }
}
