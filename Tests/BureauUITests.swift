import XCTest

final class BureauUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func launch(locale: String = "en-GB", large: Bool = false, freshStandard: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        if !freshStandard { app.launchEnvironment["TIGER_QA_SUITE"] = UUID().uuidString }
        app.launchEnvironment["TIGER_QA_SILENT_OUTPUT"] = "1"
        app.launchEnvironment["TIGER_MOTION_CUES"] = "1"
        app.launchArguments += ["-AppleLanguages", "(" + locale + ")"]
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityM"] }
        app.launch()
        XCTAssertTrue(app.buttons["ring"].waitForExistence(timeout: 12))
        XCTAssertEqual(app.staticTexts["brand-title"].label, "Benatiger")
        return app
    }

    func tap(_ id: String, in app: XCUIApplication, scroll: String = "page-scroll",
             file: StaticString = #filePath, line: UInt = #line) {
        let target = app.buttons[id]
        if !target.isHittable {
            let window = app.windows.firstMatch
            let bottom = window.coordinate(withNormalizedOffset: CGVector(dx: 0.51, dy: scroll == "cards-scroll" ? 0.68 : 0.80))
            let top = window.coordinate(withNormalizedOffset: CGVector(dx: 0.51, dy: scroll == "cards-scroll" ? 0.43 : 0.35))
            for _ in 0..<8 where !target.isHittable {
                bottom.press(forDuration: 0.02, thenDragTo: top, withVelocity: .slow, thenHoldForDuration: 0.02)
            }
            for _ in 0..<8 where !target.isHittable {
                top.press(forDuration: 0.02, thenDragTo: bottom, withVelocity: .slow, thenHoldForDuration: 0.02)
            }
        }
        XCTAssertTrue(target.isHittable, id, file: file, line: line)
        target.tap()
    }

    func take(_ name: String) {
        RunLoop.current.run(until: Date().addingTimeInterval(0.28))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func evidence(_ ids: [String], in app: XCUIApplication) {
        tap("slot-0", in: app)
        for id in ids {
            tap("card-" + id, in: app, scroll: "cards-scroll")
        }
        tap("cards-done", in: app)
    }

    func inspectBox(_ app: XCUIApplication, signed: Bool) {
        tap("tab-bench", in: app)
        tap("find-0", in: app)
        tap("face-1", in: app)
        tap("setting-0", in: app)
        tap("find-1", in: app)
        if signed { tap("find-2", in: app) }
    }

    func test01FirstCaseAndRecovery() {
        let app = launch()
        XCTAssertEqual(app.staticTexts["case-title"].label, "The Music Box")
        XCTAssertFalse(app.buttons["visitor-0"].exists)
        take("01-first-launch")
        tap("ring", in: app)
        take("02-reception")
        tap("visitor-0", in: app)
        tap("question-0", in: app)
        XCTAssertTrue(app.staticTexts["answer-0"].firstMatch.exists || app.staticTexts.containing(.staticText, identifier: "answer-0").count > 0 ||
                      app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "little silence")).firstMatch.exists)
        XCTAssertFalse(app.buttons["question-1"].exists)
        tap("play-melody", in: app)
        take("02b-melody-transcript")
        tap("tab-receipt", in: app)
        tap("owner-0", in: app)
        tap("slot-0", in: app)
        XCTAssertFalse(app.buttons["card-match"].exists)
        tap("card-familiar", in: app, scroll: "cards-scroll")
        tap("cards-done", in: app)
        tap("stamp", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Arthur can hum it too")).firstMatch.waitForExistence(timeout: 3))
        take("03-rejected-melody")
        tap("fold-objection", in: app)
        tap("open-notebook", in: app)
        tap("read-objection", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Arthur can hum it too")).firstMatch.waitForExistence(timeout: 3))
        tap("close-notebook", in: app)
        tap("find-0", in: app)
        tap("face-1", in: app)
        tap("find-1", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Hold it down")).firstMatch.exists)
        tap("setting-0", in: app)
        take("04-left-pin")
        tap("find-1", in: app)
        take("05-opened-paper-shim")
        tap("find-2", in: app)
        take("06-signed-shim")
        tap("tab-receipt", in: app)
        evidence(["familiar", "match"], in: app)
        take("07-corrected-receipt")
        tap("stamp", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "thanks for every little repair")).firstMatch.waitForExistence(timeout: 3))
        take("08-ada-letter")
        tap("drawer", in: app)
        XCTAssertTrue(app.buttons["case-umbrella"].isEnabled)
        XCTAssertTrue(app.buttons["case-thermos"].isEnabled)
        XCTAssertFalse(app.buttons["case-punch"].isEnabled)
        take("09-first-archive")
    }

    func test02QuestionAndDraftSurviveRelaunch() {
        let app = launch()
        tap("ring", in: app)
        tap("visitor-0", in: app)
        tap("question-1", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Eleanor braces")).firstMatch.exists)
        take("10-demonstration")
        inspectBox(app, signed: false)
        tap("tab-receipt", in: app)
        tap("owner-0", in: app)
        evidence(["mechanism"], in: app)
        tap("tab-room", in: app)
        tap("visitor-0", in: app)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Eleanor braces")).firstMatch.exists)
        XCTAssertFalse(app.buttons["question-0"].exists)
        take("11-restored-conversation")
        tap("tab-receipt", in: app)
        XCTAssertEqual(app.buttons["slot-0"].label, "Loose left hinge")
        take("12-restored-draft")
        tap("stamp", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "thanks for every little repair")).firstMatch.waitForExistence(timeout: 3))
        tap("drawer", in: app)
        tap("case-box", in: app)
        XCTAssertFalse(app.buttons["stamp"].exists)
        tap("tab-room", in: app)
        tap("visitor-0", in: app)
        tap("question-0", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "little silence")).firstMatch.exists)
    }

    func test03CampaignFromEmptyLedger() {
        let app = launch()
        let tablet = app.windows.firstMatch.frame.width > 700
        let order: [(String, Int, String)] = [
            ("box", 0, "Eleanor Vale"), ("thermos", 1, "Mara Reed"), ("umbrella", 1, "Nell Sayer"),
            ("punch", 0, "Ida Moss"), ("glasses", 1, "Simon Dane"), ("mittens", 0, "Bea Ash"),
            ("metronome", 1, "Lydia Crane"), ("puppet", 0, "Ruth Finch"), ("lantern", 0, "June Ward"),
            ("camera", 1, "Anya Keel"), ("keys", 0, "May Lind"), ("suitcase", 1, "Elsie Holt")
        ]
        for (index, entry) in order.enumerated() {
            let (id, owner, recipient) = entry
            XCTContext.runActivity(named: "Release \(index + 1)/12 — \(id)") { _ in
                if index > 0 {
                    tap("drawer", in: app)
                    tap("case-" + id, in: app)
                }
                tap("ring", in: app)
                XCTAssertEqual(app.buttons["visitor-\(owner)"].label, recipient)
                let proof = prepareDeduction(id, tablet: tablet, in: app)
                tap("tab-bench", in: app)
                if ["box", "camera", "suitcase"].contains(id) {
                    directInspection(id, in: app, keep: true)
                } else {
                    tap("find-0", in: app)
                    tap("face-1", in: app)
                    switch id {
                    case "punch":
                        tap("setting-0", in: app)
                    case "lantern":
                        tap("setting-0", in: app)
                        tap("find-1", in: app)
                        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "blue reaches the registration")).firstMatch.exists)
                        take("campaign-09-lantern-wrong-shutter")
                        tap("setting-2", in: app)
                    case "keys":
                        tap("tooth-1", in: app)
                        tap("tooth-3", in: app)
                        tap("find-1", in: app)
                        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "The teeth do not seat")).firstMatch.exists)
                        take("campaign-11-keys-wrong-teeth")
                        tap("tooth-1", in: app)
                        tap("tooth-3", in: app)
                        tap("tooth-0", in: app)
                        tap("tooth-2", in: app)
                    default:
                        break
                    }
                    tap("find-1", in: app)
                    switch id {
                    case "punch":
                        tap("setting-2", in: app)
                        tap("find-2", in: app)
                        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "little split in its cut")).firstMatch.exists)
                        tap("setting-1", in: app)
                    case "metronome":
                        tap("setting-2", in: app)
                        take("campaign-07-metronome-fourth-beat")
                    default:
                        break
                    }
                    if let proof, proof.early {
                        XCTAssertTrue(app.buttons["find-2"].exists)
                    } else {
                        tap("find-2", in: app)
                    }
                }
                if ["punch", "lantern", "camera", "keys", "suitcase"].contains(id) {
                    take("campaign-\(index + 1)-\(id)-inspection")
                }
                tap("tab-receipt", in: app)
                XCTAssertEqual(app.buttons["owner-\(owner)"].label, recipient)
                tap("owner-\(owner)", in: app)
                if let proof {
                    attachDeduction(proof, id: id, tablet: tablet, in: app)
                } else if id == "suitcase" {
                    evidence(["file.box", "file.thermos"], in: app)
                    tap("stamp", in: app)
                    XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Those are real receipts")).firstMatch.waitForExistence(timeout: 3))
                    tap("tab-receipt", in: app)
                    evidence(["file.box", "file.puppet"], in: app)
                    take("campaign-12-suitcase-receipt")
                } else if id == "camera" || id == "keys" {
                    evidence(["mechanism", "match"], in: app)
                } else {
                    evidence(["match"], in: app)
                }
                tap("stamp", in: app)
                XCTAssertTrue(app.buttons["drawer"].waitForExistence(timeout: 3))
                XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label == %@", "Release recorded")).firstMatch.exists)
                if proof != nil { take("deduction-\(id)-issued") }
                print("CAMPAIGN RELEASE \(index + 1)/12 \(id)")
            }
        }
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "All twelve things have gone home")).firstMatch.exists)
        take("campaign-13-finale")
        tap("drawer", in: app)
        for (id, _, _) in order {
            XCTAssertTrue(app.buttons["case-" + id].label.contains("Release recorded"), id)
        }
        take("campaign-14-archive")
    }

    private struct Deduction {
        let witnessSeat: Int
        let rightQuestion: Int
        let witness: String
        let weakMessage: String
        let physical: [String]
        let spoken: [String]
        let takesStatement: Bool
        var early: Bool { takesStatement && spoken[0] != "match" }
    }

    private func prepareDeduction(_ id: String, tablet: Bool, in app: XCUIApplication) -> Deduction? {
        let proof: Deduction
        switch id {
        case "thermos":
            proof = Deduction(witnessSeat: 0, rightQuestion: 0, witness: "Eli Noon", weakMessage: "Eli’s account of when his name was added",
                              physical: ["trace", "match"], spoken: ["match", "statement.b"], takesStatement: !tablet)
        case "punch":
            proof = Deduction(witnessSeat: 0, rightQuestion: 0, witness: "Ida Moss", weakMessage: "Her description of its split",
                              physical: ["trace", "match"], spoken: ["mechanism", "statement.b"], takesStatement: !tablet)
        case "metronome":
            proof = Deduction(witnessSeat: 0, rightQuestion: 1, witness: "Felix Marr", weakMessage: "Felix’s account of the loan",
                              physical: ["mechanism", "match"], spoken: ["mechanism", "statement.b"], takesStatement: tablet)
        case "lantern":
            proof = Deduction(witnessSeat: 1, rightQuestion: 1, witness: "Rafi Cole", weakMessage: "The amber cue explains why Rafi used the lamp",
                              physical: ["mechanism", "match"], spoken: ["mechanism", "statement.a"], takesStatement: tablet)
        default: return nil
        }
        let question = proof.takesStatement ? proof.rightQuestion : 1 - proof.rightQuestion
        XCTAssertEqual(app.buttons["visitor-\(proof.witnessSeat)"].label, proof.witness)
        tap("visitor-\(proof.witnessSeat)", in: app)
        tap("question-\(question)", in: app)
        XCTAssertFalse(app.buttons["question-\(1 - question)"].exists)
        take("deduction-\(id)-question-\(question)")
        return proof
    }

    private func attachDeduction(_ proof: Deduction, id: String, tablet: Bool, in app: XCUIApplication) {
        if id == "thermos" {
            evidence(["match"], in: app)
            if !tablet {
                app.terminate()
                app.launch()
                XCTAssertEqual(app.buttons["slot-0"].label, "Order of the engravings")
                XCTAssertTrue(app.buttons["owner-1"].isSelected)
                take("deduction-thermos-draft-after-relaunch")
            }
            tap("stamp", in: app)
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "The inside marks need context")).firstMatch.waitForExistence(timeout: 3))
            take("deduction-thermos-last-card-refused")
            tap("tab-receipt", in: app)
            evidence(["match"], in: app)
        }
        if proof.takesStatement {
            evidence(proof.spoken, in: app)
            print("DEDUCTION \(id) accepts \(proof.spoken.joined(separator: "+")) after question \(proof.rightQuestion); before final card: \(proof.early)")
        } else {
            evidence(proof.spoken, in: app)
            tap("stamp", in: app)
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", proof.weakMessage)).firstMatch.waitForExistence(timeout: 3))
            take("deduction-\(id)-weak-statement-refused")
            tap("tab-receipt", in: app)
            evidence(proof.spoken + proof.physical, in: app)
            print("DEDUCTION \(id) rejects question \(1 - proof.rightQuestion); accepts \(proof.physical.joined(separator: "+"))")
        }
        take("deduction-\(id)-corrected-draft")
    }

    func test04ArabicLargeTypeWithSoundOff() {
        let app = launch(locale: "ar", large: true)
        XCTAssertEqual(app.staticTexts["case-title"].label, "علبة الموسيقى")
        tap("sound", in: app)
        XCTAssertEqual(app.buttons["sound"].label, "تشغيل الصوت")
        tap("ring", in: app)
        tap("visitor-0", in: app)
        tap("question-1", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "المفصلة اليسرى بإبهامها")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts["sound-transcript"].exists)
        take("locale-ar-large-conversation")
        inspectBox(app, signed: true)
        tap("tab-receipt", in: app)
        tap("slot-0", in: app)
        tap("card-match", in: app, scroll: "cards-scroll")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "حشوة ورقية موقّعة")).firstMatch.exists)
        take("locale-ar-large-evidence")
    }

    func test05TraditionalChineseConversationAndCards() {
        let app = launch(locale: "zh-Hant")
        XCTAssertEqual(app.staticTexts["case-title"].label, "音樂盒")
        tap("ring", in: app)
        tap("visitor-1", in: app)
        tap("question-0", in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "一個音一個音抄下來")).firstMatch.exists)
        take("locale-zh-Hant-conversation")
        inspectBox(app, signed: true)
        tap("tab-receipt", in: app)
        tap("slot-0", in: app)
        tap("card-mechanism", in: app, scroll: "cards-scroll")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "鬆脫的左鉸鏈")).firstMatch.exists)
        take("locale-zh-Hant-evidence")
    }


    func touchPart(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let button = app.buttons["part-hotspot"]
        let frame = button.frame
        print("PART AX FRAME \(frame) \(button.label)")
        XCTAssertTrue(button.isHittable, file: file, line: line)
        XCTAssertEqual(frame.width, 54, accuracy: 2, file: file, line: line)
        XCTAssertEqual(frame.height, 54, accuracy: 2, file: file, line: line)
        button.tap()
    }

    private func stageScale(_ app: XCUIApplication) -> CGFloat {
        let frame = app.windows.firstMatch.frame
        return min((frame.width - 16) / 324, (frame.height - 180) * 0.57 / 205)
    }

    private func pull(_ app: XCUIApplication, dx: CGFloat, dy: CGFloat, pause: TimeInterval = 0.05) {
        let mark = app.buttons["part-hotspot"]
        XCTAssertTrue(mark.isHittable)
        let start = mark.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let scale = stageScale(app)
        let end = start.withOffset(CGVector(dx: dx * scale, dy: dy * scale))
        start.press(forDuration: pause, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.03)
    }

    private func turnByTouch(_ app: XCUIApplication) {
        let window = app.windows.firstMatch
        let left = window.coordinate(withNormalizedOffset: CGVector(dx: 0.17, dy: 0.43))
        let right = window.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.43))
        left.press(forDuration: 0.05, thenDragTo: right, withVelocity: .default, thenHoldForDuration: 0.04)
    }

    private func directInspection(_ id: String, in app: XCUIApplication, keep: Bool) {
        touchPart(in: app)
        if id == "suitcase" {
            XCTAssertTrue(app.buttons["find-0"].exists)
            tap("part-hotspot-2", in: app)
        }
        XCTAssertFalse(app.buttons["find-0"].exists)
        turnByTouch(app)
        XCTAssertTrue(app.buttons["find-1"].waitForExistence(timeout: 3))
        if keep {
            pull(app, dx: 0, dy: id == "suitcase" ? 15 : -15)
            XCTAssertTrue(app.buttons["find-1"].exists)
            XCTAssertTrue(app.staticTexts["motion-feedback"].exists)
        }
        pull(app, dx: 0, dy: id == "suitcase" ? 83 : -83, pause: 0.23)
        XCTAssertTrue(app.buttons["find-2"].waitForExistence(timeout: 3))
        if keep && id == "box" { take("motion-open-hinge") }
        if id == "camera" {
            // A real wrong release moves the strip farther right. The second drag aligns it.
            pull(app, dx: 16, dy: 0)
            XCTAssertTrue(app.buttons["find-2"].exists)
            XCTAssertTrue(app.staticTexts["motion-feedback"].label.contains("Still two marks"))
            if keep { take("motion-film-offset") }
            pull(app, dx: -58, dy: 0)
        } else {
            pull(app, dx: 0, dy: -105)
        }
        XCTAssertFalse(app.buttons["find-2"].exists)
        if keep {
            if id == "box" { take("motion-signed-slip") }
            if id == "camera" { take("motion-aligned-film") }
            if id == "suitcase" { take("motion-open-suitcase") }
        }
    }

    func test06IPadSceneOrientations() throws {
        let device = XCUIDevice.shared
        device.orientation = .portrait
        let app = launch()
        guard app.windows.firstMatch.frame.width > 700 else { throw XCTSkip("iPad only") }
        defer { device.orientation = .portrait }
        tap("desk-bell", in: app)
        tap("room-object", in: app)
        touchPart(in: app)
        XCTAssertFalse(app.buttons["find-0"].exists)
        device.orientation = .landscapeLeft
        let landscape = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            let frame = app.windows.firstMatch.frame
            return frame.width > frame.height
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [landscape], timeout: 8), .completed)
        turnByTouch(app)
        XCTAssertTrue(app.buttons["find-1"].waitForExistence(timeout: 3))
        pull(app, dx: 0, dy: -83, pause: 0.23)
        take("motion-landscape-hinge")
        pull(app, dx: 0, dy: -105)
        XCTAssertFalse(app.buttons["find-2"].exists)
    }

    func test00RecordedMusicBox() {
        let app = launch(freshStandard: true)
        print("MOTION_CUT_START \(Date().timeIntervalSince1970)")
        tap("desk-bell", in: app)
        take("motion-reception")
        tap("room-object", in: app)
        directInspection("box", in: app, keep: true)
        tap("tab-receipt", in: app)
        tap("owner-0", in: app)
        evidence(["match"], in: app)
        take("motion-receipt")
        let stamp = app.buttons["stamp-tool"]
        XCTAssertTrue(stamp.isHittable)
        let grip = stamp.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.33))
        grip.press(forDuration: 0.05, thenDragTo: grip.withOffset(CGVector(dx: 0, dy: 47)),
                   withVelocity: .slow, thenHoldForDuration: 0.06)
        XCTAssertTrue(app.buttons["drawer"].waitForExistence(timeout: 3))
        take("motion-release")
        print("MOTION_CUT_END \(Date().timeIntervalSince1970)")
    }

    func test07USBrand() {
        let app = launch(locale: "en-US")
        XCTAssertEqual(app.staticTexts["case-title"].label, "The Music Box")
    }
}
