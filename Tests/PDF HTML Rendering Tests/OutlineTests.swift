import CSS
import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

struct H<let N: Int> {

    @HTML.Builder
    func callAsFunction(
        @HTML.Builder _ content: () -> some HTML.View
    ) -> some HTML.View {
        switch N {
        case 1: HTML.H1.Element { content() }.css.pageBreakAfter(.avoid)
        case 2: HTML.H2.Element { content() }.css.pageBreakAfter(.avoid)
        case 3: HTML.H3.Element { content() }.css.pageBreakAfter(.avoid)
        case 4: HTML.H4.Element { content() }.css.pageBreakAfter(.avoid)
        case 5: HTML.H5.Element { content() }.css.pageBreakAfter(.avoid)
        case 6: HTML.H6.Element { content() }.css.pageBreakAfter(.avoid)
        default: HTML.H1.Element { content() }.css.pageBreakAfter(.avoid)
        }
    }
}

@Suite
struct `Outline Generation Tests` {

    @Test
    func `Raw H1 headings appear in outline`() throws {
        let result = PDF.HTML.render {
            HTML.H1.Element { "Main Title" }
            HTML.Paragraph.Element { "Some content after the title." }
        }

        print("DEBUG TEST: Raw H1 - collected \(result.headings.count) headings")
        for h in result.headings {
            print("DEBUG TEST: - Level \(h.level): '\(h.text)' page \(h.pageNumber)")
        }

        #expect(result.headings.count >= 1, "Should collect at least 1 heading")
        #expect(result.headings.contains { $0.text == "Main Title" }, "Should contain 'Main Title'")
    }

    @Test
    func `H wrapper headings appear in outline`() throws {
        let result = PDF.HTML.render {
            H<1> { "Wrapped Title" }
            HTML.Paragraph.Element { "Some content after the wrapped title." }
        }

        print("DEBUG TEST: H<1> wrapper - collected \(result.headings.count) headings")
        for h in result.headings {
            print("DEBUG TEST: - Level \(h.level): '\(h.text)' page \(h.pageNumber)")
        }

        #expect(result.headings.count >= 1, "Should collect at least 1 heading from H<N> wrapper")
        #expect(
            result.headings.contains { $0.text == "Wrapped Title" },
            "Should contain 'Wrapped Title'"
        )
    }

    @Test
    func `Raw H1 inside Header container appears in outline`() throws {
        let result = PDF.HTML.render {
            HTML.Header.Element {
                HTML.H1.Element { "Header Title" }
                HTML.Paragraph.Element { "(A subtitle)" }
            }
            HTML.Paragraph.Element { "Body content." }
        }

        print("DEBUG TEST: Raw H1 inside Header - collected \(result.headings.count) headings")
        for h in result.headings {
            print("DEBUG TEST: - Level \(h.level): '\(h.text)' page \(h.pageNumber)")
        }

        #expect(
            result.headings.count >= 1,
            "Should collect at least 1 heading from Header container"
        )
        #expect(
            result.headings.contains { $0.text == "Header Title" },
            "Should contain 'Header Title'"
        )
    }

    @Test
    func `Mixed raw and wrapped headings all appear in outline`() throws {
        let result = PDF.HTML.render {

            HTML.Header.Element {
                HTML.H1.Element { "DOCUMENT TITLE" }
                HTML.Paragraph.Element { "(A Corporation)" }
            }

            HTML.Section.Element {
                H<3> { "ARTICLE I" }
                H<4> { "NAME" }
                HTML.Paragraph.Element { "The name of this corporation is Test Corp." }
            }

            HTML.Section.Element {
                H<3> { "ARTICLE II" }
                H<4> { "PURPOSE" }
                HTML.Paragraph.Element { "The purpose of this corporation is testing." }
            }
        }

        print("DEBUG TEST: Mixed headings - collected \(result.headings.count) headings")
        for h in result.headings {
            print("DEBUG TEST: - Level \(h.level): '\(h.text)' page \(h.pageNumber)")
        }

        #expect(result.headings.count >= 5, "Should collect at least 5 headings")
        #expect(
            result.headings.contains { $0.text == "DOCUMENT TITLE" },
            "Should contain 'DOCUMENT TITLE'"
        )
        #expect(result.headings.contains { $0.text == "ARTICLE I" }, "Should contain 'ARTICLE I'")
        #expect(result.headings.contains { $0.text == "ARTICLE II" }, "Should contain 'ARTICLE II'")
        #expect(result.headings.contains { $0.text == "NAME" }, "Should contain 'NAME'")
        #expect(result.headings.contains { $0.text == "PURPOSE" }, "Should contain 'PURPOSE'")
    }

    @Test
    func `Document with outline generates correct PDF`() throws {
        let doc = PDF.Document(
            info: .init(title: "Outline Test"),
            generateOutline: true
        ) {
            HTML.Header.Element {
                HTML.H1.Element { "MAIN DOCUMENT TITLE" }
                HTML.Paragraph.Element { "(Subtitle)" }
            }

            HTML.Section.Element {
                H<3> { "SECTION ONE" }
                HTML.Paragraph.Element { "Content for section one." }
            }

            HTML.Section.Element {
                H<3> { "SECTION TWO" }
                HTML.Paragraph.Element { "Content for section two." }
            }
        }

        let bytes = [UInt8](doc)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("outline-test.pdf")
        try Data(bytes).write(to: url)
        print("DEBUG TEST: PDF written to: \(url.path)")

        #expect(doc.pages.count >= 1)
        #expect(doc.outline != nil, "Document should have outline")

        if let outline = doc.outline {
            print("DEBUG TEST: Outline has \(outline.items.count) top-level items")
            printOutlineItems(outline.items, indent: 0)

            let hasMainTitle = containsTitle(outline.items, "MAIN DOCUMENT TITLE")
            #expect(hasMainTitle, "Outline should contain 'MAIN DOCUMENT TITLE'")
        }
    }

    @Test
    func `H1 with BR elements inside`() throws {
        let result = PDF.HTML.render {
            HTML.Header.Element {
                HTML.H1.Element {
                    "ARTICLES OF INCORPORATION"
                    HTML.BR.Element()
                    "OF"
                    HTML.BR.Element()
                    "TEST CORPORATION"
                }.css.textAlign(.center)
            }
            HTML.Paragraph.Element { "Body content." }
        }

        print("DEBUG TEST: H1 with BR - collected \(result.headings.count) headings")
        for h in result.headings {
            print("DEBUG TEST: - Level \(h.level): '\(h.text)' page \(h.pageNumber)")
        }

        #expect(
            result.headings.count >= 1,
            "Should collect at least 1 heading from H1 with BR elements"
        )

        let hasH1 = result.headings.contains { h in
            h.level == 1 && !h.text.isEmpty
        }
        #expect(hasH1, "Should have an H1 heading with non-empty text")
    }

    @Test
    func `Articles of Incorporation style document`() throws {
        let doc = PDF.Document(
            info: .init(title: "Articles of Incorporation"),
            generateOutline: true
        ) {

            HTML.Header.Element {
                HTML.H1.Element {
                    "ARTICLES OF INCORPORATION"
                    HTML.BR.Element()
                    "OF"
                    HTML.BR.Element()
                    "TEST CORPORATION, INC."
                }.css.textAlign(.center)
                HTML.Paragraph.Element { "(A Nevada Corporation)" }.css.textAlign(.center)
                HTML.Paragraph.Element { "(Pursuant to Chapter 78 of the Nevada Revised Statutes)" }.css
                    .textAlign(.center)
            }

            HTML.Section.Element {
                H<3> { "ARTICLE I" }
                H<4> { "NAME" }
                HTML.Paragraph.Element { "The name of this corporation is TEST CORPORATION, INC." }
            }

            HTML.Section.Element {
                H<3> { "ARTICLE II" }
                H<4> { "REGISTERED AGENT" }
                HTML.Paragraph.Element { "The registered agent is located at 123 Main Street." }
            }

            HTML.Section.Element {
                H<3> { "ARTICLE III" }
                H<4> { "PURPOSE" }
                HTML.Paragraph.Element { "The purpose is to engage in any lawful activity." }
            }
        }

        let bytes = [UInt8](doc)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "articles-of-incorporation-test.pdf"
        )
        try Data(bytes).write(to: url)
        print("DEBUG TEST: PDF written to: \(url.path)")

        #expect(doc.outline != nil, "Document should have outline")

        if let outline = doc.outline {
            print("DEBUG TEST: Final outline structure:")
            printOutlineItems(outline.items, indent: 0)

            let hasArticlesTitle = containsTitle(
                outline.items,
                "ARTICLES OF INCORPORATION OF TEST CORPORATION, INC."
            )
            let hasArticleI = containsTitle(outline.items, "ARTICLE I")
            let hasArticleII = containsTitle(outline.items, "ARTICLE II")
            let hasArticleIII = containsTitle(outline.items, "ARTICLE III")

            #expect(hasArticlesTitle, "Outline should contain 'ARTICLES OF INCORPORATION'")
            #expect(hasArticleI, "Outline should contain 'ARTICLE I'")
            #expect(hasArticleII, "Outline should contain 'ARTICLE II'")
            #expect(hasArticleIII, "Outline should contain 'ARTICLE III'")
        }
    }
}

private func printOutlineItems(_ items: [ISO_32000.Outline.Item], indent: Int) {
    let prefix = String(repeating: "  ", count: indent)
    for item in items {
        print("\(prefix)- \(item.title)")
        if !item.children.isEmpty {
            printOutlineItems(item.children, indent: indent + 1)
        }
    }
}

private func containsTitle(_ items: [ISO_32000.Outline.Item], _ title: String) -> Bool {
    for item in items {
        if item.title == title {
            return true
        }
        if containsTitle(item.children, title) {
            return true
        }
    }
    return false
}

@Suite
struct `Single vs Multiple H1 Diagnostic Tests` {

    @Test
    func `Single H1 with H3 children - check if parent shows`() throws {
        let doc = PDF.Document(
            info: .init(title: "Single H1 Parent Test"),
            generateOutline: true
        ) {

            HTML.H1.Element { "DOCUMENT TITLE" }

            HTML.Section.Element {
                HTML.H3.Element { "Section 1" }
                HTML.Paragraph.Element { "Content for section 1." }
            }

            HTML.Section.Element {
                HTML.H3.Element { "Section 2" }
                HTML.Paragraph.Element { "Content for section 2." }
            }

            HTML.Section.Element {
                HTML.H3.Element { "Section 3" }
                HTML.Paragraph.Element { "Content for section 3." }
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "single-h1-parent-test.pdf"
        )
        try Data([UInt8](doc)).write(to: url)
        print("Single H1 PDF written to: \(url.path)")

        if let outline = doc.outline {
            print("Single H1 outline structure:")
            printOutlineItems(outline.items, indent: 0)
            print("Top-level items count: \(outline.items.count)")
        }
    }

    @Test
    func `Multiple H1s - check if all parents show`() throws {
        let doc = PDF.Document(
            info: .init(title: "Multiple H1 Parents Test"),
            generateOutline: true
        ) {

            HTML.H1.Element { "FIRST DOCUMENT" }

            HTML.Section.Element {
                HTML.H3.Element { "First Section 1" }
                HTML.Paragraph.Element { "Content." }
            }

            HTML.Section.Element {
                HTML.H3.Element { "First Section 2" }
                HTML.Paragraph.Element { "Content." }
            }

            HTML.H1.Element { "SECOND DOCUMENT" }

            HTML.Section.Element {
                HTML.H3.Element { "Second Section 1" }
                HTML.Paragraph.Element { "Content." }
            }

            HTML.Section.Element {
                HTML.H3.Element { "Second Section 2" }
                HTML.Paragraph.Element { "Content." }
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "multiple-h1-parents-test.pdf"
        )
        try Data([UInt8](doc)).write(to: url)
        print("Multiple H1 PDF written to: \(url.path)")

        if let outline = doc.outline {
            print("Multiple H1 outline structure:")
            printOutlineItems(outline.items, indent: 0)
            print("Top-level items count: \(outline.items.count)")
        }
    }
}
