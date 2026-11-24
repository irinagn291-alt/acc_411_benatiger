import Foundation

@main
struct CampaignRules {
    static let owners = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
    static let workshop: [String: (physical: [String], spoken: [String], speaker: Int, question: Int)] = [
        "thermos": (["trace", "match"], ["match", "statement.b"], 1, 0),
        "punch": (["trace", "match"], ["mechanism", "statement.b"], 1, 0),
        "metronome": (["mechanism", "match"], ["mechanism", "statement.b"], 1, 1),
        "lantern": (["mechanism", "match"], ["mechanism", "statement.a"], 0, 1)
    ]

    static func main() throws {
        let folder = URL(fileURLWithPath: "Game/Resources/Book", isDirectory: true)
        let english = try CaseBook.readEdition("en-GB", in: folder)
        let others = try ["en-US", "zh-Hant", "ar"].map { try CaseBook.readEdition($0, in: folder) }
        for edition in [english] + others {
            precondition(edition.cases.map(\.id) == CaseBook.order.flatMap { $0 })
            precondition(Set(edition.strings.keys) == Set(english.strings.keys))
            precondition(edition.strings["brand"] == "Benatiger")
            precondition(edition.nights.count == 4)
            for item in edition.cases {
                precondition(item.visitors.map(\.id) == ["a", "b"])
                precondition(item.findings.map(\.id) == ["trace", "mechanism", "match"])
                precondition(item.visitors.allSatisfy { $0.questions.count == 2 && $0.answers.count == 2 })
                let revised = workshop[item.id] != nil
                precondition(item.contradictions.count == (revised ? 5 : 3) && !item.letter.isEmpty)
                precondition((item.proofGuide?.isEmpty == false) == revised)
            }
        }
        print("PASS en-GB, en-US, zh-Hant, ar · 12 cases and \(english.strings.count) interface strings each")

        let suite = "BureauRuleChecks." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let order = CaseBook.order.flatMap { $0 }
        for a in [-1, 0, 1] {
            for b in [-1, 0, 1] {
                defaults.removePersistentDomain(forName: suite)
                let book = CaseBook(edition: english, localeCode: "en-GB", defaults: defaults)
                var releaseSeats = [Int]()
                for (i, id) in order.enumerated() {
                    let owner = owners[i]
                    precondition(book.unlocked(id), id)
                    book.enter(id)
                    precondition(book.item.id == id && !book.notes.rang)
                    releaseSeats.append(book.visitorOrder.firstIndex(of: owner)!)
                    book.ring()
                    for (speaker, question) in [a, b].enumerated() where question >= 0 {
                        book.talk(speaker)
                        book.ask(question)
                        book.ask(1 - question)
                        precondition(book.notes.questions[book.item.visitors[speaker].id] == question)
                    }
                    book.open("receipt")
                    book.chooseOwner(owner)
                    book.attach("match")
                    precondition(book.notes.evidence.isEmpty)
                    if id == "suitcase" {
                        precondition(book.cards.count == 11)
                        book.attach("file.thermos")
                        book.attach("file.puppet")
                        precondition(!book.stamp() && book.notes.objection == 2)
                        book.open("receipt")
                        book.attach("file.puppet")
                    }
                    book.open("bench")
                    precondition(book.inspect(0))
                    book.turn(to: 1)
                    switch id {
                    case "box", "punch":
                        precondition(!book.inspect(1))
                        book.selectSetting(0)
                    case "lantern":
                        book.selectSetting(1)
                        precondition(!book.inspect(1))
                        book.selectSetting(2)
                    case "keys":
                        book.toggleTooth(1)
                        book.toggleTooth(3)
                        precondition(!book.inspect(1))
                        book.toggleTooth(1)
                        book.toggleTooth(3)
                        book.toggleTooth(0)
                        book.toggleTooth(2)
                    default: break
                    }
                    precondition(book.inspect(1))
                    switch id {
                    case "punch", "camera":
                        book.selectSetting(2)
                        precondition(!book.inspect(2))
                        book.selectSetting(1)
                    case "metronome":
                        book.selectSetting(1)
                        precondition(!book.inspect(2))
                        book.selectSetting(2)
                    default: break
                    }
                    let demonstration = id == "box" && a == 1
                    if let branch = workshop[id], branch.spoken[0] == "mechanism" {
                        try checkProofs(book, owner: owner, branch: branch, beforeComparison: true)
                    }
                    if !demonstration { precondition(book.inspect(2)) }
                    if let branch = workshop[id] {
                        try checkProofs(book, owner: owner, branch: branch, beforeComparison: false)
                    }
                    book.open("receipt")
                    var right: [String]
                    let weak: [String]
                    switch id {
                    case "camera", "keys":
                        right = ["mechanism", "match"]
                        weak = ["mechanism", "familiar"]
                    case "suitcase":
                        right = ["file.thermos", "file.puppet"]
                        weak = ["file.thermos", "file.box"]
                        book.attach("file.thermos")
                    case "thermos", "punch", "metronome", "lantern":
                        right = workshop[id]!.physical
                        weak = ["match"]
                    default:
                        right = [demonstration ? "mechanism" : "match"]
                        weak = ["familiar"]
                    }
                    for card in weak { book.attach(card) }
                    let reopened = CaseBook(edition: english, localeCode: "en-GB", defaults: defaults)
                    precondition(reopened.ledger == book.ledger)
                    precondition(!book.stamp() && book.notes.objection == (workshop[id] == nil ? 1 : 3))
                    precondition(book.notes.surface == "bench" && book.notes.face == 1)
                    book.open("receipt")
                    for card in weak { book.attach(card) }
                    for card in right { book.attach(card) }
                    book.chooseOwner(1 - owner)
                    precondition(!book.stamp() && book.notes.objection == 0)
                    book.open("receipt")
                    book.chooseOwner(owner)
                    precondition(book.stamp(), "No admissible path for \(id) with choices \(a)/\(b)")
                    precondition(book.receipt(id) == Receipt(item: id, owner: owner, evidence: right))
                    precondition(!book.stamp() && book.ledger.receipts.count == i + 1)
                    if a == -1 && b == -1 { print("PASS \(id) · weak reason, wrong recipient, sufficient reason, unique release") }
                }
                precondition(releaseSeats.filter { $0 == 0 }.count == 6)
                for choiceOfOrder in 0..<8 {
                    var seats = releaseSeats
                    for night in 0..<3 where choiceOfOrder & (1 << night) != 0 {
                        seats.swapAt(3 * night + 1, 3 * night + 2)
                    }
                    precondition(Set(stride(from: 0, to: 12, by: 2).map { seats[$0] }) == [0, 1])
                    precondition(Set(stride(from: 1, to: 12, by: 2).map { seats[$0] }) == [0, 1])
                }
                precondition(book.complete)
                book.enter("box")
                book.talk(0)
                book.ask(0)
                book.ask(1)
                precondition(book.notes.reread["a"] == 1 && book.ledger.receipts.count == 12)
                print("PASS campaign with question choices \(a)/\(b) · 12 releases and original archival pair")
            }
        }
        print("PASS 6 releases in each seat; both seats occur at odd and even case numbers in all 8 legal campaign orders")
        print("PASS all available one-card/two-card combinations in each revised case for all 9 question states; also before final comparison in 3 cases")
        try checkLegacy(english, defaults: defaults)
    }

    private static func checkProofs(_ book: CaseBook, owner: Int,
                                    branch: (physical: [String], spoken: [String], speaker: Int, question: Int),
                                    beforeComparison: Bool) throws {
        let suite = "BureauProofChecks." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let snapshot = try JSONEncoder().encode(book.ledger)
        let witness = book.item.visitors[branch.speaker]
        let asked = book.notes.questions[witness.id]
        precondition(book.cards.contains(branch.spoken[1]) == (asked != nil))
        if let asked {
            precondition(book.cardTitle(branch.spoken[1]).contains(witness.name))
            precondition(book.cardDetail(branch.spoken[1]).contains(witness.answers[asked]))
        }
        let cards = book.cards
        for (index, first) in cards.enumerated() {
            for second in [nil] + cards.dropFirst(index + 1).map(Optional.some) {
                defaults.set(snapshot, forKey: "LuckyTiger.ledger.v1")
                let draft = CaseBook(edition: book.edition, localeCode: book.localeCode, defaults: defaults)
                draft.open("receipt")
                let selected = [first, second].compactMap { $0 }
                for id in selected { draft.attach(id) }
                draft.chooseOwner(owner)
                let physical = !beforeComparison && Set(selected) == Set(branch.physical)
                let spoken = asked == branch.question && Set(selected) == Set(branch.spoken)
                precondition(draft.stamp() == (physical || spoken), "\(book.item.id) with \(selected) and \(book.notes.questions)")
                if physical || spoken {
                    precondition(draft.receipt(book.item.id)?.owner == owner)
                } else {
                    let rejection = selected.contains(where: { $0.hasPrefix("statement.") }) ? 4 : 3
                    precondition(draft.notes.objection == rejection)
                    precondition(draft.notes.evidence == selected && draft.notes.questions == book.notes.questions)
                }
            }
        }
    }

    private static func checkLegacy(_ edition: Edition, defaults: UserDefaults) throws {
        let oldFile = URL(fileURLWithPath: "QA/legacy-ledger-v1.json")
        let oldData = try Data(contentsOf: oldFile)
        defaults.set(oldData, forKey: "LuckyTiger.ledger.v1")
        let book = CaseBook(edition: edition, localeCode: "en-GB", defaults: defaults)
        let oldLedger = try JSONDecoder().decode(Ledger.self, from: oldData)
        precondition(book.ledger == oldLedger)
        precondition(book.item.id == "lantern" && book.visitorOrder == [1, 0])
        precondition(book.item.visitors[book.notes.speaker].name == "Rafi Cole")
        precondition(book.item.visitors[book.notes.owner!].name == "June Ward")
        precondition(book.notes.questions["a"] == 1 && book.notes.questions["b"] == 0)
        precondition(book.notes.evidence == ["match"] && book.notes.objection == 1 && book.notes.surface == "talk")
        book.open("receipt")
        precondition(!book.stamp() && book.notes.objection == 3)
        book.open("receipt")
        book.attach("mechanism")
        precondition(book.stamp())
        book.enter("thermos")
        precondition(book.issued == Receipt(item: "thermos", owner: 0, evidence: ["match"]))
        precondition(book.item.visitors[book.issued!.owner].name == "Mara Reed")
        precondition(book.notes.questions["b"] == 0 && book.notes.reread["b"] == 1)
        book.talk(1)
        book.ask(1)
        precondition(book.notes.questions["b"] == 0)

        for id in ["camera", "keys"] {
            book.enter(id)
            book.ring()
            book.open("bench")
            precondition(book.inspect(0))
            book.turn(to: 1)
            if id == "keys" {
                book.toggleTooth(0)
                book.toggleTooth(2)
            }
            precondition(book.inspect(1))
            if id == "camera" { book.selectSetting(1) }
            precondition(book.inspect(2))
            book.open("receipt")
            book.chooseOwner(id == "camera" ? 1 : 0)
            book.attach("mechanism")
            book.attach("match")
            precondition(book.stamp())
        }
        book.enter("suitcase")
        book.ring()
        book.open("bench")
        precondition(book.inspect(0))
        book.turn(to: 1)
        precondition(book.inspect(1) && book.inspect(2))
        precondition(book.cardDetail("file.thermos").hasPrefix("Mara Reed · "))
        precondition(book.cardDetail("file.puppet").hasPrefix("Ruth Finch · "))
        book.open("receipt")
        book.chooseOwner(1)
        book.attach("file.thermos")
        book.attach("file.puppet")
        precondition(book.stamp() && book.complete)
        let restored = CaseBook(edition: edition, localeCode: "en-GB", defaults: defaults)
        precondition(restored.ledger == book.ledger)
        print("PASS V1 fixture · swapped active speaker and draft recipient, old observations and objection, issued single-card copies authentic at final suitcase, reload after release")
    }
}
