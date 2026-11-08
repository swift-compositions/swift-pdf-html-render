import HTML_Rendering_Core
import PDF_Rendering

extension HTML.Tag.Element {

    static func drawCellBorder(
        bounds: PDF.UserSpace.Rectangle,
        tableCtx: PDF.HTML.Context.Table,
        context: inout PDF.HTML.Context
    ) {
        let color = tableCtx.borderColor
        let width = tableCtx.borderWidth.width
        guard tableCtx.borderWidth != .init(0) else { return }

        context.pdf.emit.line(
            from: PDF.UserSpace.Coordinate(x: bounds.llx, y: bounds.lly),
            to: PDF.UserSpace.Coordinate(x: bounds.llx, y: bounds.ury),
            color: color,
            width: width
        )

        context.pdf.emit.line(
            from: PDF.UserSpace.Coordinate(x: bounds.llx, y: bounds.lly),
            to: PDF.UserSpace.Coordinate(x: bounds.urx, y: bounds.lly),
            color: color,
            width: width
        )
    }

    static func drawFragmentRightAndBottomBorders(
        tableCtx: PDF.HTML.Context.Table,
        fragmentStartY: PDF.UserSpace.Y,
        fragmentEndY: PDF.UserSpace.Y,
        context: inout PDF.HTML.Context
    ) {
        guard tableCtx.columnWidths.count > 0 else { return }

        let color = tableCtx.borderColor
        let width = tableCtx.borderWidth.width
        guard tableCtx.borderWidth != .init(0) else { return }
        let tableBounds = tableCtx.bounds

        context.pdf.emit.line(
            from: PDF.UserSpace.Coordinate(x: tableBounds.urx, y: fragmentStartY),
            to: PDF.UserSpace.Coordinate(x: tableBounds.urx, y: fragmentEndY),
            color: color,
            width: width
        )

        context.pdf.emit.line(
            from: PDF.UserSpace.Coordinate(x: tableBounds.llx, y: fragmentEndY),
            to: PDF.UserSpace.Coordinate(x: tableBounds.urx, y: fragmentEndY),
            color: color,
            width: width
        )
    }

    static func drawTableRightAndBottomBorders(
        tableCtx: PDF.HTML.Context.Table,
        context: inout PDF.HTML.Context
    ) {
        drawFragmentRightAndBottomBorders(
            tableCtx: tableCtx,
            fragmentStartY: tableCtx.currentFragmentStartY,
            fragmentEndY: tableCtx.currentFragmentEndY,
            context: &context
        )
    }

    static func drawHorizontalBorder(
        from: PDF.UserSpace.Coordinate,
        to: PDF.UserSpace.Coordinate,
        color: PDF.Color,
        width: PDF.UserSpace.Width,
        style: W3C_CSS_Values.LineStyle,
        context: inout PDF.HTML.Context
    ) {
        switch style {
        case .double:
            let third = width / 3
            let offsetY = third.retag(Extent.Y<UserSpace>.self)
            let topY = from.y - offsetY
            let bottomY = from.y + offsetY
            context.pdf.emit.line(
                from: PDF.UserSpace.Coordinate(x: from.x, y: topY),
                to: PDF.UserSpace.Coordinate(x: to.x, y: topY),
                color: color,
                width: third
            )
            context.pdf.emit.line(
                from: PDF.UserSpace.Coordinate(x: from.x, y: bottomY),
                to: PDF.UserSpace.Coordinate(x: to.x, y: bottomY),
                color: color,
                width: third
            )

        default:
            context.pdf.emit.line(from: from, to: to, color: color, width: width)
        }
    }

    static func drawVerticalBorder(
        from: PDF.UserSpace.Coordinate,
        to: PDF.UserSpace.Coordinate,
        color: PDF.Color,
        width: PDF.UserSpace.Width,
        style: W3C_CSS_Values.LineStyle,
        context: inout PDF.HTML.Context
    ) {
        switch style {
        case .double:
            let third = width / 3
            let leftX = from.x - third
            let rightX = from.x + third
            context.pdf.emit.line(
                from: PDF.UserSpace.Coordinate(x: leftX, y: from.y),
                to: PDF.UserSpace.Coordinate(x: leftX, y: to.y),
                color: color,
                width: third
            )
            context.pdf.emit.line(
                from: PDF.UserSpace.Coordinate(x: rightX, y: from.y),
                to: PDF.UserSpace.Coordinate(x: rightX, y: to.y),
                color: color,
                width: third
            )

        default:
            context.pdf.emit.line(from: from, to: to, color: color, width: width)
        }
    }

    static func drawCellBackground(
        bounds: PDF.UserSpace.Rectangle,
        color: PDF.Color,
        borderWidth: PDF.UserSpace.Size<1> = 0,
        context: inout PDF.HTML.Context
    ) {

        let insetX = borderWidth.width / 2
        let insetY = borderWidth.height / 2
        context.pdf.emit.rectangle(
            bounds.insetBy(dx: insetX, dy: insetY),
            fill: color,
            stroke: nil
        )
    }
}

extension HTML.Tag.Element {

    static func applyTagStyle(_ tagName: String, context: inout PDF.HTML.Context) {
        switch tagName {

        case "h1":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 1)

        case "h2":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 2)

        case "h3":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 3)

        case "h4":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 4)

        case "h5":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 5)

        case "h6":
            context.pdf.style.font = context.pdf.style.font.bold
            context.pdf.style.fontSize = context.configuration.headingSize(level: 6)

        case "strong", "b":
            context.pdf.style.font = context.pdf.style.font.bold

        case "em", "i":
            context.pdf.style.font = context.pdf.style.font.italic

        case "code", "kbd", "samp":
            context.pdf.style.font = .courier

            context.pdf.style.fontSize = (context.pdf.style.fontSize) * 0.9

        case "pre":
            context.pdf.style.font = .courier
            context.pdf.style.fontSize = (context.pdf.style.fontSize) * 0.9
            context.pdf.mode.preserveWhitespace = true

        case "s", "strike", "del":
            context.pdf.style.textMarkup = .strikeOut

        case "u", "ins":
            context.pdf.style.textMarkup = .underline

        case "mark":
            context.pdf.style.textMarkup = .highlight(.rgb(red: 1.0, green: 1.0, blue: 0.0))

        case "sub":
            let currentSize = context.pdf.style.fontSize
            context.pdf.style.fontSize =
                currentSize * context.configuration.typography.subscriptScale

            context.pdf.style.verticalOffset -=
                (currentSize * context.configuration.typography.subscriptOffset).height

        case "sup":
            let currentSize = context.pdf.style.fontSize
            context.pdf.style.fontSize =
                currentSize * context.configuration.typography.superscriptScale

            context.pdf.style.verticalOffset +=
                (currentSize * context.configuration.typography.superscriptOffset).height

        case "small":
            let currentSize = context.pdf.style.fontSize
            context.pdf.style.fontSize =
                currentSize * context.configuration.typography.smallScale

        case "a":
            context.pdf.style.color = .blue
            context.pdf.style.textMarkup = .underline

        case "blockquote", "dd":
            let indent = context.configuration.indent.blockquote
            context.pdf.layout.box.llx += indent

        case "figure":
            let margin = context.configuration.indent.figure
            context.pdf.layout.box.llx += margin
            context.pdf.layout.box.urx -= margin

        case "cite", "dfn", "var":
            context.pdf.style.font = context.pdf.style.font.italic

        default:
            break
        }
    }

    static func blockMargins(
        for tagName: String,
        configuration: PDF.HTML.Configuration
    ) -> (top: LengthPercentage, bottom: LengthPercentage)? {
        switch tagName {
        case "p":
            return (.length(.em(1.0)), .length(.em(1.0)))

        case "h1", "h2", "h3", "h4", "h5", "h6":
            let margin = configuration.headingMarginEm(for: tagName).value
            return (.length(.em(margin)), .length(.em(margin)))

        case "blockquote":
            return (.length(.em(1.0)), .length(.em(1.0)))

        case "pre":
            return (.length(.em(1.0)), .length(.em(1.0)))

        case "ul", "ol":

            return (.length(.em(1.0)), .length(.em(1.0)))

        case "table":

            return nil

        default:
            return nil
        }
    }

    static func headingLevel(for tagName: String) -> Int? {
        switch tagName {
        case "h1": return 1
        case "h2": return 2
        case "h3": return 3
        case "h4": return 4
        case "h5": return 5
        case "h6": return 6
        default: return nil
        }
    }

    static func isListContainer(_ tagName: String) -> Bool {
        tagName == "ol" || tagName == "ul"
    }

    static func listType(for tagName: String) -> PDF.Context.List.Kind? {
        switch tagName {
        case "ol": return .ordered(startNumber: 1)
        case "ul": return .unordered
        default: return nil
        }
    }
}
