import Foundation
import HTML_Rendering
import PDF_Rendering
import Testing

@testable import PDF_HTML_Rendering

@Suite
struct `Conditional Table Tests` {

    @Test
    func `Conditional TableRow inside TableBody`() {
        struct TestTable: HTML.View {
            let showExtraRow = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Always shown" }
                        }
                        if showExtraRow {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element { "Conditionally shown" }
                            }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestTable() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Conditional content inside TableDataCell`() {
        struct TestTable: HTML.View {
            let useAlternateText = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element {
                                if useAlternateText {
                                    "Option A"
                                } else {
                                    "Option B"
                                }
                            }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestTable() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Conditional TableRow with styled content inside TableBody`() {
        struct TestChecklist: HTML.View {
            let showSCorpRow = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableHead.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element { "☐" }
                            HTML.TableHeader.Element { "Task" }
                            HTML.TableHeader.Element { "Fee" }
                            HTML.TableHeader.Element { "Deadline" }
                            HTML.TableHeader.Element { "Notes" }
                        }
                    }
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "☐" }
                            HTML.TableDataCell.Element {
                                HTML.StrongImportance.Element { "Apply for EIN (Form SS-4)" }
                            }
                            HTML.TableDataCell.Element { "Free" }
                            HTML.TableDataCell.Element { "Before banking" }
                            HTML.TableDataCell.Element { "Apply online at www.irs.gov" }
                        }
                        if showSCorpRow {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element { "☐" }
                                HTML.TableDataCell.Element {
                                    HTML.StrongImportance.Element { "File Form 2553 (S-Corp Election)" }
                                }
                                HTML.TableDataCell.Element { "Free" }
                                HTML.TableDataCell.Element { "Within 75 days" }
                                HTML.TableDataCell.Element { "All shareholders must consent" }
                            }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestChecklist() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Conditional styled content inside TableDataCell`() {
        struct TestTable: HTML.View {
            let isSCorp = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element {
                                HTML.StrongImportance.Element { "Federal Tax Return" }
                            }
                            HTML.TableDataCell.Element { "Annually" }
                            HTML.TableDataCell.Element { "Varies" }
                            HTML.TableDataCell.Element {
                                if isSCorp {
                                    "Form 1120-S (S-Corp)"
                                } else {
                                    "Form 1120 (C-Corp)"
                                }
                            }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestTable() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Multiple conditional sections in table`() {
        struct TestTable: HTML.View {
            let showSection1 = true
            let showSection2 = false
            let showSection3 = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Header" }
                        }
                        if showSection1 {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element {
                                    HTML.StrongImportance.Element { "Section 1" }
                                }
                            }
                        }
                        if showSection2 {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element {
                                    HTML.Emphasis.Element { "Section 2" }
                                }
                            }
                        }
                        if showSection3 {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element {
                                    HTML.StrongImportance.Element { "Section 3" }
                                }
                            }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestTable() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Optional TableRow inside HTML.TableBody.Element (if without else)`() {
        struct TestChecklist: HTML.View {
            let showSCorpRow = true
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableHead.Element {
                        HTML.TableRow.Element {
                            HTML.TableHeader.Element { "Task" }
                            HTML.TableHeader.Element { "Fee" }
                            HTML.TableHeader.Element { "Deadline" }
                        }
                    }
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element {
                                HTML.StrongImportance.Element { "Apply for EIN" }
                            }
                            HTML.TableDataCell.Element { "Free" }
                            HTML.TableDataCell.Element { "Before banking" }
                        }

                        if showSCorpRow {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element {
                                    HTML.StrongImportance.Element { "File Form 2553 (S-Corp Election)" }
                                }
                                HTML.TableDataCell.Element { "Free" }
                                HTML.TableDataCell.Element { "Within 75 days" }
                            }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element {
                                HTML.StrongImportance.Element { "Open Business Bank Account" }
                            }
                            HTML.TableDataCell.Element { "Varies" }
                            HTML.TableDataCell.Element { "After EIN" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestChecklist() }
        }
        let _ = [UInt8](document)
    }

    @Test
    func `Optional TableRow with false condition (nil case)`() {
        struct TestTable: HTML.View {
            let showOptionalRow = false
            var body: some HTML.View {
                HTML.Table.Element {
                    HTML.TableBody.Element {
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Always shown" }
                        }
                        if showOptionalRow {
                            HTML.TableRow.Element {
                                HTML.TableDataCell.Element {
                                    HTML.StrongImportance.Element { "This should not appear" }
                                }
                            }
                        }
                        HTML.TableRow.Element {
                            HTML.TableDataCell.Element { "Also always shown" }
                        }
                    }
                }
            }
        }

        let document = PDF.Document {
            HTML.Document { TestTable() }
        }
        let _ = [UInt8](document)
    }
}
