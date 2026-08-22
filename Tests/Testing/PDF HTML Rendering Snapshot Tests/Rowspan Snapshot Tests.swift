import HTML_Rendering
import PDF_HTML_Rendering
import PDF_Rendering
import Test_Snapshot_Primitives
import Testing
import Tests_Inline_Snapshot

@Suite
struct `Rowspan Snapshot Tests` {
    @Suite struct Snapshot {}
}

extension RowspanSnapshotTests.Snapshot {
    @Test
    func `minimal rowspan`() {
        let document = PDF.Document {
            HTML.Document {
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

        snapshot(as: .pdf, named: "rowspan-minimal") { document }
    }

    @Test
    func `multiple rowspan cells`() {
        let document = PDF.Document {
            HTML.Document {
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

        snapshot(as: .pdf, named: "rowspan-multiple") { document }
    }

    @Test
    func `table without rowspan`() {
        let document = PDF.Document {
            HTML.Document {
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

        snapshot(as: .pdf, named: "rowspan-control") { document }
    }

    @Test
    func `complex rowspan with colspan and tfoot`() {
        let document = PDF.Document {
            HTML.Document {
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

        snapshot(as: .pdf, named: "rowspan-complex") { document }
    }
}
