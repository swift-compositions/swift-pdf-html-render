import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering_Test_Support

@Suite
struct `Iterative Tuple Tests` {

    private func render<V: HTML.View>(_ view: V) -> [UInt8] {
        let document = PDF.Document {
            HTML.Document { view }
        }
        return [UInt8](document)
    }

    @Test
    func `10x10 table renders without stack overflow`() {
        let bytes = render(Table10x10())
        #expect(!bytes.isEmpty)
    }

    @Test
    func `10x30 table renders without stack overflow`() {
        let bytes = render(Table10x30())
        #expect(!bytes.isEmpty)
    }

    @Test
    func `5-column styled table renders without stack overflow`() {
        let bytes = render(StyledTable5x10())
        #expect(!bytes.isEmpty)
    }

    @Test
    func `30-element flat view body renders without stack overflow`() {
        let bytes = render(FlatView30())
        #expect(!bytes.isEmpty)
    }

    @Test
    func `50-element flat view body renders without stack overflow`() {
        let bytes = render(FlatView50())
        #expect(!bytes.isEmpty)
    }
}

private struct Row10: HTML.View {
    var body: some HTML.View {
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "C1" }
            HTML.TableDataCell.Element { "C2" }
            HTML.TableDataCell.Element { "C3" }
            HTML.TableDataCell.Element { "C4" }
            HTML.TableDataCell.Element { "C5" }
            HTML.TableDataCell.Element { "C6" }
            HTML.TableDataCell.Element { "C7" }
            HTML.TableDataCell.Element { "C8" }
            HTML.TableDataCell.Element { "C9" }
            HTML.TableDataCell.Element { "C10" }
        }
    }
}

private struct Rows10x10: HTML.View {
    var body: some HTML.View {
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
        Row10()
    }
}

private struct Table10x10: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "H1" }
                    HTML.TableHeader.Element { "H2" }
                    HTML.TableHeader.Element { "H3" }
                    HTML.TableHeader.Element { "H4" }
                    HTML.TableHeader.Element { "H5" }
                    HTML.TableHeader.Element { "H6" }
                    HTML.TableHeader.Element { "H7" }
                    HTML.TableHeader.Element { "H8" }
                    HTML.TableHeader.Element { "H9" }
                    HTML.TableHeader.Element { "H10" }
                }
            }
            HTML.TableBody.Element {
                Rows10x10()
            }
        }
    }
}

private struct Table10x30: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "H1" }
                    HTML.TableHeader.Element { "H2" }
                    HTML.TableHeader.Element { "H3" }
                    HTML.TableHeader.Element { "H4" }
                    HTML.TableHeader.Element { "H5" }
                    HTML.TableHeader.Element { "H6" }
                    HTML.TableHeader.Element { "H7" }
                    HTML.TableHeader.Element { "H8" }
                    HTML.TableHeader.Element { "H9" }
                    HTML.TableHeader.Element { "H10" }
                }
            }
            HTML.TableBody.Element {
                Rows10x10()
                Rows10x10()
                Rows10x10()
            }
        }
    }
}

private struct StyledTable5x10: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "Name" }
                    HTML.TableHeader.Element { "Age" }
                    HTML.TableHeader.Element { "City" }
                    HTML.TableHeader.Element { "Role" }
                    HTML.TableHeader.Element { "Status" }
                }
            }
            HTML.TableBody.Element {
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
                StyledRow5()
            }
        }
    }
}

private struct StyledRow5: HTML.View {
    var body: some HTML.View {
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "Alice" }
            HTML.TableDataCell.Element { "30" }
            HTML.TableDataCell.Element { "Amsterdam" }
            HTML.TableDataCell.Element { "Engineer" }
            HTML.TableDataCell.Element { "Active" }
        }
    }
}

private struct FlatView30: HTML.View {
    var body: some HTML.View {
        HTML.Paragraph.Element { "Line 1" }
        HTML.Paragraph.Element { "Line 2" }
        HTML.Paragraph.Element { "Line 3" }
        HTML.Paragraph.Element { "Line 4" }
        HTML.Paragraph.Element { "Line 5" }
        HTML.Paragraph.Element { "Line 6" }
        HTML.Paragraph.Element { "Line 7" }
        HTML.Paragraph.Element { "Line 8" }
        HTML.Paragraph.Element { "Line 9" }
        HTML.Paragraph.Element { "Line 10" }
        HTML.Paragraph.Element { "Line 11" }
        HTML.Paragraph.Element { "Line 12" }
        HTML.Paragraph.Element { "Line 13" }
        HTML.Paragraph.Element { "Line 14" }
        HTML.Paragraph.Element { "Line 15" }
        HTML.Paragraph.Element { "Line 16" }
        HTML.Paragraph.Element { "Line 17" }
        HTML.Paragraph.Element { "Line 18" }
        HTML.Paragraph.Element { "Line 19" }
        HTML.Paragraph.Element { "Line 20" }
        HTML.Paragraph.Element { "Line 21" }
        HTML.Paragraph.Element { "Line 22" }
        HTML.Paragraph.Element { "Line 23" }
        HTML.Paragraph.Element { "Line 24" }
        HTML.Paragraph.Element { "Line 25" }
        HTML.Paragraph.Element { "Line 26" }
        HTML.Paragraph.Element { "Line 27" }
        HTML.Paragraph.Element { "Line 28" }
        HTML.Paragraph.Element { "Line 29" }
        HTML.Paragraph.Element { "Line 30" }
    }
}

private struct FlatView50: HTML.View {
    var body: some HTML.View {
        FlatView30()
        HTML.Paragraph.Element { "Line 31" }
        HTML.Paragraph.Element { "Line 32" }
        HTML.Paragraph.Element { "Line 33" }
        HTML.Paragraph.Element { "Line 34" }
        HTML.Paragraph.Element { "Line 35" }
        HTML.Paragraph.Element { "Line 36" }
        HTML.Paragraph.Element { "Line 37" }
        HTML.Paragraph.Element { "Line 38" }
        HTML.Paragraph.Element { "Line 39" }
        HTML.Paragraph.Element { "Line 40" }
        HTML.Paragraph.Element { "Line 41" }
        HTML.Paragraph.Element { "Line 42" }
        HTML.Paragraph.Element { "Line 43" }
        HTML.Paragraph.Element { "Line 44" }
        HTML.Paragraph.Element { "Line 45" }
        HTML.Paragraph.Element { "Line 46" }
        HTML.Paragraph.Element { "Line 47" }
        HTML.Paragraph.Element { "Line 48" }
        HTML.Paragraph.Element { "Line 49" }
        HTML.Paragraph.Element { "Line 50" }
    }
}
