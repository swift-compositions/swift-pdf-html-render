import Space

extension PDF.HTML.Configuration {

    public struct Typography: Sendable, Equatable {

        public var subscriptScale: Scale::Scale<1, Double>

        public var superscriptScale: Scale::Scale<1, Double>

        public var smallScale: Scale::Scale<1, Double>

        public var subscriptOffset: Scale::Scale<1, Double>

        public var superscriptOffset: Scale::Scale<1, Double>

        public init(
            subscriptScale: Scale::Scale<1, Double> = 0.83,
            superscriptScale: Scale::Scale<1, Double> = 0.83,
            smallScale: Scale::Scale<1, Double> = 0.83,
            subscriptOffset: Scale::Scale<1, Double> = 0.2,
            superscriptOffset: Scale::Scale<1, Double> = 0.4
        ) {
            self.subscriptScale = subscriptScale
            self.superscriptScale = superscriptScale
            self.smallScale = smallScale
            self.subscriptOffset = subscriptOffset
            self.superscriptOffset = superscriptOffset
        }
    }
}
