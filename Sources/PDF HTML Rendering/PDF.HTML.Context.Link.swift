extension PDF.HTML.Context {

    public struct Link: Sendable {

        // swift-linter:disable:next raw concept
        // REASON: a link's target as the document wrote it, an HTML href or a Markdown destination that may be relative or malformed, carried unparsed to where the PDF URI action is written; looked at RFC_3986.URI, whose parsing refuses such text and would silently drop the link.
        public var currentURL: String?

        public var currentInternalId: String?

        public var destinations: [String: Destination] = [:]

        public var pending: [Pending] = []

        public init() {}
    }
}
