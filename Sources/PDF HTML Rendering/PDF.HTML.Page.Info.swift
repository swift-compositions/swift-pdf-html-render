extension PDF.HTML.Page {

    public struct Info: Sendable {

        public let pageNumber: Int

        public let totalPages: Int

        public let sectionTitle: String?

        public let documentTitle: String?

        // swift-linter:disable:next raw concept
        // REASON: the document date as display text for a page header or footer, passed through from PDF.HTML.Configuration.documentDate; the author's own wording, so ISO_8601.CalendarDate and Gregorian.Date would refuse or reformat it.
        public let date: String?

        public init(
            pageNumber: Int,
            totalPages: Int,
            sectionTitle: String? = nil,
            documentTitle: String? = nil,
            // swift-linter:disable:next raw concept
            // REASON: the document date as display text for a page header or footer, passed through from PDF.HTML.Configuration.documentDate; the author's own wording, so ISO_8601.CalendarDate and Gregorian.Date would refuse or reformat it.
            date: String? = nil
        ) {
            self.pageNumber = pageNumber
            self.totalPages = totalPages
            self.sectionTitle = sectionTitle
            self.documentTitle = documentTitle
            self.date = date
        }
    }
}
