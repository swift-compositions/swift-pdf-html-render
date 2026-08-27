import Dimension

extension PDF.HTML.Configuration {

    public struct Typography: Sendable, Equatable {

        public var subscriptScale: Dimension.Scale<1, Double>

        public var superscriptScale: Dimension.Scale<1, Double>

        public var smallScale: Dimension.Scale<1, Double>

        public var subscriptOffset: Dimension.Scale<1, Double>

        public var superscriptOffset: Dimension.Scale<1, Double>

        public init(
            subscriptScale: Dimension.Scale<1, Double> = 0.83,
            superscriptScale: Dimension.Scale<1, Double> = 0.83,
            smallScale: Dimension.Scale<1, Double> = 0.83,
            subscriptOffset: Dimension.Scale<1, Double> = 0.2,
            superscriptOffset: Dimension.Scale<1, Double> = 0.4
        ) {
            self.subscriptScale = subscriptScale
            self.superscriptScale = superscriptScale
            self.smallScale = smallScale
            self.subscriptOffset = subscriptOffset
            self.superscriptOffset = superscriptOffset
        }
    }
}
