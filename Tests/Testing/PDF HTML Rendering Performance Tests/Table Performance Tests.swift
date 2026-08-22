import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

extension PDF {
    #Tests
}

private func render<V: HTML.View>(_ view: V) {
    let document = PDF.Document {
        HTML.Document { view }
    }
    let _ = [UInt8](document)
}

extension PDF.Test.Performance {

    @Test(.timed(iterations: 20, warmup: 3))
    func `simple table 5x10`() {
        render(SimpleTable5x10())
    }

    @Test(.timed(iterations: 10, warmup: 2))
    func `simple table 10x50`() {
        render(SimpleTable10x50())
    }

    @Test(.timed(iterations: 5, warmup: 1))
    func `simple table 10x100`() {
        render(SimpleTable10x100())
    }

    @Test(.timed(iterations: 20, warmup: 3))
    func `simple table 10x1`() {
        render(SimpleTable10x1())
    }

    @Test(.timed(iterations: 20, warmup: 3))
    func `simple table 10x2`() {
        render(SimpleTable10x2())
    }

    @Test(.timed(iterations: 20, warmup: 3))
    func `simple table 10x5`() {
        render(SimpleTable10x5())
    }

    @Test(.timed(iterations: 20, warmup: 3))
    func `simple table 10x10`() {
        render(SimpleTable10x10())
    }

    @Test(.timed(iterations: 10, warmup: 2))
    func `simple table 10x25`() {
        render(SimpleTable10x25())
    }

    @Test(.timed(iterations: 10, warmup: 2))
    func `table with rowspan 30 rows`() {
        render(RowspanTable30())
    }

    @Test(.timed(iterations: 5, warmup: 1))
    func `complex table mixed spans`() {
        render(ComplexTable30())
    }

    @Test(.timed(iterations: 500, warmup: 50))
    func `throughput single table 5x10`() {
        render(SimpleTable5x10())
    }

    @Test(.timed(iterations: 10, warmup: 2))
    func `simple table 5x30`() {
        render(SimpleTable5x30())
    }
}

private struct SimpleTable5x10: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "H1" }
                    HTML.TableHeader.Element { "H2" }
                    HTML.TableHeader.Element { "H3" }
                    HTML.TableHeader.Element { "H4" }
                    HTML.TableHeader.Element { "H5" }
                }
            }
            HTML.TableBody.Element {
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
            }
        }
    }
}

private struct Row5: HTML.View {
    var body: some HTML.View {
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "C1" }
            HTML.TableDataCell.Element { "C2" }
            HTML.TableDataCell.Element { "C3" }
            HTML.TableDataCell.Element { "C4" }
            HTML.TableDataCell.Element { "C5" }
        }
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

private struct Header10: HTML.View {
    var body: some HTML.View {
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

private struct SimpleTable10x1: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element { Row10() }
        }
    }
}

private struct SimpleTable10x2: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element {
                Row10()
                Row10()
            }
        }
    }
}

private struct SimpleTable10x5: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element {
                Row10()
                Row10()
                Row10()
                Row10()
                Row10()
            }
        }
    }
}

private struct SimpleTable10x10: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element { Rows10x10() }
        }
    }
}

private struct SimpleTable10x25: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element {
                Rows10x10()
                Rows10x10()
                Row10()
                Row10()
                Row10()
                Row10()
                Row10()
            }
        }
    }
}

private struct SimpleTable10x50: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element {
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
            }
        }
    }
}

private struct SimpleTable10x100: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element { Header10() }
            HTML.TableBody.Element {
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
                Rows10x10()
            }
        }
    }
}

private struct SimpleTable5x30: HTML.View {
    var body: some HTML.View {
        HTML.Table.Element {
            HTML.TableHead.Element {
                HTML.TableRow.Element {
                    HTML.TableHeader.Element { "H1" }
                    HTML.TableHeader.Element { "H2" }
                    HTML.TableHeader.Element { "H3" }
                    HTML.TableHeader.Element { "H4" }
                    HTML.TableHeader.Element { "H5" }
                }
            }
            HTML.TableBody.Element {
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
                Row5()
            }
        }
    }
}

private struct RowspanGroup: HTML.View {
    var body: some HTML.View {
        HTML.TableRow.Element {
            HTML.TableHeader.Element(rowspan: 3) { "Group" }
            HTML.TableDataCell.Element { "Item 1" }
            HTML.TableDataCell.Element { "100" }
        }
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "Item 2" }
            HTML.TableDataCell.Element { "200" }
        }
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "Item 3" }
            HTML.TableDataCell.Element { "300" }
        }
    }
}

private struct RowspanTable30: HTML.View {
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
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
                RowspanGroup()
            }
        }
    }
}

private struct ComplexGroup: HTML.View {
    var body: some HTML.View {
        HTML.TableRow.Element {
            HTML.TableHeader.Element(rowspan: 3) { "Group" }
            HTML.TableDataCell.Element { "Sub A" }
            HTML.TableDataCell.Element { "Val A" }
            HTML.TableDataCell.Element { "OK" }
        }
        HTML.TableRow.Element {
            HTML.TableDataCell.Element { "Sub B" }
            HTML.TableDataCell.Element { "Val B" }
            HTML.TableDataCell.Element { "OK" }
        }
        HTML.TableRow.Element {
            HTML.TableDataCell.Element(colspan: 2) { "Combined" }
            HTML.TableDataCell.Element { "OK" }
        }
    }
}

private struct ComplexTable30: HTML.View {
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
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
                ComplexGroup()
            }
            HTML.TableFoot.Element {
                HTML.TableRow.Element {
                    HTML.TableDataCell.Element(colspan: 4) { "Total: 30 items" }
                }
            }
        }
    }
}
