import HTML_Rendering_Core
import Ownership
import PDF_Rendering
import Renderer

extension PDF.HTML {

    public static func render<H: Renderer::Renderer.Document.View>(
        configuration: PDF.HTML.Configuration = .init(),
        @HTML.Builder html: () -> H
    ) -> Renderer.Document.Result {
        let state = Ownership.Mutable(prepareContext(configuration: configuration))
        var renderCtx = Renderer::Renderer.Document.Context.pdfHTML(state: state)
        renderCtx.render(html())
        return finalizeRendering(context: &state.value)
    }
}

extension PDF.HTML {

    public static func pages<
        Content: Renderer::Renderer.Document.View,
        Header: Renderer::Renderer.Document.View,
        Footer: Renderer::Renderer.Document.View
    >(
        configuration: PDF.HTML.Configuration = .init(),
        @HTML.Builder content: () -> Content,
        @HTML.Builder header: @escaping (Page.Info) -> Header = { _ in
            Renderer::Renderer.Document.Empty()
        },
        @HTML.Builder footer: @escaping (Page.Info) -> Footer = { _ in
            Renderer::Renderer.Document.Empty()
        }
    ) -> [PDF.Page] {

        let adjustedMargins = PDF.UserSpace.Insets(
            top: configuration.margins.top + configuration.header.height.underlying,
            leading: configuration.margins.leading,
            bottom: configuration.margins.bottom + configuration.footer.height.underlying,
            trailing: configuration.margins.trailing
        )

        var pass1Config = configuration
        pass1Config.margins = adjustedMargins

        let pass1State = Ownership.Mutable(prepareContext(configuration: pass1Config))
        let contentView = content()
        var pass1RenderCtx = Renderer::Renderer.Document.Context.pdfHTML(state: pass1State)
        pass1RenderCtx.render(contentView)

        pass1State.value.pdf.flush.inline()

        let totalPages = pass1State.value.pdf.pages.count
        let pageSectionTitles = pass1State.value.section.pageTitles

        var finalPages: [PDF.Page] = []

        (1...totalPages).forEach { pageNumber in
            let pageInfo = Page.Info(
                pageNumber: pageNumber,
                totalPages: totalPages,
                sectionTitle: pageSectionTitles[pageNumber],
                documentTitle: configuration.documentTitle,
                date: configuration.documentDate
            )

            var headerContext = PDF.Context(
                mediaBox: configuration.mediaBox,
                margins: PDF.UserSpace.Insets(
                    top: configuration.margins.top,
                    leading: configuration.margins.leading,
                    bottom: configuration.paperSize.height.underlying - configuration.margins.top
                        - configuration.header.height.underlying,
                    trailing: configuration.margins.trailing
                )
            )
            headerContext.style = pass1State.value.pdf.style

            let headerState = Ownership.Mutable(
                Self.Context(pdf: headerContext, configuration: configuration)
            )
            var headerRenderCtx = Renderer::Renderer.Document.Context.pdfHTML(state: headerState)
            headerRenderCtx.render(header(pageInfo))
            headerState.value.pdf.flush.inline()

            var footerContext = PDF.Context(
                mediaBox: configuration.mediaBox,
                margins: PDF.UserSpace.Insets(
                    top: configuration.paperSize.height.underlying - configuration.margins.bottom
                        - configuration.footer.height.underlying,
                    leading: configuration.margins.leading,
                    bottom: configuration.margins.bottom,
                    trailing: configuration.margins.trailing
                )
            )
            footerContext.style = pass1State.value.pdf.style

            let footerState = Ownership.Mutable(
                Self.Context(pdf: footerContext, configuration: configuration)
            )
            var footerRenderCtx = Renderer::Renderer.Document.Context.pdfHTML(state: footerState)
            footerRenderCtx.render(footer(pageInfo))
            footerState.value.pdf.flush.inline()

            let contentPage = pass1State.value.pdf.pages[pageNumber - 1]

            var mergedContents: [PDF.ContentStream] = []
            if let headerPage = headerState.value.pdf.pages.first {
                mergedContents.append(contentsOf: headerPage.contents)
            }
            mergedContents.append(contentsOf: contentPage.contents)
            if let footerPage = footerState.value.pdf.pages.first {
                mergedContents.append(contentsOf: footerPage.contents)
            }

            var mergedResources = contentPage.resources
            if let headerPage = headerState.value.pdf.pages.first {
                for (name, font) in headerPage.resources.fonts {
                    mergedResources.fonts[name] = font
                }
            }
            if let footerPage = footerState.value.pdf.pages.first {
                for (name, font) in footerPage.resources.fonts {
                    mergedResources.fonts[name] = font
                }
            }

            let mergedPage = PDF.Page(
                mediaBox: contentPage.mediaBox,
                contents: mergedContents,
                resources: mergedResources,
                annotations: contentPage.annotations
            )

            finalPages.append(mergedPage)
        }

        return finalPages
    }
}
