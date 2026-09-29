import Binary
import Byte
import PDF_Rendering
import Test_Snapshot

extension Test.Snapshot.Strategy where Value == PDF.Document, Format == [Byte] {
    static var pdf: Self {
        Test.Snapshot.Strategy<[Byte], [Byte]>(pathExtension: "pdf", diffing: .data)
            .pullback { (doc: PDF.Document) -> [Byte] in [Byte](doc) }
    }
}
