import Foundation

@main
struct BoxRules {
    static func main() throws {
        let bookFolder = URL(fileURLWithPath: "Game/Resources/Book", isDirectory: true)
        let edition = try CaseBook.readEdition("en-GB", in: bookFolder)
        let suite = "BoxRules." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        for question in [1, 0] {
            defaults.removePersistentDomain(forName: suite)
            let session = CaseBook(edition: edition, localeCode: "en-GB", defaults: defaults)
            session.ring()
            session.talk(0)
            session.ask(question)
            session.ask(1 - question)
            precondition(session.notes.questions["a"] == question)
            session.open("receipt")
            session.chooseOwner(0)
            session.attach("match")
            precondition(session.notes.evidence.isEmpty)
            session.attach("familiar")
            precondition(!session.stamp() && session.notes.objection == 1)
            precondition(session.inspect(0))
            session.turn(to: 1)
            precondition(!session.inspect(1))
            session.selectSetting(0)
            precondition(session.inspect(1))
            session.open("receipt")
            session.attach("familiar")
            session.attach("mechanism")
            if question == 0 {
                precondition(!session.stamp())
                precondition(session.inspect(2))
                session.open("receipt")
                session.attach("mechanism")
                session.attach("match")
            }
            precondition(session.stamp())
            precondition(!session.stamp() && session.ledger.receipts.count == 1)
            print(question == 1 ? "PASS demonstration + loose hinge" : "PASS melody spent + signed shim")
        }
    }
}
