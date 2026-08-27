import HTML_Rendering
import PDF_HTML_Rendering
import PDF_Rendering
import Test_Snapshot
import Testing
import Tests_Inline_Snapshot

@Suite
struct `PDFOutput Snapshot Tests` {
    @Suite struct Snapshot {}
}

extension PDFOutputSnapshotTests.Snapshot {
    @Test
    func `basic HTML`() {
        struct SampleDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "HTML to PDF Test Document" }
                    HTML.Paragraph.Element { "This document demonstrates basic HTML to PDF rendering." }

                    HTML.H2.Element { "Text Formatting" }
                    HTML.Paragraph.Element {
                        "Normal text with "
                        HTML.StrongImportance.Element { "bold" }
                        " and "
                        HTML.Emphasis.Element { "italic" }
                        " formatting."
                    }

                    HTML.H2.Element { "Lists" }
                    HTML.UnorderedList.Element {
                        HTML.ListItem.Element { "First item" }
                        HTML.ListItem.Element { "Second item" }
                        HTML.ListItem.Element { "Third item" }
                    }

                    HTML.H2.Element { "Ordered List" }
                    HTML.OrderedList.Element {
                        HTML.ListItem.Element { "Step one" }
                        HTML.ListItem.Element { "Step two" }
                        HTML.ListItem.Element { "Step three" }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { SampleDocument() }
        }

        snapshot(as: .pdf, named: "basic-html") { document }
    }

    @Test
    func `table`() {
        struct TableDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "Table Test" }
                    HTML.Table.Element {
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
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TableDocument() }
        }

        snapshot(as: .pdf, named: "table") { document }
    }

    @Test
    func `multi-page`() {
        struct MultiPageDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "Multi-Page Document" }
                    for i in 1...30 {
                        HTML.Paragraph.Element {
                            "Paragraph \(i): This is some sample content that helps fill the page. When enough paragraphs accumulate, the content will flow onto subsequent pages. This tests the page break handling in the HTML to PDF renderer."
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { MultiPageDocument() }
        }

        snapshot(as: .pdf, named: "multi-page") { document }
    }

    @Test
    func `styled HTML`() {
        struct StyledDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "Styled Document" }
                        .css.color(.hex("#333"))
                    HTML.Paragraph.Element { "This paragraph has custom styling applied." }
                        .css.padding(.px(10)).backgroundColor(.hex("#f0f0f0"))
                    HTML.ContentDivision.Element {
                        HTML.Paragraph.Element { "Box with border" }
                    }
                    .css.padding(.px(20)).margin(.px(10))
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { StyledDocument() }
        }

        snapshot(as: .pdf, named: "styled-html") { document }
    }
}
