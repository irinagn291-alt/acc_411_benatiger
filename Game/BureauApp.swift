import AVFoundation
import SwiftUI

@main
struct BureauApp: App {
    @State private var book: CaseBook

    init() {
        let folder = Bundle.main.resourceURL!.appendingPathComponent("Book")
        var code = Locale.preferredLanguages.first ?? "en-GB"
        if code.hasPrefix("ar") { code = "ar" }
        else if code.hasPrefix("zh-Hant") || code.hasPrefix("zh-TW") ||
                    code.hasPrefix("zh-HK") || code.hasPrefix("zh-MO") { code = "zh-Hant" }
        else if code != "en-US" { code = "en-GB" }

        var defaults = UserDefaults.standard
        #if DEBUG
        if let suite = ProcessInfo.processInfo.environment["TIGER_QA_SUITE"] {
            defaults = UserDefaults(suiteName: "LuckyTiger.UI." + suite)!
        }
        #endif
        let edition = (try? CaseBook.readEdition(code, in: folder))
            ?? (try! CaseBook.readEdition("en-GB", in: folder))
        _book = State(initialValue: CaseBook(edition: edition, localeCode: code, defaults: defaults))
    }

    var body: some Scene {
        WindowGroup {
            Bureau(book: book)
                .environment(\.locale, Locale(identifier: book.localeCode))
                .environment(\.layoutDirection, book.localeCode == "ar" ? .rightToLeft : .leftToRight)
                .preferredColorScheme(.dark)
        }
    }
}

let ink = Color(red: 0.12, green: 0.09, blue: 0.08)
let burgundy = Color(red: 0.333, green: 0.145, blue: 0.165)
let baize = Color(red: 0.157, green: 0.235, blue: 0.212)
let brass = Color(red: 0.710, green: 0.545, blue: 0.310)
let lamp = Color(red: 0.953, green: 0.871, blue: 0.694)
let parchment = Color(red: 0.91, green: 0.84, blue: 0.71)

struct ActionRow: View {
    let title: String
    var icon = "arrow.right"
    var filled = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
                Text(title).font(.system(.subheadline, design: .serif, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15).padding(.vertical, 11)
            .frame(minHeight: 46)
            .foregroundStyle(filled ? ink : lamp)
            .background(filled ? lamp : Color.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(brass.opacity(0.55)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct Docket: View {
    let title: String
    let detail: String
    var selected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(.headline, design: .serif, weight: .semibold))
            if !detail.isEmpty {
                Text(detail).font(.system(.body, design: .serif))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(14)
        .foregroundStyle(ink)
        .background(selected ? lamp : parchment, in: RoundedRectangle(cornerRadius: 5))
        .overlay(alignment: .leading) {
            Rectangle().fill(selected ? burgundy : brass)
                .frame(width: selected ? 5 : 2)
                .padding(.vertical, 7)
                .accessibilityHidden(true)
        }
    }
}

struct ReleaseMark: View {
    let title: String
    let recipient: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var printed = false

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(.headline, design: .serif, weight: .bold))
                Text(recipient).font(.system(.title2, design: .serif))
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 2)
            Image(systemName: "seal")
                .font(.system(.largeTitle, weight: .semibold))
                .rotationEffect(.degrees(-12))
                .scaleEffect(printed || reduceMotion ? 1 : 1.45)
                .opacity(printed || reduceMotion ? 1 : 0)
                .accessibilityHidden(true)
        }
        .padding(14)
        .foregroundStyle(burgundy)
        .background(lamp, in: RoundedRectangle(cornerRadius: 5))
        .padding(4)
        .background(brass, in: RoundedRectangle(cornerRadius: 7))
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.20)) { printed = true }
        }
    }
}

struct CaseHeading: View {
    let book: CaseBook

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.edition.nights[book.night])
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(lamp.opacity(0.82))
            Text(book.item.title)
                .font(.system(.largeTitle, design: .serif, weight: .regular))
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("case-title")
        }
        .shadow(color: ink.opacity(0.85), radius: 4, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Bureau: View {
    let book: CaseBook
    @State private var board = false
    @State private var audio: AVAudioPlayer?
    @AppStorage("LuckyTiger.muted") private var muted = false

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width >= 720
            VStack(spacing: 0) {
                masthead
                if !board && book.notes.surface == "room" {
                    room
                } else if !board && book.notes.surface == "bench" {
                    Desk(book: book, wide: wide, play: play)
                        .id(book.item.id + ".bench")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            if board {
                                nightBoard
                            } else {
                                CaseHeading(book: book)
                                if book.notes.surface == "letter" {
                                    letter
                                } else {
                                    Desk(book: book, wide: wide, play: play)
                                }
                            }
                        }
                        .frame(maxWidth: 1060)
                        .padding(.horizontal, wide ? 34 : 17)
                        .padding(.top, 13)
                        .padding(.bottom, 28)
                        .frame(maxWidth: .infinity)
                    }
                    .id(book.item.id + (board ? ".board" : "." + book.notes.surface))
                    .accessibilityIdentifier("page-scroll")
                }
                if book.notes.rang && !board { bottomBar }
            }
        }
        .foregroundStyle(lamp)
        .background {
            ZStack {
                LinearGradient(colors: [ink, burgundy.opacity(0.86), ink], startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [brass.opacity(0.16), .clear], center: .top, startRadius: 0, endRadius: 410)
                Canvas { context, size in
                    for y in stride(from: 0.0, through: size.height, by: 6) {
                        var line = Path()
                        line.move(to: CGPoint(x: 0, y: y))
                        line.addLine(to: CGPoint(x: size.width, y: y + 12))
                        context.stroke(line, with: .color(lamp.opacity(0.035)), lineWidth: 0.5)
                    }
                }
            }
            .ignoresSafeArea()
        }
        #if !targetEnvironment(simulator)
        .sensoryFeedback(.success, trigger: book.ledger.receipts.count)
        #endif
    }

    private var masthead: some View {
        HStack(spacing: 9) {
            Image("Tiger").resizable().scaledToFit().frame(width: 29, height: 34)
                .accessibilityHidden(true)
            Text(book.word("brand"))
                .font(.system(.headline, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("brand-title")
            Spacer(minLength: 4)
            Button {
                muted.toggle()
                if muted { audio?.stop() }
            } label: {
                Image(systemName: muted ? "speaker.slash" : "speaker.wave.2")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(book.word(muted ? "unmute" : "mute"))
            .accessibilityIdentifier("sound")
            Button { board.toggle() } label: {
                Image(systemName: board ? "xmark" : "tray.full")
                    .frame(width: 44, height: 44)
                    .background(brass.opacity(0.17), in: RoundedRectangle(cornerRadius: 7))
            }
            .accessibilityLabel(book.word(board ? "close" : "archive"))
            .accessibilityIdentifier("archive")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 17).padding(.vertical, 4)
        .overlay(alignment: .bottom) { Rectangle().fill(brass.opacity(0.38)).frame(height: 1) }
    }

    private var room: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let landscape = w > h
            ZStack(alignment: .topLeading) {
                ObjectStage(id: book.item.id, face: 0, progress: 0,
                            reception: true, immersive: true)

                if book.notes.rang {
                    visitorButton(0, width: w * 0.36, height: h * (landscape ? 0.53 : 0.41))
                        .position(x: w * (landscape ? 0.16 : 0.20), y: h * 0.41)
                        .zIndex(1)
                    visitorButton(1, width: w * 0.36, height: h * (landscape ? 0.53 : 0.41))
                        .position(x: w * (landscape ? 0.84 : 0.80), y: h * 0.41)
                        .zIndex(1)

                    Button { book.open("bench") } label: {
                        Rectangle().fill(.clear)
                            .frame(width: w * 0.48, height: h * 0.24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .position(x: w * 0.5, y: h * 0.63)
                    .accessibilityLabel(book.word("inspect"))
                    .accessibilityIdentifier("room-object")
                } else {
                    Button(action: ringBell) {
                        Rectangle().fill(.clear)
                            .frame(width: max(52, min(w, h) * 0.18), height: max(52, min(w, h) * 0.16))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .position(x: w * 0.84, y: h * 0.73)
                    .accessibilityLabel(book.word("bell"))
                    .accessibilityIdentifier("desk-bell")
                }

                VStack(alignment: .leading, spacing: 0) {
                    CaseHeading(book: book)
                        .padding(.horizontal, 17).padding(.top, 11)
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.notes.rang ? book.item.arrival : book.word("arrival_prompt"))
                            .font(.system(.subheadline, design: .serif))
                            .fixedSize(horizontal: false, vertical: true)
                        if book.notes.rang {
                            ActionRow(title: book.word("inspect"), icon: "magnifyingglass", filled: true) {
                                book.open("bench")
                            }
                            .accessibilityIdentifier("open-bench")
                        } else {
                            ActionRow(title: book.word("bell"), icon: "bell", filled: true, action: ringBell)
                                .accessibilityIdentifier("ring")
                        }
                    }
                    .frame(maxWidth: 620)
                    .padding(.horizontal, 17).padding(.top, 13).padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        LinearGradient(colors: [ink.opacity(0.10), ink.opacity(0.94), ink],
                                       startPoint: .top, endPoint: .bottom)
                    }
                }
            }
        }
    }

    private func ringBell() {
        play("bell")
        book.ring()
    }

    private func visitorButton(_ seat: Int, width: CGFloat, height: CGFloat) -> some View {
        let index = book.visitorOrder[seat]
        let visitor = book.item.visitors[index]
        return Button {
            book.talk(index)
        } label: {
            ZStack(alignment: .bottom) {
                Image(book.item.id + "-person-" + String(index))
                    .resizable().scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .shadow(color: ink, radius: 18)
                    .accessibilityHidden(true)
                Text(visitor.name)
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(ink.opacity(0.86), in: RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(brass.opacity(0.70)))
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("visitor-\(seat)")
    }

    private var bottomBar: some View {
        HStack(spacing: 4) {
            navigation("room", icon: "lamp.table")
            navigation("bench", icon: "magnifyingglass")
            navigation(book.issued == nil ? "receipt" : "letter", icon: "doc.plaintext")
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(ink)
        .overlay(alignment: .top) { Rectangle().fill(brass.opacity(0.42)).frame(height: 1) }
    }

    private func navigation(_ id: String, icon: String) -> some View {
        let current = book.notes.surface == id
        return Button { book.open(id) } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).accessibilityHidden(true)
                Text(book.word(id)).font(.system(.caption, design: .serif, weight: current ? .semibold : .regular))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 47)
            .padding(.horizontal, 2)
            .background(current ? burgundy : .clear, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(current ? [.isSelected] : [])
        .accessibilityIdentifier("tab-" + id)
    }

    private var letter: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let receipt = book.issued {
                ReleaseMark(title: book.word("issued"), recipient: book.item.visitors[receipt.owner].name)
                    .accessibilityIdentifier("issued")
                ForEach(receipt.evidence, id: \.self) { id in
                    Docket(title: book.cardTitle(id), detail: book.cardDetail(id))
                }
                Docket(title: book.word("letter"), detail: book.item.letter)
                    .accessibilityIdentifier("case-letter")
            }
            if book.complete {
                Docket(title: book.word("closed"), detail: book.word("ending"))
            }
            ActionRow(title: book.word("drawer"), icon: "tray.full", filled: true) { board = true }
                .accessibilityIdentifier("drawer")
            ActionRow(title: book.word("review"), icon: "person.2") { book.open("room") }
        }
        .frame(maxWidth: 760)
    }

    private var nightBoard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(book.word("archive")).font(.system(.largeTitle, design: .serif))
                .accessibilityAddTraits(.isHeader)
            if book.complete {
                Docket(title: book.word("closed"), detail: book.word("ending"))
            }
            if let receipt = book.issued, book.notes.surface != "letter" {
                ActionRow(title: book.word("open_copy") + " · " + book.item.visitors[receipt.owner].name,
                          icon: "envelope.open") {
                    board = false
                    book.open("letter")
                }
            }
            ForEach(CaseBook.order.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.edition.nights[index])
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .accessibilityAddTraits(.isHeader)
                    ForEach(CaseBook.order[index], id: \.self) { id in
                        if let item = book.caseNamed(id) {
                            boardRow(item)
                        }
                    }
                }
            }
        }
    }

    private func boardRow(_ item: BureauCase) -> some View {
        let receipt = book.receipt(item.id)
        let available = book.unlocked(item.id)
        let status: String
        if let receipt {
            status = book.word("issued") + " · " + item.visitors[receipt.owner].name
        } else if book.ledger.notes[item.id]?.rang == true {
            status = book.word("in_progress")
        } else {
            status = book.word(available ? "in_drawer" : "locked")
        }
        return Button {
            book.enter(item.id)
            if receipt != nil { book.open("letter") }
            board = false
        } label: {
            HStack(spacing: 12) {
                Image(item.id + "-front").resizable().scaledToFit().frame(width: 62, height: 49)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title).font(.system(.headline, design: .serif))
                    Text(status).font(.system(.subheadline, design: .serif))
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Image(systemName: available ? (receipt != nil ? "envelope" : "arrow.right") : "lock")
                    .accessibilityHidden(true)
            }
            .padding(9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ink.opacity(0.7), in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(brass.opacity(0.36)))
            .opacity(available ? 1 : 0.62)
        }
        .buttonStyle(.plain)
        .disabled(!available)
        .accessibilityIdentifier("case-" + item.id)
    }

    private func play(_ name: String) {
        guard !muted else { return }
        #if !targetEnvironment(simulator)
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav")
            ?? Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "MotionAudio") else { return }
        #endif
        #if DEBUG
        if ProcessInfo.processInfo.environment["TIGER_MOTION_CUES"] == "1" {
            let url = URL.documentsDirectory.appending(path: "motion-cues.tsv")
            let line = Data("\(Date().timeIntervalSince1970)\t\(name)\n".utf8)
            if let file = try? FileHandle(forWritingTo: url) {
                try? file.seekToEnd()
                try? file.write(contentsOf: line)
                try? file.close()
            } else {
                try? line.write(to: url)
            }
        }
        if ProcessInfo.processInfo.environment["TIGER_QA_SILENT_OUTPUT"] == "1" { return }
        #endif
        #if !targetEnvironment(simulator)
        audio = try? AVAudioPlayer(contentsOf: url)
        audio?.play()
        #endif
    }
}
