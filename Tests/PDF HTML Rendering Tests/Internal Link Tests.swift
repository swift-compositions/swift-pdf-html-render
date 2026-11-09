import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

enum `Internal Link Tests` {}

extension `Internal Link Tests` {
    @Suite
    struct `Fragment Links` {

        @Test
        func `render resolves a fragment link to a destination, not a URI`() {
            let result = PDF.HTML.render {
                HTML.Paragraph.Element {
                    HTML.Anchor.Element(href: "#target") { "Jump" }
                }
                HTML.Paragraph.Element { "Target" }
                    .attribute("id", "target")
            }

            let links = Self.links(in: result.pages)
            #expect(links.count == 1)
            #expect(links.allSatisfy(Self.isDestination))
        }

        @Test
        func `pages resolves a fragment link to a destination, not a URI`() {
            let pages = PDF.HTML.pages {
                HTML.Paragraph.Element {
                    HTML.Anchor.Element(href: "#target") { "Jump" }
                }
                HTML.Paragraph.Element { "Target" }
                    .attribute("id", "target")
            }

            let links = Self.links(in: pages)
            #expect(links.count == 1)
            #expect(links.allSatisfy(Self.isDestination))
        }

        @Test
        func `an external link stays a URI`() {
            let result = PDF.HTML.render {
                HTML.Paragraph.Element {
                    HTML.Anchor.Element(href: "https://example.com") { "Example" }
                }
            }

            let links = Self.links(in: result.pages)
            #expect(links.count == 1)
            #expect(!links.contains(where: Self.isDestination))
        }

        private static func links(in pages: [PDF.Page]) -> [PDF.Annotation.Link] {
            pages.flatMap(\.annotations).compactMap { annotation in
                guard case .link(let link) = annotation.content else { return nil }
                return link
            }
        }

        private static func isDestination(_ link: PDF.Annotation.Link) -> Bool {
            guard case .destination = link.target else { return false }
            return true
        }
    }
}
