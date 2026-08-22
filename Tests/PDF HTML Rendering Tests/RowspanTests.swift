import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

@Suite
struct `Rowspan Tests` {

    @Test
    func `rowspan cell content should appear inside cell`() throws {
        struct MinimalRowspanTable: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element(rowspan: 2) { "Spanning" }
                            HTML.TableDataCell.Element { "Row 1 Data" }
                        }
                        HTML.TableRow.Element {

                            HTML.TableDataCell.Element { "Row 2 Data" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document {
                MinimalRowspanTable()
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rowspan-minimal-test.pdf"
        )
        try Data([UInt8](document)).write(to: url)

        print("Minimal rowspan test PDF written to: \(url.path)")
    }

    @Test
    func `multiple rowspan cells content positioning`() throws {
        struct MultipleRowspanTable: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableHead.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element { "Category" }
                            HTML.TableHeader.Element { "Item" }
                            HTML.TableHeader.Element { "Value" }
                        }
                    }
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element(rowspan: 2) { "Group A" }
                            HTML.TableDataCell.Element { "Item 1" }
                            HTML.TableDataCell.Element { "100" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Item 2" }
                            HTML.TableDataCell.Element { "200" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element(rowspan: 3) { "Group B" }
                            HTML.TableDataCell.Element { "Item 3" }
                            HTML.TableDataCell.Element { "300" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Item 4" }
                            HTML.TableDataCell.Element { "400" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Item 5" }
                            HTML.TableDataCell.Element { "500" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document {
                MultipleRowspanTable()
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rowspan-multiple-test.pdf"
        )
        try Data([UInt8](document)).write(to: url)

        print("Multiple rowspan test PDF written to: \(url.path)")
    }

    @Test
    func `table without rowspan renders correctly`() throws {
        struct SimpleTable: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element { "Header 1" }
                            HTML.TableHeader.Element { "Header 2" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Data 1" }
                            HTML.TableDataCell.Element { "Data 2" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document {
                SimpleTable()
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rowspan-control-test.pdf"
        )
        try Data([UInt8](document)).write(to: url)

        print("Control test (no rowspan) PDF written to: \(url.path)")
    }

    @Test
    func `rowspan with thead colspan and tfoot`() throws {
        struct ComplexTable: HTML.View {
            var body: some HTML.View {
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
                            HTML.TableDataCell.Element { "OK" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Lists" }
                            HTML.TableDataCell.Element { "Full support" }
                            HTML.TableDataCell.Element { "OK" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element(rowspan: 3) { "Typography" }
                            HTML.TableDataCell.Element { "Headings" }
                            HTML.TableDataCell.Element { "H1-H6" }
                            HTML.TableDataCell.Element { "OK" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Inline styles" }
                            HTML.TableDataCell.Element { "Bold, italic" }
                            HTML.TableDataCell.Element { "OK" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Links" }
                            HTML.TableDataCell.Element { "Clickable" }
                            HTML.TableDataCell.Element { "OK" }
                        }
                    }
                    HTML.TableFoot.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element(colspan: 4) { "All features implemented" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document {
                ComplexTable()
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rowspan-complex-test.pdf"
        )
        try Data([UInt8](document)).write(to: url)

        print("Complex rowspan test (matching 6.6) PDF written to: \(url.path)")
    }
}
