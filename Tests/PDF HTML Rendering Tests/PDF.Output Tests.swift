import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

@Suite
struct `PDFOutput Tests` {
    @Test
    func `Writes Basic HTMLTo PDF`() throws {
        struct SampleDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "HTML to PDF Test Document" }

                    HTML.Paragraph.Element {
                        "This document demonstrates basic HTML to PDF rendering."
                    }

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
            HTML.Document {
                SampleDocument()
            }
        }

        let bytes = [UInt8](document)
        let path = try PDFOutput.write(bytes, name: "basic-html")

        print("PDF written to: \(path)")
        #expect(!bytes.isEmpty)
    }

    @Test
    func `Writes Table To PDF`() throws {
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
            HTML.Document {
                TableDocument()
            }
        }

        let bytes = [UInt8](document)
        let path = try PDFOutput.write(bytes, name: "table")

        print("PDF written to: \(path)")
        #expect(!bytes.isEmpty)
    }

    @Test
    func `Writes Multi Page To PDF`() throws {
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
            HTML.Document {
                MultiPageDocument()
            }
        }

        let bytes = [UInt8](document)
        let path = try PDFOutput.write(bytes, name: "multi-page")

        print("PDF written to: \(path)")
        #expect(!bytes.isEmpty)
    }

    @Test
    func `Writes Styled HTMLTo PDF`() throws {
        struct StyledDocument: HTML.View {
            var body: some HTML.View {
                HTML.ContentDivision.Element {
                    HTML.H1.Element { "Styled Document" }
                        .css
                        .color(.hex("#333"))

                    HTML.Paragraph.Element {
                        "This paragraph has custom styling applied."
                    }
                    .css
                    .padding(.px(10))
                    .backgroundColor(.hex("#f0f0f0"))

                    HTML.ContentDivision.Element {
                        HTML.Paragraph.Element { "Box with border" }
                    }
                    .css

                    .padding(.px(20))
                    .margin(.px(10))
                }
            }
        }

        let document = PDF.Document {
            HTML.Document {
                StyledDocument()
            }
        }

        let bytes = [UInt8](document)
        let path = try PDFOutput.write(bytes, name: "styled")

        print("PDF written to: \(path)")
        #expect(!bytes.isEmpty)
    }
}
