import PDF_Rendering
import W3C_CSS_Values

extension PDF.HTML.Context.Element.Scope {
    public struct PendingSideBorder: Sendable {
        public let width: PDF.UserSpace.Size<1>
        public let style: W3C_CSS_Values::LineStyle
        public let color: PDF.Color
    }
}
