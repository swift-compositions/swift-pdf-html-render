import Dimension
import PDF_Rendering
import PDF_Standard

extension W3C_CSS_Text.LineHeight: PDF.HTML.Style.Modifier {
    public func apply(to context: inout PDF.Context, configuration: PDF.HTML.Configuration) {
        switch self {
        case .normal:

            context.style.lineHeight = 1.2

        case .multiple(let value):

            context.style.lineHeight = Dimension.Scale(value)

        case .lengthPercentage(let lp):
            switch lp {
            case .percentage(let percentage):
                context.style.lineHeight = Dimension.Scale(percentage.value / 100.0)

            case .length:

                break

            case .calc:

                break
            }

        case .global:
            break
        }
    }
}
