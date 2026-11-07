
extension PDF.HTML.Context.Section {
    public struct ActiveHeading: Sendable {
        public let level: Int
        public let pageNumber: Int
        public let yPosition: PDF.UserSpace.Y
        public var text: String = ""
    }
}
