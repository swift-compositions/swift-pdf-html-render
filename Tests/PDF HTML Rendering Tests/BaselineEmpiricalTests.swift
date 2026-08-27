import Byte_Primitive
import Byte_Standard_Library_Integration
import CSS
import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

extension Array where Element == Byte {

    fileprivate func countStrokes() -> Int {
        let s = String(decoding: self, as: UTF8.self)
        return s.components(separatedBy: " S\n").count - 1
    }

    fileprivate func tjPositions() -> [(x: Double, y: Double, text: String)] {
        let s = String(decoding: self, as: UTF8.self)
        var out: [(Double, Double, String)] = []
        let re = /(?<x>-?\d+\.?\d*)\s+(?<y>-?\d+\.?\d*)\s+Td\s*\n?\s*\((?<text>[^)]*)\)\s*Tj/
        for m in s.matches(of: re) {
            let x = Double(m.output.x) ?? .nan
            let y = Double(m.output.y) ?? .nan
            out.append((x, y, String(m.output.text)))
        }
        return out
    }

    fileprivate func absoluteTjPositions() -> [(x: Double, y: Double, text: String)] {
        let s = String(decoding: self, as: UTF8.self)
        var out: [(Double, Double, String)] = []
        var x = 0.0
        var y = 0.0
        var inBT = false
        let tdRe = /^\s*(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+Td\s*$/
        let tjRe = /^\s*\(([^)]*)\)\s*Tj\s*$/
        for rawLine in s.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line == "BT" {
                inBT = true
                x = 0
                y = 0
                continue
            }
            if line == "ET" {
                inBT = false
                continue
            }
            guard inBT else { continue }
            if let m = try? tdRe.wholeMatch(in: rawLine) {
                x += Double(m.output.1) ?? 0
                y += Double(m.output.2) ?? 0
                continue
            }
            if let m = try? tjRe.wholeMatch(in: rawLine) {
                out.append((x, y, String(m.output.1)))
            }
        }
        return out
    }
}

private func pageBytes(_ pages: [PDF.Page]) -> [Byte] {
    Array(pages.flatMap { $0.contents }.flatMap { $0.data })
}

@Suite
struct `Baseline Empirical Tests` {

    @Test
    func `default cell content baseline is at top of cell padding-inset area`() throws {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "ANCHOR" }
                    }
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let positions = bytes.tjPositions()
        let pos = positions.first { $0.text.contains("ANCHOR") }
        try #require(pos != nil, "ANCHOR text should appear in content stream")

        #expect(
            pos!.y > 740,
            "Cell content baseline Y should be near top of page (top-aligned default); got y=\(pos!.y)"
        )
    }

    @Test
    func `td width percent 100 yields proportional column allocation`() throws {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "LEFT" }.css.width(.percent(100))
                        HTML.TableDataCell.Element { "RIGHT" }
                    }
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let positions = bytes.tjPositions()
        let leftPos = positions.first { $0.text.contains("LEFT") }
        let rightPos = positions.first { $0.text.contains("RIGHT") }
        try #require(
            leftPos != nil && rightPos != nil,
            "Both LEFT and RIGHT should appear in content stream"
        )

        #expect(
            rightPos!.x > 270,
            "RIGHT column's relative x-offset from LEFT (\(rightPos!.x)) should exceed 270pt under A.1' weighted allocation; equal-width would give ~226pt"
        )
    }

    @Test
    func `default border-collapse draws shared cell edges (fewer strokes than separate)`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "A" }
                            HTML.TableDataCell.Element { "B" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "C" }
                            HTML.TableDataCell.Element { "D" }
                        }
                    }
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let strokes = bytes.countStrokes()
        #expect(
            strokes < 14,
            "Default border-collapse mode should emit fewer strokes than .separate (16+); got \(strokes)"
        )
    }

    @Test
    func `configuration with table border width 0 produces zero border strokes`() {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "X" }
                            HTML.TableDataCell.Element { "Y" }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Z" }
                            HTML.TableDataCell.Element { "W" }
                        }
                    }
                }
            }
        }
        var config = PDF.HTML.Configuration()
        config.table.border.width = 0
        let bytes = pageBytes(PDF.HTML.pages(configuration: config) { TestView() })
        let strokes = bytes.countStrokes()
        #expect(
            strokes == 0,
            "Setting table.border.width = 0 should suppress all border strokes; got \(strokes)"
        )
    }

    @Test
    func `discriminating: isolated 2-col table cells render side-by-side`() throws {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "ALPHA" }.css.width(.percent(60))
                        HTML.TableDataCell.Element { "BETA" }.css.width(.percent(40))
                    }
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let positions = bytes.tjPositions()
        let alpha = positions.first { $0.text.contains("ALPHA") }
        let beta = positions.first { $0.text.contains("BETA") }
        try #require(
            alpha != nil && beta != nil,
            "Both ALPHA and BETA should appear in content stream"
        )

        #expect(
            beta!.x > 50,
            "Discriminating test: BETA's relative x-offset from ALPHA (\(beta!.x)) should be > 50pt if cells are side-by-side (case A → H2 confirmed); near 0 if vertically stacked (case B → H1 confirmed). ALPHA pos = (\(alpha!.x), \(alpha!.y)); BETA pos = (\(beta!.x), \(beta!.y))."
        )
    }

    @Test
    func `white-space nowrap suppresses wrap-on-overflow line-breaks`() throws {
        struct WideText: HTML.View {
            let nowrap: Bool
            var body: some HTML.View {
                HTML.Paragraph.Element {
                    "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                }
                .css.whiteSpace(nowrap ? .nowrap : .normal)
            }
        }
        let normalBytes = pageBytes(PDF.HTML.pages { WideText(nowrap: false) })
        let nowrapBytes = pageBytes(PDF.HTML.pages { WideText(nowrap: true) })
        let normalLineBreaks = normalBytes.tjPositions().filter { $0.y < 0 }.count
        let nowrapLineBreaks = nowrapBytes.tjPositions().filter { $0.y < 0 }.count
        #expect(
            normalLineBreaks > 0,
            "Long text under .normal should wrap (at least one Td with y < 0); got \(normalLineBreaks)"
        )
        #expect(
            nowrapLineBreaks == 0,
            "Long text under .nowrap should NOT wrap (no Td with y < 0); got \(nowrapLineBreaks)"
        )
    }

    @Test
    func `outer table css width(.percent(100)) does not collapse layout box`() throws {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "LEFT" }.css.width(.percent(100))
                        HTML.TableDataCell.Element { "RIGHT" }
                    }
                }
                .css.width(.percent(100))
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let positions = bytes.tjPositions()
        let right = positions.first { $0.text.contains("RIGHT") }
        try #require(right != nil, "RIGHT should appear in content stream")

        #expect(
            right!.x > 270,
            "Outer `<table>.css.width(.percent(100))` must NOT collapse the table to ~11pt; got RIGHT.x=\(right!.x)"
        )
    }

    @Test
    func `sibling tables: second table column-width hints reach their state`() throws {
        struct TestView: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "A1" }.css.width(.percent(60))
                        HTML.TableDataCell.Element { "B1" }.css.width(.percent(40))
                    }
                }
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "A2" }.css.width(.percent(60))
                        HTML.TableDataCell.Element { "B2" }.css.width(.percent(40))
                    }
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { TestView() })
        let positions = bytes.tjPositions()
        let b1 = positions.first { $0.text.contains("B1") }
        let b2 = positions.first { $0.text.contains("B2") }
        try #require(b1 != nil, "Sibling 1: B1 should appear in content stream")
        try #require(b2 != nil, "Sibling 2: B2 should appear in content stream")
        #expect(
            b1!.x > 50,
            "Sibling 1 (no leakage source): B1 x-offset \(b1!.x) should exceed 50pt — confirms isolated column layout works"
        )
        #expect(
            b2!.x > 50,
            "Sibling 2 (leakage target): B2 x-offset \(b2!.x) should exceed 50pt — if state-stack leaks, Table 2's width hints don't reach its allocator and B2 collapses near 0"
        )
        #expect(
            abs(b1!.x - b2!.x) < 5,
            "Sibling tables 1 & 2 with identical width hints should yield identical column allocations; got B1.x=\(b1!.x), B2.x=\(b2!.x)"
        )
    }

    @Test
    func `Void elements before sibling cell do not nil context.table`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element {
                            HTML.Tag.Element(tag: "b") { "LBOLD" }
                            HTML.Tag.Element<Never>(tag: "br")
                            "L1"
                            HTML.Tag.Element<Never>(tag: "br")
                            "L2"
                            HTML.Tag.Element<Never>(tag: "br")
                            "L3"
                            HTML.Tag.Element<Never>(tag: "br")
                            "L4"
                            HTML.Tag.Element<Never>(tag: "br")
                            HTML.Table.Element {
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "" }
                                    HTML.TableDataCell.Element { "" }
                                }
                            }
                        }.css.verticalAlign(.top).width(.percent(100))
                        HTML.TableDataCell.Element {
                            HTML.Tag.Element(tag: "h3") { "HEADING" }
                        }.css.verticalAlign(.top)
                    }
                }
                .css.width(.percent(100))
                .borderCollapse(.collapse)
            }
        }

        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let lbold = positions.first { $0.text.contains("LBOLD") }
        let heading = positions.first { $0.text.contains("HEADING") }
        try #require(lbold != nil, "LBOLD must appear in content stream")
        try #require(heading != nil, "HEADING must appear in content stream")

        #expect(
            abs(lbold!.y - heading!.y) < 25,
            "h3 absolute y (\(heading!.y)) must align with top of right cell, near LBOLD (\(lbold!.y)) — pre-fix bug placed it ~130pt below"
        )

        #expect(
            heading!.x > lbold!.x + 100,
            "h3 absolute x (\(heading!.x)) must render in right column, well right of LBOLD (\(lbold!.x))"
        )
    }

    @Test
    func `C-11: nested-table mid-row break does not force next block to new page`() throws {
        struct V: HTML.View {
            var body: some HTML.View {

                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F01" }
                        HTML.TableDataCell.Element { "v01" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F02" }
                        HTML.TableDataCell.Element { "v02" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F03" }
                        HTML.TableDataCell.Element { "v03" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F04" }
                        HTML.TableDataCell.Element { "v04" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F05" }
                        HTML.TableDataCell.Element { "v05" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F06" }
                        HTML.TableDataCell.Element { "v06" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F07" }
                        HTML.TableDataCell.Element { "v07" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F08" }
                        HTML.TableDataCell.Element { "v08" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F09" }
                        HTML.TableDataCell.Element { "v09" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F10" }
                        HTML.TableDataCell.Element { "v10" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F11" }
                        HTML.TableDataCell.Element { "v11" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F12" }
                        HTML.TableDataCell.Element { "v12" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F13" }
                        HTML.TableDataCell.Element { "v13" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F14" }
                        HTML.TableDataCell.Element { "v14" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F15" }
                        HTML.TableDataCell.Element { "v15" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F16" }
                        HTML.TableDataCell.Element { "v16" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F17" }
                        HTML.TableDataCell.Element { "v17" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F18" }
                        HTML.TableDataCell.Element { "v18" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F19" }
                        HTML.TableDataCell.Element { "v19" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F20" }
                        HTML.TableDataCell.Element { "v20" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F21" }
                        HTML.TableDataCell.Element { "v21" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F22" }
                        HTML.TableDataCell.Element { "v22" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F23" }
                        HTML.TableDataCell.Element { "v23" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F24" }
                        HTML.TableDataCell.Element { "v24" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F25" }
                        HTML.TableDataCell.Element { "v25" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F26" }
                        HTML.TableDataCell.Element { "v26" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F27" }
                        HTML.TableDataCell.Element { "v27" }
                    }
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "F28" }
                        HTML.TableDataCell.Element { "v28" }
                    }
                }
                HTML.Tag.Element<Never>(tag: "hr")

                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { HTML.Empty() }.css.width(.percent(100))
                        HTML.TableDataCell.Element {
                            HTML.Table.Element {
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "Bedrag" }
                                    HTML.TableDataCell.Element { "€ 6000" }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "BTW" }
                                    HTML.TableDataCell.Element { "€ 1260" }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "TOTALMARKER" }
                                    HTML.TableDataCell.Element { "€ 7260" }
                                }
                            }
                        }
                    }
                }.css.borderCollapse(.collapse)
                HTML.Tag.Element<Never>(tag: "br")
                HTML.Tag.Element<Never>(tag: "br")
                HTML.Paragraph.Element { "AFTER_PAYMENT_MARKER" }
            }
        }

        let config = PDF.HTML.Configuration(margins: .init(all: 72))
        let pages = PDF.HTML.pages(configuration: config) { V() }

        var totalPage: Int?
        var afterPage: Int?
        for (i, page) in pages.enumerated() {
            let pb = Array(page.contents.flatMap { $0.data })
            let positions = pb.tjPositions()
            if positions.contains(where: { $0.text.contains("TOTALMARKER") }) {
                totalPage = i + 1
            }
            if positions.contains(where: { $0.text.contains("AFTER_PAYMENT_MARKER") }) {
                afterPage = i + 1
            }
        }
        try #require(totalPage != nil, "TOTALMARKER missing")
        try #require(afterPage != nil, "AFTER_PAYMENT_MARKER missing")
        #expect(
            afterPage! == totalPage!,
            "C-11: AFTER_PAYMENT_MARKER (page \(afterPage!)) must land on the same page where TOTALMARKER (page \(totalPage!)) ended; pre-fix bug forced it to a new page via stale rowStartY in popTableRow"
        )
    }

    @Test
    func `Width constraint does not leak into descendant box-model resolution`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "LEFT" }
                            .css.verticalAlign(.top).width(.percent(100))
                        HTML.TableDataCell.Element {
                            HTML.Tag.Element(tag: "h3") { "RIGHT" }
                                .css.margin(top: 0).margin(bottom: 0)
                                .textAlign(.right)
                        }.css.verticalAlign(.top)
                    }
                }
                .css.width(.percent(100))
                .borderCollapse(.collapse)
            }
        }
        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let right = positions.first { $0.text.contains("RIGHT") }
        try #require(right != nil, "RIGHT must appear in content stream")

        #expect(
            right!.x < 595,
            "RIGHT absolute x (\(right!.x)) must be on-page — pre-fix bug rendered descendants past A4 right edge due to constraint.width leak from outer .css.width(.percent(100)) ancestor"
        )

        let left = positions.first { $0.text.contains("LEFT") }
        try #require(left != nil, "LEFT must appear in content stream")
        #expect(
            right!.x > left!.x + 100,
            "RIGHT (\(right!.x)) must render in right column, well right of LEFT (\(left!.x))"
        )
    }

    @Test
    func `C-E1: nested 2-col table cells render side-by-side`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "OUTER_LEFT" }
                        HTML.TableDataCell.Element {
                            HTML.Table.Element {
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "LABEL1" }
                                    HTML.TableDataCell.Element { "VALUE1" }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { "LABEL2" }
                                    HTML.TableDataCell.Element { "VALUE2" }
                                }
                            }
                        }
                    }
                }
                .css.borderCollapse(.collapse)
            }
        }
        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let label1 = positions.first { $0.text.contains("LABEL1") }
        let value1 = positions.first { $0.text.contains("VALUE1") }
        let label2 = positions.first { $0.text.contains("LABEL2") }
        let value2 = positions.first { $0.text.contains("VALUE2") }
        try #require(label1 != nil, "LABEL1 must appear in content stream")
        try #require(value1 != nil, "VALUE1 must appear in content stream")
        try #require(label2 != nil, "LABEL2 must appear in content stream")
        try #require(value2 != nil, "VALUE2 must appear in content stream")

        #expect(
            abs(label1!.y - value1!.y) < 2,
            "C-E1 row 1: LABEL1.y (\(label1!.y)) and VALUE1.y (\(value1!.y)) must share the same baseline (Δy < 2pt). If Δy is large, the bug stacks cells vertically inside nested tables."
        )
        #expect(
            value1!.x > label1!.x + 30,
            "C-E1 row 1: VALUE1.x (\(value1!.x)) must be well right of LABEL1.x (\(label1!.x)) — clear horizontal layout (Δx > 30pt). If Δx ~ 0, cells collapsed to a single column."
        )

        #expect(
            abs(label2!.y - value2!.y) < 2,
            "C-E1 row 2: LABEL2.y (\(label2!.y)) and VALUE2.y (\(value2!.y)) must share the same baseline (Δy < 2pt)."
        )
        #expect(
            value2!.x > label2!.x + 30,
            "C-E1 row 2: VALUE2.x (\(value2!.x)) must be well right of LABEL2.x (\(label2!.x)) — Δx > 30pt."
        )

        #expect(
            label1!.y > label2!.y,
            "C-E1 inner-row ordering: row 1 baseline (\(label1!.y)) must be above row 2 baseline (\(label2!.y))."
        )
    }

    @Test
    func `C-E2: row height stable across rows with same visible content shape`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "OUTER_LEFT" }.css.verticalAlign(.top)
                        HTML.TableDataCell.Element {
                            HTML.Table.Element {
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "L1" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "alpha beta gamma delta" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "L2" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "no-spaces-here" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "L3" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "still-no-spaces" }
                                    }
                                }
                            }
                            .css.borderCollapse(.collapse)
                        }.css.verticalAlign(.top)
                    }
                }
                .css.borderCollapse(.collapse).width(.percent(100))
            }
        }
        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let l1 = positions.first { $0.text == "L1" }
        let l2 = positions.first { $0.text == "L2" }
        let l3 = positions.first { $0.text == "L3" }
        try #require(l1 != nil, "L1 must appear in content stream")
        try #require(l2 != nil, "L2 must appear in content stream")
        try #require(l3 != nil, "L3 must appear in content stream")

        let gap12 = abs(l1!.y - l2!.y)
        let gap23 = abs(l2!.y - l3!.y)

        #expect(
            abs(gap12 - gap23) < 3,
            "C-E2: row 1→2 gap (\(gap12)) should equal row 2→3 gap (\(gap23)) — both rows have single-line visible content. Δ > 3pt indicates value-with-whitespace inflates row height (factuur-21 anomaly reproduced). Pos: L1=(\(l1!.x),\(l1!.y)) L2=(\(l2!.x),\(l2!.y)) L3=(\(l3!.x),\(l3!.y))."
        )
    }

    @Test
    func `C-E3: row height stable after preceding multi-line br-stack row`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "OUTER_LEFT" }.css.verticalAlign(.top)
                        HTML.TableDataCell.Element {
                            HTML.Table.Element {

                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Empty() }
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "ADDR1" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                        HTML.Tag.Element(tag: "small") { "ADDR2" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                        HTML.Tag.Element(tag: "small") { "ADDR3" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                    }
                                }

                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M1" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "value one two three" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M2" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "nospaces-here" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M3" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "anothernospaces" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M4" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "fourthrow" } }
                                }
                            }
                            .css.borderCollapse(.collapse)
                        }.css.verticalAlign(.top)
                    }
                }
                .css.borderCollapse(.collapse).width(.percent(100))
            }
        }
        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let m1 = positions.first { $0.text == "M1" }
        let m2 = positions.first { $0.text == "M2" }
        let m3 = positions.first { $0.text == "M3" }
        let m4 = positions.first { $0.text == "M4" }
        try #require(m1 != nil, "M1 must appear")
        try #require(m2 != nil, "M2 must appear")
        try #require(m3 != nil, "M3 must appear")
        try #require(m4 != nil, "M4 must appear")
        let gap12 = abs(m1!.y - m2!.y)
        let gap23 = abs(m2!.y - m3!.y)
        let gap34 = abs(m3!.y - m4!.y)

        #expect(
            abs(gap12 - gap23) < 3,
            "C-E3: row 1→2 gap (\(gap12)) vs row 2→3 gap (\(gap23)). Δ > 3 means the first metadata row inherits extra height — anomaly reproduced. M1=(\(m1!.x),\(m1!.y)) M2=(\(m2!.x),\(m2!.y)) M3=(\(m3!.x),\(m3!.y)) M4=(\(m4!.x),\(m4!.y))."
        )
        #expect(
            abs(gap23 - gap34) < 3,
            "C-E3: row 2→3 gap (\(gap23)) vs row 3→4 gap (\(gap34)) should match."
        )
    }

    @Test
    func `C-E4: Letter.Header + Letter.Sender exact-shape replica`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "RECIPIENT" }
                            .css.verticalAlign(.top).width(.percent(100))
                        HTML.TableDataCell.Element {
                            HTML.Tag.Element(tag: "h3") { "SENDER_NAME" }
                                .css.margin(top: 0).margin(bottom: 0).textAlign(.right)
                            HTML.Table.Element {
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Empty() }
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "ADDR1" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                        HTML.Tag.Element(tag: "small") { "ADDR2" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                        HTML.Tag.Element(tag: "small") { "ADDR3" }
                                        HTML.Tag.Element<Never>(tag: "br")
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M1" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "v one two three" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M2" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "nospaces" } }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M3" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element {
                                        HTML.Tag.Element(tag: "small") { "anothernospaces" }
                                    }
                                }
                                HTML.TableRow.Element {
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "M4" } }
                                        .css.textAlign(.right).verticalAlign(.top).padding(
                                            right: .px(10)
                                        )
                                    HTML.TableDataCell.Element { HTML.Tag.Element(tag: "small") { "fourthrow" } }
                                }
                            }
                            .css.borderCollapse(.collapse)
                        }.css.verticalAlign(.top)
                    }
                }
                .css.width(.percent(100)).borderCollapse(.collapse)
            }
        }
        let positions = pageBytes(PDF.HTML.pages { V() }).absoluteTjPositions()
        let m1 = positions.first { $0.text == "M1" }
        let m2 = positions.first { $0.text == "M2" }
        let m3 = positions.first { $0.text == "M3" }
        let m4 = positions.first { $0.text == "M4" }
        try #require(m1 != nil, "M1 must appear")
        try #require(m2 != nil, "M2 must appear")
        try #require(m3 != nil, "M3 must appear")
        try #require(m4 != nil, "M4 must appear")
        let gap12 = abs(m1!.y - m2!.y)
        let gap23 = abs(m2!.y - m3!.y)
        let gap34 = abs(m3!.y - m4!.y)
        #expect(
            abs(gap12 - gap23) < 3,
            "C-E4: row M1→M2 gap (\(gap12)) vs M2→M3 gap (\(gap23)). Δ > 3 means factuur-21 anomaly reproduced in synthetic Letter.Header+Letter.Sender shape. M1=(\(m1!.x),\(m1!.y)) M2=(\(m2!.x),\(m2!.y)) M3=(\(m3!.x),\(m3!.y)) M4=(\(m4!.x),\(m4!.y))."
        )
        #expect(
            abs(gap23 - gap34) < 3,
            "C-E4: row M2→M3 gap (\(gap23)) vs M3→M4 gap (\(gap34)) should match."
        )
    }

    @Test
    func `C-E5: paragraph wraps despite nowrap child in middle`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Paragraph.Element {
                    "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                    HTML.Text("NOWRAP_TOKEN").css.whiteSpace(.nowrap)
                    " Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
                }
            }
        }
        let bytes = pageBytes(PDF.HTML.pages { V() })
        let lineBreaks = bytes.tjPositions().filter { $0.y < 0 }.count
        #expect(
            lineBreaks >= 2,
            "Paragraph with nowrap child in middle must still wrap at line boundaries; got \(lineBreaks) line-breaks (Tj with y<0). The nowrap child's mode mutation should be scoped to the child, not leak to the whole paragraph."
        )
    }

    @Test
    func `css.borderBottom on TR emits one horizontal stroke at row bottom`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "TOPCELL" }
                    }.css.borderBottom(.init(.px(1), .solid, .hex("000000")))
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "BOTTOMCELL" }
                    }
                }.css.borderCollapse(.separate)
            }
        }
        var config = PDF.HTML.Configuration()
        config.table.border.width = 0
        let bytes = pageBytes(PDF.HTML.pages(configuration: config) { V() })

        let s = String(decoding: bytes + [0x0A], as: UTF8.self)
        let strokes = s.components(separatedBy: "\nS\n").count - 1
        #expect(
            strokes == 1,
            "border-bottom on TR should emit exactly one horizontal stroke at the row's bottom edge; got \(strokes) strokes"
        )
    }

    @Test
    func `css.borderBottom with double style emits two parallel strokes`() throws {
        struct V: HTML.View {
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableRow.Element {
                        HTML.TableDataCell.Element { "CELL" }
                            .css.borderBottom(.init(.px(3), .double, .hex("000000")))
                    }
                }.css.borderCollapse(.separate)
            }
        }
        var config = PDF.HTML.Configuration()
        config.table.border.width = 0
        let bytes = pageBytes(PDF.HTML.pages(configuration: config) { V() })

        let s = String(decoding: bytes + [0x0A], as: UTF8.self)
        let strokes = s.components(separatedBy: "\nS\n").count - 1
        #expect(
            strokes == 2,
            "border-style: double should emit two parallel strokes (line + gap + line); got \(strokes)"
        )
    }
}
