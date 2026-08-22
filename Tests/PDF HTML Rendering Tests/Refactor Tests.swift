import CSS
import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

@Suite
struct `PDF.HTML.View Tests` {

    @Test
    func `String transforms to PDF content`() {
        let html = "Hello, World!"
        let pages = PDF.HTML.pages {
            html
        }

        #expect(pages.count >= 1)
    }

    @Test
    func `Paragraph transforms with spacing`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "Test paragraph" }
            }
        }

        let pages = PDF.HTML.pages(configuration: .init(), content: TestView.init)

        #expect(pages.count >= 1)
        #expect(!pages[0].contents.isEmpty)
    }

    @Test
    func `Heading transforms`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.H1.Element { "Big Heading" }
            }
        }

        let pages = PDF.HTML.pages(configuration: .init(), content: TestView.init)
        #expect(pages.count >= 1)
        #expect(!pages[0].contents.isEmpty)
    }

    @Test
    func `Inline elements render together`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element {
                    "Normal "
                    HTML.StrongImportance.Element { "bold" }
                    " normal"
                }
            }
        }

        let pages = PDF.HTML.pages(configuration: .init(), content: TestView.init)
        #expect(pages.count >= 1)

        let contentData = pages[0].contents.first?.data ?? []
        let contentString = String(decoding: contentData, as: UTF8.self)
        #expect(contentString.contains("Normal"))
        #expect(contentString.contains("bold"))
    }

    @Test
    func `PDF.Document can be created from HTML`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.H1.Element { "Title" }
                HTML.Paragraph.Element { "Content" }
            }
        }

        let doc = PDF.Document(info: .init(title: "Test")) {
            TestView()
        }

        #expect(doc.pages.count >= 1)
        #expect(doc.info?.title == "Test")
    }

    @Test
    func `PDF bytes can be generated from HTML`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "Hello PDF" }
            }
        }

        let doc = PDF.Document { TestView() }
        let bytes = [UInt8](doc)

        #expect(!bytes.isEmpty)
        #expect(bytes.starts(with: [.ascii.percentSign, .ascii.P, .ascii.D, .ascii.F]))
    }

    @Test
    func `Configuration affects heading sizes`() {
        let config = PDF.HTML.Configuration(defaultFontSize: 14)

        #expect(config.headingSize(level: 1) == 28)
        #expect(config.headingSize(level: 2) == 21)
        #expect(config.headingSize(level: 3) == config.defaultFontSize * 1.17)
    }

    @Test
    func `Configuration affects content dimensions`() {
        let config = PDF.HTML.Configuration(
            paperSize: .a4,
            margins: .init(top: 72, leading: 72, bottom: 72, trailing: 72)
        )

        #expect(abs(config.content.width - (PDF.UserSpace.Rectangle.a4.width - 144)) < 0.001)
        #expect(abs(config.content.height - (PDF.UserSpace.Rectangle.a4.height - 144)) < 0.001)
    }
}

@Suite
struct `Sticky Header Tests` {

    @Test
    func `Basic sticky header document renders`() {
        struct TestView: HTML.View {
            var body: some HTML.View {

                HTML.Paragraph.Element { "Filler 1" }
                HTML.Paragraph.Element { "Filler 2" }
                HTML.Paragraph.Element { "Filler 3" }
                HTML.Paragraph.Element { "Filler 4" }
                HTML.Paragraph.Element { "Filler 5" }
                HTML.Paragraph.Element { "Filler 6" }
                HTML.Paragraph.Element { "Filler 7" }
                HTML.Paragraph.Element { "Filler 8" }
                HTML.Paragraph.Element { "Filler 9" }
                HTML.Paragraph.Element { "Filler 10" }
                HTML.Paragraph.Element { "Filler 11" }
                HTML.Paragraph.Element { "Filler 12" }
                HTML.Paragraph.Element { "Filler 13" }
                HTML.Paragraph.Element { "Filler 14" }
                HTML.Paragraph.Element { "Filler 15" }
                HTML.Paragraph.Element { "Filler 16" }
                HTML.Paragraph.Element { "Filler 17" }
                HTML.Paragraph.Element { "Filler 18" }
                HTML.Paragraph.Element { "Filler 19" }
                HTML.Paragraph.Element { "Filler 20" }
                HTML.Paragraph.Element { "Filler 21" }
                HTML.Paragraph.Element { "Filler 22" }
                HTML.Paragraph.Element { "Filler 23" }
                HTML.Paragraph.Element { "Filler 24" }
                HTML.Paragraph.Element { "Filler 25" }
                HTML.Paragraph.Element { "Filler 26" }
                HTML.Paragraph.Element { "Filler 27" }
                HTML.Paragraph.Element { "Filler 28" }
                HTML.Paragraph.Element { "Filler 29" }
                HTML.Paragraph.Element { "Filler 30" }
                HTML.Paragraph.Element { "Filler 31" }
                HTML.Paragraph.Element { "Filler 32" }
                HTML.Paragraph.Element { "Filler 33" }
                HTML.Paragraph.Element { "Filler 34" }
                HTML.Paragraph.Element { "Filler 35" }
                HTML.Paragraph.Element { "Filler 36" }
                HTML.Paragraph.Element { "Filler 37" }
                HTML.Paragraph.Element { "Filler 38" }
                HTML.Paragraph.Element { "Filler 39" }
                HTML.Paragraph.Element { "Filler 40" }

                HTML.H2.Element { "STICKY_HEADER" }
                    .css.pageBreakAfter(.avoid)

                HTML.Paragraph.Element { "FOLLOWING_CONTENT" }
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        #expect(pages.count >= 1)

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("STICKY_HEADER"))
        #expect(contentString.contains("FOLLOWING_CONTENT"))
    }

    @Test
    func `Sticky header at document end renders`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element { "Some content" }

                HTML.H2.Element { "ORPHAN_HEADER" }
                    .css.pageBreakAfter(.avoid)
            }
        }

        let pages = PDF.HTML.pages { TestView() }

        let allContent = pages.flatMap { $0.contents }.flatMap { $0.data }
        let contentString = String(decoding: allContent, as: UTF8.self)
        #expect(contentString.contains("ORPHAN_HEADER"), "Orphan sticky header should be rendered")
    }
}

@Suite
struct `Comprehensive PDF.HTML.View Tests` {

    @Test
    func `document showing all elements and properties with outline`() throws {
        let doc = PDF.Document(
            info: .init(
                title: "All Elements Demo",
                author: "Test Suite"
            ),
            generateOutline: true
        ) {
            ComplexView()
        }

        let bytes = [UInt8](doc)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "html-to-pdf-refactor-test.pdf"
        )
        try Data(bytes).write(to: url)
        print("PDF written to: \(url.path)")

        #expect(doc.pages.count >= 1)
        #expect(bytes.count > 1000, "Complex document should have substantial content")

        #expect(doc.outline != nil, "Document should have outline/bookmarks")
        if let outline = doc.outline {
            #expect(!outline.items.isEmpty, "Outline should have items from H1-H6 headings")
        }
    }

    @Test
    func `document with nested collapsible outline structure`() throws {
        let doc = PDF.Document(
            info: .init(
                title: "Technical Specification",
                author: "Test Suite"
            ),
            generateOutline: true
        ) {
            TechnicalSpecificationView()
        }

        let bytes = [UInt8](doc)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "nested-outline-test.pdf"
        )
        try Data(bytes).write(to: url)
        print("PDF with nested outline written to: \(url.path)")

        #expect(doc.pages.count >= 1)

        #expect(doc.outline != nil, "Document should have outline/bookmarks")

        if let outline = doc.outline {

            print("Outline structure:")
            printOutline(outline.items, indent: 0)

            #expect(!outline.items.isEmpty, "Outline should have top-level items")
        }
    }
}

private func printOutline(_ items: [ISO_32000.Outline.Item], indent: Int) {
    let prefix = String(repeating: "  ", count: indent)
    for item in items {
        print("\(prefix)- \(item.title)")
        if !item.children.isEmpty {
            printOutline(item.children, indent: indent + 1)
        }
    }
}

private struct TechnicalSpecificationView: HTML.View {
    var body: some HTML.View {

        HTML.H1.Element { "Technical Specification XYZ-2024" }
            .css.textAlign(.center)
        HTML.Paragraph.Element { "A comprehensive guide to the XYZ standard." }

        HTML.H1.Element { "1 Scope" }
        HTML.Paragraph.Element { "This document specifies the requirements for XYZ systems." }

        HTML.H1.Element { "2 Normative references" }
        HTML.Paragraph.Element { "The following documents are referred to in the text." }

        HTML.H1.Element { "3 Terms and definitions" }
        HTML.Paragraph.Element { "For the purposes of this document, the following terms apply." }

        HTML.H1.Element { "4 Notation" }
        HTML.Paragraph.Element { "This section describes the notation used throughout the document." }

        HTML.H2.Element { "4.1 General" }
        HTML.Paragraph.Element { "General notation conventions are described here." }

        HTML.H2.Element { "4.2 Established notations" }
        HTML.Paragraph.Element { "Industry-standard notations that are adopted." }

        HTML.H2.Element { "4.3 Special symbols" }
        HTML.Paragraph.Element { "Special symbols used in this specification." }

        HTML.H3.Element { "4.3.1 Mathematical symbols" }
        HTML.Paragraph.Element { "Symbols used for mathematical expressions." }

        HTML.H3.Element { "4.3.2 Logical symbols" }
        HTML.Paragraph.Element { "Symbols used for logical operations." }

        HTML.H1.Element { "5 Version designations" }
        HTML.Paragraph.Element { "How versions are designated in this standard." }

        HTML.H1.Element { "6 Conformance" }
        HTML.Paragraph.Element { "Requirements for conformance to this specification." }

        HTML.H2.Element { "6.1 Conformance levels" }
        HTML.Paragraph.Element { "Different levels of conformance are defined." }

        HTML.H3.Element { "6.1.1 Basic conformance" }
        HTML.Paragraph.Element { "Minimum requirements for basic conformance." }

        HTML.H3.Element { "6.1.2 Full conformance" }
        HTML.Paragraph.Element { "Requirements for full conformance." }

        HTML.H4.Element { "6.1.2.1 Mandatory features" }
        HTML.Paragraph.Element { "Features that must be implemented." }

        HTML.H4.Element { "6.1.2.2 Optional features" }
        HTML.Paragraph.Element { "Features that may optionally be implemented." }

        HTML.H2.Element { "6.2 Conformance testing" }
        HTML.Paragraph.Element { "How conformance is verified." }

        HTML.H1.Element { "7 Syntax" }
        HTML.Paragraph.Element { "The syntax of the XYZ language." }

        HTML.H2.Element { "7.1 Lexical elements" }
        HTML.Paragraph.Element { "Basic lexical elements of the language." }

        HTML.H2.Element { "7.2 Expressions" }
        HTML.Paragraph.Element { "How expressions are formed." }

        HTML.H2.Element { "7.3 Statements" }
        HTML.Paragraph.Element { "Statement syntax and semantics." }

        HTML.H1.Element { "8 Graphics" }
        HTML.Paragraph.Element { "Graphics capabilities of the system." }

        HTML.H2.Element { "8.1 Coordinate systems" }
        HTML.Paragraph.Element { "How coordinates are specified." }

        HTML.H2.Element { "8.2 Transformations" }
        HTML.Paragraph.Element { "Geometric transformations supported." }

        HTML.H1.Element { "9 Text" }
        HTML.Paragraph.Element { "Text handling capabilities." }

        HTML.H2.Element { "9.1 General" }
        HTML.Paragraph.Element { "Overview of text handling." }

        HTML.H2.Element { "9.2 Organisation and use of fonts" }
        HTML.Paragraph.Element { "How fonts are organized and used." }

        HTML.H3.Element { "9.2.1 Font types" }
        HTML.Paragraph.Element { "Different types of fonts supported." }

        HTML.H3.Element { "9.2.2 Font embedding" }
        HTML.Paragraph.Element { "How fonts are embedded in documents." }

        HTML.H2.Element { "9.3 Text state parameters and operators" }
        HTML.Paragraph.Element { "Parameters that control text rendering." }

        HTML.H2.Element { "9.4 Text objects" }
        HTML.Paragraph.Element { "How text objects are defined." }

        HTML.H2.Element { "9.5 Introduction to font data structures" }
        HTML.Paragraph.Element { "Overview of font data structures." }

        HTML.H2.Element { "9.6 Simple fonts" }
        HTML.Paragraph.Element { "Simple font types and their properties." }

        HTML.H3.Element { "9.6.1 Type 1 fonts" }
        HTML.Paragraph.Element { "Adobe Type 1 font format." }

        HTML.H3.Element { "9.6.2 TrueType fonts" }
        HTML.Paragraph.Element { "TrueType font format." }

        HTML.H2.Element { "9.7 Composite fonts" }
        HTML.Paragraph.Element { "Composite font architecture." }

        HTML.H2.Element { "9.8 Font descriptors" }
        HTML.Paragraph.Element { "Metadata about fonts." }

        HTML.H1.Element { "Annex A (normative) Implementation notes" }
        HTML.Paragraph.Element { "Notes for implementers of this specification." }

        HTML.H1.Element { "Annex B (informative) Examples" }
        HTML.Paragraph.Element { "Example implementations and use cases." }

        HTML.H2.Element { "B.1 Basic example" }
        HTML.Paragraph.Element { "A simple example demonstrating core features." }

        HTML.H2.Element { "B.2 Advanced example" }
        HTML.Paragraph.Element { "A complex example showing advanced features." }
    }
}

struct ComplexView: HTML.View {
    var body: some HTML.View {
        TextStylingDemo()
        LinksDemo()
        BlockElementsDemo()
        ListsDemo()
        HeadingsDemo()
        TableDemo()
        DescriptionListDemo()
        SemanticDemo()
        FigureDemo()
        NestedListDemo()
        InlineStyleDemo()
        HTML.Paragraph.Element { HTML.Emphasis.Element { "End of demo." } }
        NDADemo()
    }
}

private struct TextStylingDemo: HTML.View {
    var body: some HTML.View {
        HTML.H1.Element { "All HTML Elements Demo" }
        HTML.H2.Element { "1. Text Styling" }
        HTML.Paragraph.Element {
            "Normal, "
            HTML.StrongImportance.Element { "bold" }
            ", "
            HTML.Emphasis.Element { "italic" }
            ", "
            HTML.Code.Element { "code" }
            "."
        }
        HTML.Paragraph.Element {
            HTML.Mark.Element { "highlighted" }
            ", "
            HTML.Strikethrough.Element { "strikethrough" }
            ", "
            HTML.UnarticulatedAnnotation.Element { "underline" }
            "."
        }
        HTML.Paragraph.Element {
            "H"
            HTML.Subscript.Element { "2" }
            "O, E=mc"
            HTML.Superscript.Element { "2" }
            "."
        }
        HTML.Paragraph.Element {
            "Read "
            HTML.Cite.Element { "1984" }
            " by George Orwell."
        }
        HTML.Paragraph.Element {
            "Press "
            HTML.KeyboardInput.Element { "Ctrl+C" }
            " to copy."
        }
        HTML.Paragraph.Element {
            "Output: "
            HTML.Samp.Element { "Hello, World!" }
        }
        HTML.Paragraph.Element {
            "Let "
            HTML.Variable.Element { "x" }
            " = 5."
        }
        HTML.Paragraph.Element {
            "The "
            HTML.Definition.Element { "DOM" }
            " is the Document Object Model."
        }
        HTML.Paragraph.Element {
            "The "
            HTML.Abbreviation.Element { "HTML" }
            " specification."
        }
        HTML.Paragraph.Element {
            "She said, "
            HTML.InlineQuotation.Element { "Hello!" }
        }
        HTML.Paragraph.Element {
            "Line 1"
            HTML.BR.Element()
            "Line 2 (after BR)"
        }
        HTML.Paragraph.Element {
            "Meeting at "
            HTML.Time.Element { "2024-01-15" }
            "."
        }
    }
}

private struct LinksDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "2. Links" }
        HTML.Paragraph.Element {
            "Visit "
            HTML.Anchor.Element(href: "https://example.com") { "Example Website" }
            " for more info."
        }
        HTML.Paragraph.Element {
            "Contact: "
            HTML.Anchor.Element(href: "mailto:test@example.com") { "test@example.com" }
        }
    }
}

private struct BlockElementsDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "3. Block Elements" }
        HTML.BlockQuote.Element {
            HTML.Paragraph.Element { "This is a block quotation." }
        }
        HTML.PreformattedText.Element {
            "func hello() {\n    print(\"Hello\")\n}"
        }

    }
}

private struct ListsDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "4. Lists" }
            .css.pageBreakAfter(.avoid)

        HTML.H3.Element { "4.1 Simple Unordered List" }
            .css.pageBreakAfter(.avoid)

        HTML.UnorderedList.Element {
            HTML.ListItem.Element { "First bullet point" }
            HTML.ListItem.Element { "Second bullet point" }
            HTML.ListItem.Element { "Third bullet point" }
        }

        HTML.H3.Element { "4.2 Simple Ordered List" }
        HTML.OrderedList.Element {
            HTML.ListItem.Element { "First numbered item" }
            HTML.ListItem.Element { "Second numbered item" }
            HTML.ListItem.Element { "Third numbered item" }
        }

        HTML.H3.Element { "4.3 List Items with Wrapping Text" }
        HTML.OrderedList.Element {
            HTML.ListItem.Element {
                "This is a longer list item that should wrap to multiple lines to test how the list marker aligns with multi-line content in an ordered list."
            }
            HTML.ListItem.Element {
                "Another lengthy item with sufficient text to cause line wrapping and verify proper indentation is maintained throughout."
            }
            HTML.ListItem.Element { "Short item." }
        }

        HTML.H3.Element { "4.4 List Items with Inline Formatting" }
        HTML.UnorderedList.Element {
            HTML.ListItem.Element {
                HTML.StrongImportance.Element { "Bold text" }
                " followed by normal text"
            }
            HTML.ListItem.Element {
                "Normal text with "
                HTML.Emphasis.Element { "italic" }
                " in the middle"
            }
            HTML.ListItem.Element {
                HTML.Code.Element { "inline code" }
                " mixed with regular text"
            }
            HTML.ListItem.Element {
                "Link: "
                HTML.Anchor.Element(href: "https://example.com") { "Example Website" }
            }
        }

        HTML.H3.Element { "4.5 Nested Lists" }
        HTML.UnorderedList.Element {
            HTML.ListItem.Element { "Level 1 - Item A" }
            HTML.ListItem.Element {
                "Level 1 - Item B with nested list:"
                HTML.UnorderedList.Element {
                    HTML.ListItem.Element { "Level 2 - Nested item 1" }
                    HTML.ListItem.Element { "Level 2 - Nested item 2" }
                    HTML.ListItem.Element {
                        "Level 2 - Item with deeper nesting:"
                        HTML.UnorderedList.Element {
                            HTML.ListItem.Element { "Level 3 - Deep nested item" }
                        }
                    }
                }
            }
            HTML.ListItem.Element { "Level 1 - Item C" }
        }

        HTML.H3.Element { "4.6 Mixed Nested Lists" }
        HTML.OrderedList.Element {
            HTML.ListItem.Element { "First main item" }
            HTML.ListItem.Element {
                "Second main item with sub-points:"
                HTML.UnorderedList.Element {
                    HTML.ListItem.Element { "Sub-point A" }
                    HTML.ListItem.Element { "Sub-point B" }
                    HTML.ListItem.Element { "Sub-point C" }
                }
            }
            HTML.ListItem.Element {
                "Third main item with numbered sub-items:"
                HTML.OrderedList.Element {
                    HTML.ListItem.Element { "Sub-item 1" }
                    HTML.ListItem.Element { "Sub-item 2" }
                }
            }
        }

        HTML.H3.Element { "4.7 List with Many Items" }
        HTML.OrderedList.Element {
            HTML.ListItem.Element { "Item one" }
            HTML.ListItem.Element { "Item two" }
            HTML.ListItem.Element { "Item three" }
            HTML.ListItem.Element { "Item four" }
            HTML.ListItem.Element { "Item five" }
            HTML.ListItem.Element { "Item six" }
            HTML.ListItem.Element { "Item seven" }
            HTML.ListItem.Element { "Item eight" }
            HTML.ListItem.Element { "Item nine" }
            HTML.ListItem.Element { "Item ten" }
            HTML.ListItem.Element { "Item eleven" }
            HTML.ListItem.Element { "Item twelve" }
        }

        HTML.H3.Element { "4.8 List Spacing" }
        HTML.Paragraph.Element {
            "This paragraph comes before a list. There should be appropriate spacing between this text and the list below."
        }
        HTML.UnorderedList.Element {
            HTML.ListItem.Element { "First item after paragraph" }
            HTML.ListItem.Element { "Second item" }
        }
        HTML.Paragraph.Element {
            "This paragraph comes after the list. Spacing should also be appropriate here."
        }

        HTML.H3.Element { "4.9 Single Item Lists" }
        HTML.UnorderedList.Element {
            HTML.ListItem.Element { "Only item in unordered list" }
        }
        HTML.OrderedList.Element {
            HTML.ListItem.Element { "Only item in ordered list" }
        }
    }
}

private struct HeadingsDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "5. Headings" }
        HTML.H1.Element { "H1" }
        HTML.H2.Element { "H2" }
        HTML.H3.Element { "H3" }
        HTML.H4.Element { "H4" }
        HTML.H5.Element { "H5" }
        HTML.H6.Element { "H6" }
    }
}

private struct TableDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "6. Tables" }
            .css.pageBreakAfter(.avoid)

        HTML.H3.Element { "6.1 Simple Data Table" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.Caption.Element { "Employee Directory" }
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Name" }
                    HTML.TableHeader.Element { "Age" }
                    HTML.TableHeader.Element { "City" }
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Alice" }
                    HTML.TableDataCell.Element { "30" }
                    HTML.TableDataCell.Element { "New York" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Bob" }
                    HTML.TableDataCell.Element { "25" }
                    HTML.TableDataCell.Element { "Los Angeles" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Charlie" }
                    HTML.TableDataCell.Element { "35" }
                    HTML.TableDataCell.Element { "Chicago" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Diana" }
                    HTML.TableDataCell.Element { "28" }
                    HTML.TableDataCell.Element { "Houston" }
                }
            }
        }

        HTML.H3.Element { "6.2 Product Inventory" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "SKU" }
                    HTML.TableHeader.Element { "Product Name" }
                    HTML.TableHeader.Element { "Category" }
                    HTML.TableHeader.Element { "Price" }
                    HTML.TableHeader.Element { "Stock" }
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "A001" }
                    HTML.TableDataCell.Element { "Wireless Mouse" }
                    HTML.TableDataCell.Element { "Electronics" }
                    HTML.TableDataCell.Element { "$29.99" }
                    HTML.TableDataCell.Element { "150" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "A002" }
                    HTML.TableDataCell.Element { "USB-C Hub" }
                    HTML.TableDataCell.Element { "Electronics" }
                    HTML.TableDataCell.Element { "$49.99" }
                    HTML.TableDataCell.Element { "75" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "B001" }
                    HTML.TableDataCell.Element { "Ergonomic Chair" }
                    HTML.TableDataCell.Element { "Furniture" }
                    HTML.TableDataCell.Element { "$299.00" }
                    HTML.TableDataCell.Element { "25" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "B002" }
                    HTML.TableDataCell.Element { "Standing Desk" }
                    HTML.TableDataCell.Element { "Furniture" }
                    HTML.TableDataCell.Element { "$450.00" }
                    HTML.TableDataCell.Element { "12" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "C001" }
                    HTML.TableDataCell.Element { "Notebook Set" }
                    HTML.TableDataCell.Element { "Office Supplies" }
                    HTML.TableDataCell.Element { "$12.99" }
                    HTML.TableDataCell.Element { "500" }
                }
            }
        }

        HTML.H3.Element { "6.3 Table with Formatted Content" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Feature" }
                    HTML.TableHeader.Element { "Status" }
                    HTML.TableHeader.Element { "Notes" }
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element {
                        HTML.StrongImportance.Element { "Authentication" }
                    }
                    HTML.TableDataCell.Element { "Complete" }
                    HTML.TableDataCell.Element {
                        "Supports "
                        HTML.Code.Element { "OAuth 2.0" }
                        " and "
                        HTML.Code.Element { "JWT" }
                    }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element {
                        HTML.StrongImportance.Element { "API Gateway" }
                    }
                    HTML.TableDataCell.Element { "In Progress" }
                    HTML.TableDataCell.Element {
                        HTML.Emphasis.Element { "Expected Q2 2025" }
                    }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element {
                        HTML.StrongImportance.Element { "Dashboard" }
                    }
                    HTML.TableDataCell.Element { "Planned" }
                    HTML.TableDataCell.Element { "See roadmap for details" }
                }
            }
        }

        HTML.H3.Element { "6.4 Financial Summary with Footer" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Quarter" }
                    HTML.TableHeader.Element { "Revenue" }
                    HTML.TableHeader.Element { "Expenses" }
                    HTML.TableHeader.Element { "Profit" }
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Q1 2024" }
                    HTML.TableDataCell.Element { "$125,000" }
                    HTML.TableDataCell.Element { "$95,000" }
                    HTML.TableDataCell.Element { "$30,000" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Q2 2024" }
                    HTML.TableDataCell.Element { "$142,000" }
                    HTML.TableDataCell.Element { "$98,000" }
                    HTML.TableDataCell.Element { "$44,000" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Q3 2024" }
                    HTML.TableDataCell.Element { "$158,000" }
                    HTML.TableDataCell.Element { "$102,000" }
                    HTML.TableDataCell.Element { "$56,000" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Q4 2024" }
                    HTML.TableDataCell.Element { "$175,000" }
                    HTML.TableDataCell.Element { "$110,000" }
                    HTML.TableDataCell.Element { "$65,000" }
                }
            }
            HTML.TableFoot.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Total" }
                    HTML.TableDataCell.Element { "$600,000" }
                    HTML.TableDataCell.Element { "$405,000" }
                    HTML.TableDataCell.Element {
                        HTML.StrongImportance.Element { "$195,000" }
                    }
                }
            }
        }

        HTML.H3.Element { "6.5 Key-Value Table" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Version" }
                    HTML.TableDataCell.Element { "2.4.1" }
                }
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Release Date" }
                    HTML.TableDataCell.Element { "December 10, 2024" }
                }
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "License" }
                    HTML.TableDataCell.Element { "MIT" }
                }
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Author" }
                    HTML.TableDataCell.Element { "Coen ten Thije Boonkkamp" }
                }
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Repository" }
                    HTML.TableDataCell.Element { "github.com/coenttb/swift-pdf-html-rendering" }
                }
            }
        }

        HTML.H3.Element { "6.6 Colspan/Rowspan Table" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Category" }
                    HTML.TableHeader.Element(colspan: 2) { "Details" }
                    HTML.TableHeader.Element { "Status" }
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element(rowspan: 2) { "Rendering" }
                    HTML.TableDataCell.Element { "Tables" }
                    HTML.TableDataCell.Element { "Full support" }
                    HTML.TableDataCell.Element { "✓" }
                }
                HTML.TableRow.Element {

                    HTML.TableDataCell.Element { "Lists" }
                    HTML.TableDataCell.Element { "Full support" }
                    HTML.TableDataCell.Element { "✓" }
                }
                HTML.TableRow.Element {
                    HTML.TableHeader.Element(rowspan: 3) { "Typography" }
                    HTML.TableDataCell.Element { "Headings" }
                    HTML.TableDataCell.Element { "H1-H6" }
                    HTML.TableDataCell.Element { "✓" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Inline styles" }
                    HTML.TableDataCell.Element { "Bold, italic, etc." }
                    HTML.TableDataCell.Element { "✓" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Links" }
                    HTML.TableDataCell.Element { "Clickable URLs" }
                    HTML.TableDataCell.Element { "✓" }
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element(colspan: 3) { "Combined colspan example spanning three columns" }
                    HTML.TableDataCell.Element { "OK" }
                }
            }
            HTML.TableFoot.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element(colspan: 4) { "All features implemented and tested" }
                }
            }
        }

        HTML.H3.Element { "6.7 Text Alignment (CSS)" }
            .css.pageBreakAfter(.avoid)

        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Product" }
                    HTML.TableHeader.Element { "Quantity" }
                        .css.textAlign(.right)
                    HTML.TableHeader.Element { "Price" }
                        .css.textAlign(.right)
                    HTML.TableHeader.Element { "Total" }
                        .css.textAlign(.right)
                }
            }
            HTML.TableBody.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Widget A" }
                    HTML.TableDataCell.Element { "10" }
                        .css.textAlign(.right)
                    HTML.TableDataCell.Element { "$5.00" }
                        .css.textAlign(.right)
                    HTML.TableDataCell.Element { "$50.00" }
                        .css.textAlign(.right)
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Widget B" }
                    HTML.TableDataCell.Element { "25" }
                        .css.textAlign(.right)
                    HTML.TableDataCell.Element { "$3.50" }
                        .css.textAlign(.right)
                    HTML.TableDataCell.Element { "$87.50" }
                        .css.textAlign(.right)
                }
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element { "Service Fee" }
                    HTML.TableDataCell.Element { "—" }
                        .css.textAlign(.center)
                    HTML.TableDataCell.Element { "—" }
                        .css.textAlign(.center)
                    HTML.TableDataCell.Element { "$15.00" }
                        .css.textAlign(.right)
                }
            }
            HTML.TableFoot.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element(colspan: 3) { "Grand Total" }
                        .css.textAlign(.right)
                    HTML.TableDataCell.Element { "$152.50" }
                        .css.textAlign(.right)
                }
            }
        }
    }
}

private struct DescriptionListDemo: HTML.View {
    var body: some HTML.View {
        HTML.DescriptionList.Element {
            HTML.DescriptionTerm.Element { "HTML" }
            HTML.DescriptionDetails.Element { "HyperText Markup Language" }
            HTML.DescriptionTerm.Element { "CSS" }
            HTML.DescriptionDetails.Element { "Cascading Style Sheets" }
            HTML.DescriptionTerm.Element { "PDF" }
            HTML.DescriptionDetails.Element { "Portable Document Format" }
        }
    }
}

private struct SemanticDemo: HTML.View {
    var body: some HTML.View {
        HTML.Article.Element {
            HTML.Header.Element {
                HTML.H3.Element { "Article Title" }
            }
            HTML.Section.Element {
                HTML.Paragraph.Element { "Main content of the article." }
            }
            HTML.Footer.Element {
                HTML.Paragraph.Element { HTML.Small.Element { "Author: Test Suite" } }
            }
        }
    }
}

private struct FigureDemo: HTML.View {
    var body: some HTML.View {
        HTML.Figure.Element {
            HTML.Paragraph.Element { "[Image placeholder]" }
            HTML.FigureCaption.Element { "Figure 1: Sample figure." }
        }
    }
}

private struct NestedListDemo: HTML.View {
    var body: some HTML.View {
        HTML.UnorderedList.Element {
            HTML.ListItem.Element { "Item 1" }
            HTML.ListItem.Element {
                "Item 2 with nested:"
                HTML.UnorderedList.Element {
                    HTML.ListItem.Element { "Nested 2.1" }
                    HTML.ListItem.Element { "Nested 2.2" }
                }
            }
            HTML.ListItem.Element { "Item 3" }
        }
    }
}

private struct NDADemo: HTML.View {
    var body: some HTML.View {

        HTML.ContentDivision.Element {
            HTML.H1.Element { "NON-DISCLOSURE AGREEMENT" }
                .css.textAlign(.center)
        }
        .css.pageBreakBefore(.always)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "THIS NON-DISCLOSURE AGREEMENT" }
            " (the \"Agreement\") is entered into as of "
            HTML.ContentSpan.Element { "[DATE]" }
                .css.textDecoration(.underline)
            " by and between:"
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "DISCLOSING PARTY:" }
            HTML.BR.Element()
            "[Company Name], a [State] corporation, with its principal place of business at [Address] (\"Discloser\")"
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "RECEIVING PARTY:" }
            HTML.BR.Element()
            "[Recipient Name], an individual/entity located at [Address] (\"Recipient\")"
        }

        HTML.Paragraph.Element {
            "(Discloser and Recipient are collectively referred to as the \"Parties\")"
        }

        HTML.H2.Element { "RECITALS" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "WHEREAS" }
            ", the Discloser possesses certain confidential and proprietary information relating to [describe business/technology/project] (the \"Purpose\"); and"
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "WHEREAS" }
            ", the Recipient desires to receive certain Confidential Information for the Purpose; and"
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "NOW, THEREFORE" }
            ", in consideration of the mutual covenants and agreements set forth herein, and for other good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, the Parties agree as follows:"
        }

        HTML.H2.Element { "ARTICLE 1: DEFINITIONS" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "1.1 \"Confidential Information\"" }
            " means any and all information or data, whether oral, written, electronic, or visual, that is disclosed by the Discloser to the Recipient, including but not limited to:"
        }

        HTML.OrderedList.Element {
            HTML.ListItem.Element {
                "Trade secrets, inventions, ideas, processes, formulas, source code, and software;"
            }
            HTML.ListItem.Element { "Business plans, financial information, and customer lists;" }
            HTML.ListItem.Element { "Technical data, know-how, and research findings;" }
            HTML.ListItem.Element {
                "Any other information designated as \"Confidential\" at the time of disclosure."
            }
        }

        HTML.H2.Element { "ARTICLE 2: OBLIGATIONS OF RECIPIENT" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "2.1 Non-Disclosure." }
            " The Recipient agrees to hold and maintain the Confidential Information in strict confidence and shall not, without the prior written approval of the Discloser:"
        }

        HTML.OrderedList.Element {
            HTML.ListItem.Element { "Disclose any Confidential Information to any third parties;" }
            HTML.ListItem.Element { "Use the Confidential Information for any purpose other than the Purpose;" }
            HTML.ListItem.Element {
                "Copy or reproduce the Confidential Information except as necessary for the Purpose."
            }
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "2.2 Standard of Care." }
            " The Recipient shall protect the Confidential Information using the same degree of care it uses to protect its own confidential information, but in no event less than reasonable care."
        }

        HTML.H2.Element { "ARTICLE 3: TERM AND TERMINATION" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "3.1 Term." }
            " This Agreement shall remain in effect for a period of "
            HTML.ContentSpan.Element { "[NUMBER]" }
                .css.textDecoration(.underline)
            " years from the Effective Date, unless earlier terminated in accordance with this Agreement."
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "3.2 Survival." }
            " The confidentiality obligations under this Agreement shall survive termination and continue for a period of "
            HTML.ContentSpan.Element { "[NUMBER]" }
                .css.textDecoration(.underline)
            " years following termination."
        }

        HTML.H2.Element { "ARTICLE 4: GENERAL PROVISIONS" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "4.1 Governing Law." }
            " This Agreement shall be governed by and construed in accordance with the laws of the State of "
            HTML.ContentSpan.Element { "[STATE]" }
                .css.textDecoration(.underline)
            ", without regard to its conflict of laws principles."
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "4.2 Entire Agreement." }
            " This Agreement constitutes the entire agreement between the Parties with respect to the subject matter hereof and supersedes all prior negotiations, representations, or agreements relating thereto."
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "4.3 Amendments." }
            " This Agreement may not be amended or modified except by a written instrument signed by both Parties."
        }

        HTML.H2.Element { "SIGNATURES" }
            .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "IN WITNESS WHEREOF" }
            ", the Parties have executed this Non-Disclosure Agreement as of the date first written above."
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "DISCLOSER:" }
        }
        .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.BR.Element()
            "________________________________"
            HTML.BR.Element()
            "Name: [Authorized Representative]"
            HTML.BR.Element()
            "Title: [Title]"
            HTML.BR.Element()
            "Date: _______________"
        }

        HTML.Paragraph.Element {
            HTML.StrongImportance.Element { "RECIPIENT:" }
        }
        .css.pageBreakAfter(.avoid)

        HTML.Paragraph.Element {
            HTML.BR.Element()
            "________________________________"
            HTML.BR.Element()
            "Name: [Recipient Name]"
            HTML.BR.Element()
            "Title: [Title]"
            HTML.BR.Element()
            "Date: _______________"
        }
    }
}

private struct InlineStyleDemo: HTML.View {
    var body: some HTML.View {
        HTML.H2.Element { "10. CSS Styling" }
        HTML.Paragraph.Element {
            "Color: "
            HTML.ContentSpan.Element { "red" }
                .css.color(.red)
            ", "
            HTML.ContentSpan.Element { "blue" }
                .css.color(.blue)
            ", "
            HTML.ContentSpan.Element { "green" }
                .css.color(.green)
            "."
        }
        HTML.Paragraph.Element {
            "Background: "
            HTML.ContentSpan.Element { " highlighted " }
                .css.backgroundColor(.yellow)
            " text."
        }
        HTML.Paragraph.Element {
            "Font weight: "
            HTML.ContentSpan.Element { "bold" }
                .css.fontWeight(.bold)
            ", "
            HTML.ContentSpan.Element { "normal" }
                .css.fontWeight(.normal)
            "."
        }
        HTML.Paragraph.Element {
            "Font style: "
            HTML.ContentSpan.Element { "italic" }
                .css.fontStyle(.italic)
            ", "
            HTML.ContentSpan.Element { "normal" }
                .css.fontStyle(.normal)
            "."
        }
        HTML.Paragraph.Element {
            "Font size: "
            HTML.ContentSpan.Element { "small" }
                .css.fontSize(.absoluteSize(.small))
            ", "
            HTML.ContentSpan.Element { "large" }
                .css.fontSize(.absoluteSize(.large))
            ", "
            HTML.ContentSpan.Element { "x-large" }
                .css.fontSize(.absoluteSize(.xLarge))
            "."
        }
        HTML.ContentDivision.Element {
            HTML.Paragraph.Element { "Content in a div." }
        }
    }
}
