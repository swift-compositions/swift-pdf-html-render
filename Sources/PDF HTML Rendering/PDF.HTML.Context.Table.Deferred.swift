import Direction
import Layout
import PDF_Rendering
import Renderer

extension PDF.HTML.Context.Table {

    public struct Deferred {
        let origin: Origin
        let column: Int
        let span: Span
        let isHeader: Bool
        let cell: Cell
        let content: Content
        let savedStyle: PDF.Context.Style.Resolved
        let text: String
        let textAlignment: Horizontal.Alignment
    }
}
