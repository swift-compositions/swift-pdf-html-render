import HTML_Rendering
import PDF_HTML_Rendering
import PDF_Rendering
import Test_Snapshot
import Testing
import Tests_Inline_Snapshot

@Suite
struct `Outline Snapshot Tests` {
    @Suite struct Snapshot {}
}

extension OutlineSnapshotTests.Snapshot {
    @Test
    func `outline generation`() {
        let document = PDF.Document(generateOutline: true) {
            HTML.Document {
                HTML.H1.Element { "Chapter 1: Introduction" }
                HTML.Paragraph.Element { "Introduction content goes here." }
                HTML.H2.Element { "1.1 Background" }
                HTML.Paragraph.Element { "Background information." }
                HTML.H2.Element { "1.2 Objectives" }
                HTML.Paragraph.Element { "Project objectives." }
                HTML.H3.Element { "1.2.1 Primary Goals" }
                HTML.Paragraph.Element { "Primary goals description." }
                HTML.H1.Element { "Chapter 2: Method" }
                HTML.Paragraph.Element { "Method description." }
                HTML.H2.Element { "2.1 Approach" }
                HTML.Paragraph.Element { "Approach details." }
            }
        }

        snapshot(as: .pdf, named: "outline-generation") { document }
    }

    @Test
    func `articles of incorporation style`() {
        let document = PDF.Document(generateOutline: true) {
            HTML.Document {
                HTML.H1.Element { "Articles of Incorporation" }
                    .css.textAlign(.center)

                HTML.H2.Element { "Article I: Name" }
                HTML.Paragraph.Element { "The name of the corporation shall be Test Corp." }

                HTML.H2.Element { "Article II: Purpose" }
                HTML.Paragraph.Element { "The purpose of the corporation is to engage in any lawful activity." }

                HTML.H2.Element { "Article III: Capital Stock" }
                HTML.H3.Element { "Section 3.1: Authorized Shares" }
                HTML.Paragraph.Element { "The total number of shares shall be 10,000." }
                HTML.H3.Element { "Section 3.2: Par Value" }
                HTML.Paragraph.Element { "Each share shall have a par value of $0.01." }
                HTML.H3.Element { "Section 3.3: Classes of Stock" }
                HTML.Paragraph.Element { "There shall be two classes: Common and Preferred." }

                HTML.H2.Element { "Article IV: Registered Agent" }
                HTML.Paragraph.Element { "The registered agent shall be located at the principal office." }

                HTML.H2.Element { "Article V: Directors" }
                HTML.Paragraph.Element { "The initial board shall consist of three directors." }
            }
        }

        snapshot(as: .pdf, named: "articles-of-incorporation") { document }
    }

    @Test
    func `single H1 parent`() {
        let document = PDF.Document(generateOutline: true) {
            HTML.Document {
                HTML.H1.Element { "Main Document" }
                HTML.Paragraph.Element { "Introduction paragraph." }
                HTML.H3.Element { "Section 1" }
                HTML.Paragraph.Element { "Content for section 1." }
                HTML.H3.Element { "Section 2" }
                HTML.Paragraph.Element { "Content for section 2." }
                HTML.H3.Element { "Section 3" }
                HTML.Paragraph.Element { "Content for section 3." }
            }
        }

        snapshot(as: .pdf, named: "single-h1-parent") { document }
    }

    @Test
    func `multiple H1 parents`() {
        let document = PDF.Document(generateOutline: true) {
            HTML.Document {
                HTML.H1.Element { "First Chapter" }
                HTML.Paragraph.Element { "Content." }
                HTML.H3.Element { "First Section 1" }
                HTML.Paragraph.Element { "Content." }
                HTML.H3.Element { "First Section 2" }
                HTML.Paragraph.Element { "Content." }
                HTML.H1.Element { "Second Chapter" }
                HTML.Paragraph.Element { "Content." }
                HTML.H3.Element { "Second Section 1" }
                HTML.Paragraph.Element { "Content." }
                HTML.H3.Element { "Second Section 2" }
                HTML.Paragraph.Element { "Content." }
            }
        }

        snapshot(as: .pdf, named: "multiple-h1-parents") { document }
    }
}
