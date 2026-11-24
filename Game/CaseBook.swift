import Foundation
import Observation

struct Visitor: Decodable, Identifiable {
    let id: String
    let name: String
    let role: String
    let claim: String
    let questions: [String]
    let answers: [String]
}

struct Finding: Decodable, Identifiable {
    let id: String
    let action: String
    let title: String
    let detail: String
}

struct BureauCase: Decodable, Identifiable {
    let id: String
    let title: String
    let arrival: String
    let visitors: [Visitor]
    let familiar: String
    let familiarDetail: String
    let findings: [Finding]
    let contradictions: [String]
    let letter: String
    let proofGuide: String?
}

struct Edition: Decodable {
    let strings: [String: String]
    let nights: [String]
    let cases: [BureauCase]
}

struct Receipt: Codable, Equatable {
    let item: String
    let owner: Int
    let evidence: [String]
}

struct CaseNotes: Codable, Equatable {
    var rang = false
    var face = 0
    var findings: [String] = []
    var questions: [String: Int] = [:]
    var reread: [String: Int] = [:]
    var owner: Int?
    var evidence: [String] = []
    var surface = "room"
    var speaker = 0
    var objection: Int?
    var objectionFolded: Bool?
    var teeth: [Int] = []
    var setting: Int?
}

struct Ledger: Codable, Equatable {
    var active = "box"
    var notes: [String: CaseNotes] = [:]
    var receipts: [Receipt] = []
}

@Observable
final class CaseBook {
    static let order = [
        ["box", "umbrella", "thermos"],
        ["punch", "mittens", "glasses"],
        ["metronome", "lantern", "puppet"],
        ["camera", "keys", "suitcase"]
    ]
    let edition: Edition
    let localeCode: String
    private let defaults: UserDefaults
    private static let saveKey = "LuckyTiger.ledger.v1"
    private(set) var ledger: Ledger

    init(edition: Edition, localeCode: String, defaults: UserDefaults = .standard) {
        self.edition = edition
        self.localeCode = localeCode
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.saveKey),
           let saved = try? JSONDecoder().decode(Ledger.self, from: data),
           edition.cases.contains(where: { $0.id == saved.active }) {
            ledger = saved
        } else {
            ledger = Ledger()
        }
    }

    static func readEdition(_ code: String, in folder: URL) throws -> Edition {
        let url = folder.appendingPathComponent(code + ".json")
        return try JSONDecoder().decode(Edition.self, from: Data(contentsOf: url))
    }

    var item: BureauCase { edition.cases.first { $0.id == ledger.active } ?? edition.cases[0] }
    var notes: CaseNotes { ledger.notes[item.id] ?? CaseNotes() }
    var issued: Receipt? { receipt(item.id) }
    var night: Int { Self.order.firstIndex { $0.contains(item.id) } ?? 0 }
    var slots: Int { night == 3 || testimonyRule != nil ? 2 : 1 }
    var complete: Bool { ledger.receipts.count == 12 }

    // Visitor indices in a V1 ledger refer to the case file, regardless of seating.
    var visitorOrder: [Int] {
        switch item.id {
        case "thermos", "punch", "metronome", "lantern": return [1, 0]
        default: return [0, 1]
        }
    }

    private var recipientID: String {
        switch item.id {
        case "box", "thermos", "mittens", "metronome", "puppet", "keys": return "a"
        default: return "b"
        }
    }

    private var testimonyRule: (witness: String, question: Int, observation: String, physical: Set<String>)? {
        switch item.id {
        case "thermos": return ("b", 0, "match", ["trace", "match"])
        case "punch": return ("b", 0, "mechanism", ["trace", "match"])
        case "metronome": return ("b", 1, "mechanism", ["mechanism", "match"])
        case "lantern": return ("a", 1, "mechanism", ["mechanism", "match"])
        default: return nil
        }
    }

    func word(_ key: String) -> String { edition.strings[key] ?? key }

    func caseNamed(_ id: String) -> BureauCase? { edition.cases.first { $0.id == id } }
    func receipt(_ id: String) -> Receipt? { ledger.receipts.first { $0.item == id } }

    func unlocked(_ id: String) -> Bool {
        guard let index = Self.order.firstIndex(where: { $0.contains(id) }) else { return false }
        for night in Self.order.prefix(index) {
            if night.contains(where: { receipt($0) == nil }) { return false }
        }
        let current = Self.order[index]
        if id == "suitcase" {
            return receipt("camera") != nil && receipt("keys") != nil
        }
        return id == current[0] || receipt(current[0]) != nil
    }

    func enter(_ id: String) {
        guard unlocked(id) else { return }
        ledger.active = id
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(ledger) {
            defaults.set(data, forKey: Self.saveKey)
        }
    }

    private func change(_ edit: (inout CaseNotes) -> Void) {
        var edited = notes
        edit(&edited)
        ledger.notes[item.id] = edited
        save()
    }

    func ring() { change { $0.rang = true } }

    func foldObjection(_ folded: Bool) {
        guard notes.objection != nil else { return }
        change { $0.objectionFolded = folded }
    }

    func open(_ screen: String) {
        guard notes.rang else { return }
        change { $0.surface = screen }
    }

    func talk(_ speaker: Int) {
        guard notes.rang, item.visitors.indices.contains(speaker) else { return }
        change {
            $0.surface = "talk"
            $0.speaker = speaker
        }
    }

    func turn(to face: Int) {
        guard notes.surface == "bench", (0...1).contains(face) else { return }
        change { $0.face = face }
    }

    func ask(_ question: Int) {
        let visitor = item.visitors[notes.speaker]
        guard notes.surface == "talk", visitor.questions.indices.contains(question),
              notes.questions[visitor.id] == nil || issued != nil else { return }
        let review = issued != nil
        change {
            if review {
                $0.reread[visitor.id] = question
            } else {
                $0.questions[visitor.id] = question
            }
        }
    }

    func toggleTooth(_ tooth: Int) {
        guard item.id == "keys", notes.findings.count == 1, (0..<4).contains(tooth) else { return }
        change {
            if let index = $0.teeth.firstIndex(of: tooth) {
                $0.teeth.remove(at: index)
            } else if $0.teeth.count < 2 {
                $0.teeth.append(tooth)
            }
        }
    }

    var settingOptions: [String] {
        switch (item.id, notes.findings.count) {
        case ("box", 1): return ["brace"]
        case ("punch", 1): return ["feed"]
        case ("punch", 2): return ["square_cut", "split_cut", "round_cut"]
        case ("lantern", 1): return ["amber", "green", "blue"]
        case ("metronome", 2): return ["beat_two", "beat_three", "beat_four"]
        case ("camera", 2): return ["shift_left", "align", "shift_right"]
        default: return []
        }
    }

    func selectSetting(_ position: Int) {
        guard notes.surface == "bench", notes.face == 1, settingOptions.indices.contains(position) else { return }
        change { $0.setting = position }
    }

    @discardableResult
    func inspect(_ index: Int) -> Bool {
        guard notes.surface == "bench", item.findings.indices.contains(index),
              index == notes.findings.count, notes.face == (index == 0 ? 0 : 1) else { return false }
        if item.id == "keys", index == 1, Set(notes.teeth) != Set([0, 2]) { return false }
        var requiredSetting: Int?
        switch (item.id, index) {
        case ("box", 1), ("punch", 1): requiredSetting = 0
        case ("punch", 2), ("camera", 2): requiredSetting = 1
        case ("lantern", 1), ("metronome", 2): requiredSetting = 2
        default: break
        }
        if let requiredSetting, notes.setting != requiredSetting { return false }
        let finding = item.findings[index].id
        change {
            $0.findings.append(finding)
            $0.setting = nil
            $0.objectionFolded = true
        }
        return true
    }

    var cards: [String] {
        if item.id == "suitcase" {
            return ledger.receipts.filter { $0.item != item.id }.map { "file." + $0.item }
        }
        let statements = testimonyRule == nil ? [] : item.visitors.compactMap { visitor in
            notes.questions[visitor.id] == nil ? nil : "statement." + visitor.id
        }
        return ["familiar"] + statements + notes.findings
    }

    private func statement(_ id: String) -> (Visitor, Int)? {
        guard id.hasPrefix("statement."),
              let visitor = item.visitors.first(where: { "statement." + $0.id == id }),
              let question = notes.questions[visitor.id], visitor.answers.indices.contains(question) else { return nil }
        return (visitor, question)
    }

    func cardTitle(_ id: String) -> String {
        if id.hasPrefix("file."), let previous = caseNamed(String(id.dropFirst(5))) {
            return previous.title
        }
        if id == "familiar" { return item.familiar }
        if let (visitor, _) = statement(id) { return word("statement") + " · " + visitor.name }
        return item.findings.first { $0.id == id }?.title ?? id
    }

    func cardDetail(_ id: String) -> String {
        if id.hasPrefix("file."), let previous = caseNamed(String(id.dropFirst(5))),
           let copy = receipt(previous.id) {
            return previous.visitors[copy.owner].name + " · " + previous.letter
        }
        if id == "familiar" { return item.familiarDetail }
        if let (visitor, question) = statement(id) {
            return visitor.questions[question] + "\n\n" + visitor.answers[question]
        }
        let physical = item.findings.first { $0.id == id }?.detail ?? ""
        if item.id == "box" && id == "mechanism" && notes.questions["a"] == 1 {
            return physical + "\n\n" + item.visitors[0].answers[1]
        }
        return physical
    }

    func chooseOwner(_ person: Int) {
        guard issued == nil, notes.surface == "receipt", item.visitors.indices.contains(person) else { return }
        change { $0.owner = person }
    }

    func attach(_ id: String) {
        guard issued == nil, notes.surface == "receipt", cards.contains(id) else { return }
        let limit = slots
        change {
            if let index = $0.evidence.firstIndex(of: id) {
                $0.evidence.remove(at: index)
            } else if $0.evidence.count < limit {
                $0.evidence.append(id)
            }
        }
    }

    var canStamp: Bool {
        issued == nil && notes.owner != nil &&
            (notes.evidence.count == slots || (testimonyRule != nil && notes.evidence.count == 1))
    }

    @discardableResult
    func stamp() -> Bool {
        guard notes.surface == "receipt", canStamp, let owner = notes.owner else { return false }
        let selected = Set(notes.evidence)
        var error: Int?
        if item.visitors[owner].id != recipientID {
            error = 0
        } else if let rule = testimonyRule {
            let spoken = "statement." + rule.witness
            let corroborated = selected == [rule.observation, spoken] && notes.questions[rule.witness] == rule.question
            if !selected.isSubset(of: cards) || (selected != rule.physical && !corroborated) {
                error = selected.contains(where: { $0.hasPrefix("statement.") }) ? 4 : 3
            }
        } else {
            switch item.id {
            case "box":
                let demonstrated = notes.questions["a"] == 1 && selected == ["mechanism"]
                if !demonstrated && selected != ["match"] { error = 1 }
            case "camera", "keys":
                if selected != ["mechanism", "match"] { error = 1 }
            case "suitcase":
                if !notes.findings.contains("match") {
                    error = 2
                } else if selected != ["file.thermos", "file.puppet"] {
                    error = 1
                }
            default:
                if selected != ["match"] { error = 1 }
            }
        }
        if let error {
            change {
                $0.objection = error
                $0.objectionFolded = false
                $0.surface = "bench"
            }
            return false
        }
        var settled = notes
        settled.objection = nil
        settled.surface = "letter"
        ledger.notes[item.id] = settled
        ledger.receipts.append(Receipt(item: item.id, owner: owner, evidence: notes.evidence))
        save()
        return true
    }
}
