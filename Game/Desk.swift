import SwiftUI
import UIKit

struct Portrait: View {
    let id: String
    let index: Int

    var body: some View {
        Image(id + "-person-" + String(index))
            .resizable().scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RadialGradient(colors: [burgundy, ink], center: .bottom, startRadius: 3, endRadius: 130)
            }
            .clipShape(.rect(cornerRadius: 5))
            .accessibilityHidden(true)
    }
}

struct ObjectStage: View {
    let id: String
    let face: Int
    let progress: Int
    var wide = false
    var reception = false
    var immersive = false
    var position: Int? = nil
    var hotspot: CGPoint? = nil
    var hotspotLabel: String? = nil
    var drag: ((CGSize) -> Void)? = nil
    var touch: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black
            LinearGradient(colors: reception ? [ink, burgundy, baize] : [ink, baize, baize],
                           startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let top = h * 0.61
                if reception {
                    let window = CGRect(x: w * 0.035, y: h * 0.04, width: w * 0.93, height: h * 0.58)
                    context.fill(Path(roundedRect: window, cornerRadius: 3), with: .color(ink))
                    context.stroke(Path(roundedRect: window, cornerRadius: 3), with: .color(brass.opacity(0.55)), lineWidth: 1.5)
                    for fraction in [0.25, 0.5, 0.75] {
                        var mullion = Path()
                        let x = window.minX + window.width * fraction
                        mullion.move(to: CGPoint(x: x, y: window.minY))
                        mullion.addLine(to: CGPoint(x: x, y: window.maxY))
                        context.stroke(mullion, with: .color(brass.opacity(0.28)), lineWidth: 1)
                    }
                    for index in 0..<24 {
                        let x = window.minX + window.width * Double((index * 73 % 101) + 2) / 105
                        let y = window.minY + window.height * Double((index * 37 % 103) + 2) / 130
                        var rain = Path()
                        rain.move(to: CGPoint(x: x, y: y))
                        rain.addLine(to: CGPoint(x: x - 3, y: y + 8 + Double(index % 9)))
                        context.stroke(rain, with: .color(lamp.opacity(0.19)), lineWidth: 0.65)
                    }
                    context.fill(Path(CGRect(x: 0, y: top, width: w, height: h - top)), with: .color(burgundy))
                    context.fill(Path(CGRect(x: 0, y: h * 0.90, width: w, height: h * 0.10)), with: .color(ink))
                    var cone = Path()
                    cone.move(to: CGPoint(x: w * 0.44, y: h * 0.25))
                    cone.addLines([CGPoint(x: w * 0.56, y: h * 0.25), CGPoint(x: w * 0.84, y: h * 0.90),
                                   CGPoint(x: w * 0.16, y: h * 0.90)])
                    cone.closeSubpath()
                    context.fill(cone, with: .linearGradient(
                        Gradient(colors: [lamp.opacity(0.31), brass.opacity(0.17)]),
                        startPoint: CGPoint(x: w * 0.5, y: 25), endPoint: CGPoint(x: w * 0.5, y: h)))
                    var shade = Path()
                    shade.move(to: CGPoint(x: w * 0.46, y: h * 0.11))
                    shade.addLines([CGPoint(x: w * 0.54, y: h * 0.11), CGPoint(x: w * 0.60, y: h * 0.24),
                                    CGPoint(x: w * 0.40, y: h * 0.24)])
                    shade.closeSubpath()
                    context.fill(shade, with: .color(brass))
                    context.stroke(shade, with: .color(lamp.opacity(0.8)), lineWidth: 0.8)
                    var cord = Path()
                    cord.move(to: CGPoint(x: w * 0.5, y: 0))
                    cord.addLine(to: CGPoint(x: w * 0.5, y: h * 0.11))
                    context.stroke(cord, with: .color(brass), lineWidth: 2)
                    context.fill(Path(ellipseIn: CGRect(x: w * 0.40, y: h * 0.225, width: w * 0.20, height: h * 0.036)), with: .color(lamp))
                    let bellX = w * 0.84
                    let bellY = h * 0.76
                    let r = min(w, h) * 0.067
                    var chime = Path()
                    chime.move(to: CGPoint(x: bellX - r, y: bellY))
                    chime.addQuadCurve(to: CGPoint(x: bellX + r, y: bellY),
                                       control: CGPoint(x: bellX, y: bellY - 2.2 * r))
                    chime.closeSubpath()
                    context.fill(chime, with: .linearGradient(Gradient(colors: [lamp, brass, burgundy]),
                        startPoint: CGPoint(x: bellX - r * 0.6, y: bellY - r),
                        endPoint: CGPoint(x: bellX + r, y: bellY)))
                    context.stroke(chime, with: .color(lamp), lineWidth: 1.2)
                    context.fill(Path(ellipseIn: CGRect(x: bellX - r * 1.2, y: bellY - 1, width: r * 2.4, height: r * 0.38)), with: .color(brass))
                    context.fill(Path(ellipseIn: CGRect(x: bellX - r * 0.17, y: bellY - r * 1.36, width: r * 0.34, height: r * 0.30)), with: .color(lamp))
                } else {
                    context.fill(Path(CGRect(origin: .zero, size: size)), with: .radialGradient(
                        Gradient(colors: [lamp.opacity(0.15), .clear]),
                        center: CGPoint(x: w * 0.40, y: h * 0.36), startRadius: 3, endRadius: w * 0.65))
                    for y in stride(from: 3.0, to: h, by: 4) {
                        var fibre = Path()
                        fibre.move(to: CGPoint(x: 0, y: y))
                        fibre.addLine(to: CGPoint(x: w, y: y + 3))
                        context.stroke(fibre, with: .color(lamp.opacity(0.055)), lineWidth: 0.5)
                    }
                }
                var rail = Path()
                rail.move(to: CGPoint(x: 0, y: h * 0.90))
                rail.addLine(to: CGPoint(x: w, y: h * 0.90))
                context.stroke(rail, with: .color(brass.opacity(reception ? 0.64 : 0.24)), lineWidth: 1)
            }
            GeometryReader { geo in
                let side = face == 0 ? "-front" : progress >= 3 ? "-detail" : progress == 2 ? "-open" : "-back"
                let isLandscape = geo.size.width > geo.size.height
                let center = geo.size.height * (reception ? 0.63 : immersive ? 0.46 : 0.50)
                let scale = reception
                    ? min(geo.size.width * (isLandscape ? 0.64 : 0.90) / 275, geo.size.height * 0.50 / 185)
                    : immersive
                        ? min((geo.size.width + 12) / 267, geo.size.height * 0.66 / 181)
                        : min((geo.size.width + 8) / 320, (geo.size.height - 16) / 210)
                let w = 320 * scale
                let h = 210 * scale
                let x = (geo.size.width - w) / 2
                let y = center - h / 2
                Ellipse().fill(.black.opacity(0.52)).blur(radius: 6)
                    .frame(width: w * 0.69, height: 14)
                    .position(x: geo.size.width / 2, y: center + h * 0.35)
                Image(id + side)
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
                    .position(x: geo.size.width / 2, y: center)
                    .id(side)
                    .transition(.opacity)
                    .accessibilityHidden(true)

                if id == "box" && face == 1 && progress == 2 {
                    Image("box-hinge-close").resizable().scaledToFit()
                        .frame(width: w * 0.38)
                        .shadow(color: .black.opacity(0.55), radius: 9, y: 6)
                        .position(x: min(x + w * 0.80, geo.size.width - w * 0.19 - 9),
                                  y: y + h * 0.61)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .accessibilityHidden(true)
                }
                if let position, face == 1 {
                    settingDetail(position)
                        .accessibilityHidden(true)
                        .frame(width: 92 * scale, height: 46 * scale)
                        .position(x: x + (id == "box" ? 87 : id == "camera" ? 198 : 159) * scale,
                                  y: y + (id == "box" ? 118 : id == "camera" ? 105 : 107) * scale)
                }
                if let drag {
                    Rectangle().fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 24).onEnded { drag($0.translation) })
                        .accessibilityHidden(true)
                }
                if let point = hotspot, let touch {
                    Button(action: touch) {
                        ZStack {
                            Circle().strokeBorder(lamp, lineWidth: 1.5).frame(width: 26, height: 26)
                            Circle().fill(lamp).frame(width: 6, height: 6)
                        }
                        .frame(width: 54, height: 54)
                        .contentShape(Rectangle())
                        .shadow(color: ink, radius: 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(hotspotLabel ?? "")
                    .accessibilityIdentifier("part-hotspot")
                    .position(x: x + point.x * scale, y: y + point.y * scale)
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.23), value: progress)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: face)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: position)
            if !immersive {
                RoundedRectangle(cornerRadius: 10).strokeBorder(brass.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: immersive ? .infinity : nil)
        .frame(height: immersive ? nil : wide ? 335 : 248)
        .clipShape(.rect(cornerRadius: immersive ? 0 : 10))
        .environment(\.layoutDirection, .leftToRight)
    }
    @ViewBuilder
    private func settingDetail(_ setting: Int) -> some View {
        switch id {
        case "box":
            Image(systemName: "hand.point.up.left.fill")
                .resizable().scaledToFit().foregroundStyle(lamp).frame(width: 38).rotationEffect(.degrees(7))
        case "punch":
            if progress == 1 {
                RoundedRectangle(cornerRadius: 4).fill(parchment).stroke(brass, lineWidth: 2)
                    .overlay(Image(systemName: "ellipsis").foregroundStyle(ink))
                    .offset(x: -23, y: 14).rotationEffect(.degrees(-12))
            } else {
                Text(["■", "⌄", "●"][setting]).foregroundStyle(ink).font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity).background(parchment)
                    .rotationEffect(.degrees(-7)).offset(x: 18, y: 23)
            }
        case "lantern":
            Circle().fill([Color(red: 0.81, green: 0.47, blue: 0.19), baize,
                           Color(red: 0.29, green: 0.55, blue: 0.66)][setting])
                .overlay(Circle().strokeBorder(brass, lineWidth: 2))
                .shadow(color: lamp.opacity(0.22), radius: 12)
        case "camera":
            GeometryReader { geo in
                let x = geo.size.width / 92
                let y = geo.size.height / 46
                ZStack {
                    RoundedRectangle(cornerRadius: 3).fill(parchment.opacity(0.30))
                    Path { p in
                        p.move(to: CGPoint(x: 30 * x, y: 7 * y))
                        p.addLines([CGPoint(x: 61 * x, y: 37 * y), CGPoint(x: 51 * x, y: 32 * y),
                                    CGPoint(x: 58 * x, y: 43 * y)])
                    }
                    .stroke(lamp, lineWidth: 1.5)
                }
                .offset(x: CGFloat(setting - 1) * 27 * x)
            }
        default:
            EmptyView()
        }
    }

}

private enum ContactPhase { case down, move, up, cancel }

private final class BenchTarget: UIAccessibilityElement {
    var activate: (() -> Void)?
    override func accessibilityActivate() -> Bool {
        guard let activate else { return false }
        activate()
        return true
    }
}

private final class BenchTouchView: UIView {
    var receive: ((ContactPhase, ObjectIdentifier, CGPoint) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) { nil }

    private func send(_ phase: ContactPhase, _ touches: Set<UITouch>) {
        for touch in touches {
            receive?(phase, ObjectIdentifier(touch), touch.location(in: self))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { send(.down, touches) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { send(.move, touches) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { send(.up, touches) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { send(.cancel, touches) }
}

private struct BenchTouches: UIViewRepresentable {
    let markers: [(CGPoint, String)]
    let receive: (ContactPhase, ObjectIdentifier, CGPoint) -> Void
    let alternate: (Int) -> Void

    func makeUIView(context: Context) -> BenchTouchView { BenchTouchView() }

    func updateUIView(_ view: BenchTouchView, context: Context) {
        view.receive = receive
        let prior = view.accessibilityElements?.compactMap { $0 as? BenchTarget } ?? []
        view.accessibilityElements = markers.enumerated().map { index, marker in
            let element = prior.indices.contains(index) ? prior[index] : BenchTarget(accessibilityContainer: view)
            element.isAccessibilityElement = true
            element.accessibilityLabel = marker.1
            element.accessibilityIdentifier = index == 0 ? "part-hotspot" : "part-hotspot-2"
            element.accessibilityTraits = .button
            element.accessibilityFrameInContainerSpace = CGRect(x: marker.0.x - 27, y: marker.0.y - 27, width: 54, height: 54)
            element.activate = { alternate(index) }
            return element
        }
    }
}

private struct BenchPoint {
    let x: Double
    let y: Double
    let z: Double

    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

private struct BenchLight {
    var context: GraphicsContext!
    let yaw: Double
    let scale: Double
    let center: CGPoint

    static let walnut = Color(red: 0.42, green: 0.22, blue: 0.15)
    static let woodLight = Color(red: 0.64, green: 0.37, blue: 0.24)
    static let metal = Color(red: 0.31, green: 0.34, blue: 0.35)
    static let leather = Color(red: 0.46, green: 0.28, blue: 0.17)

    func depth(_ point: BenchPoint) -> Double {
        (-sin(yaw) * point.x + cos(yaw) * point.z) * 0.89 + point.y * 0.41
    }

    func project(_ point: BenchPoint) -> CGPoint {
        let x = cos(yaw) * point.x + sin(yaw) * point.z
        let z = -sin(yaw) * point.x + cos(yaw) * point.z
        let perspective = 680 / (680 - depth(point))
        return CGPoint(x: center.x + x * perspective * scale,
                       y: center.y + (z * 0.42 - point.y * 0.86 + 38) * perspective * scale)
    }

    func path(_ points: [BenchPoint], closed: Bool = false) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: project(first))
            for point in points.dropFirst() { path.addLine(to: project(point)) }
            if closed { path.closeSubpath() }
        }
    }

    func face(_ points: [BenchPoint], color: Color, shade: Color? = nil, edge: Color = ink) {
        let shape = path(points, closed: true)
        let bounds = shape.boundingRect
        context.fill(shape, with: .linearGradient(Gradient(colors: [shade ?? color.opacity(0.93), color]),
                                                   startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                                                   endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)))
        context.stroke(shape, with: .color(edge), style: StrokeStyle(lineWidth: 1.5 * scale, lineJoin: .round))
    }

    func line(_ points: [BenchPoint], _ color: Color, width: Double = 1) {
        context.stroke(path(points), with: .color(color),
                       style: StrokeStyle(lineWidth: scale * width, lineCap: .round, lineJoin: .round))
    }

    func solid(_ x: Double, _ y: Double, _ z: Double, _ w: Double, _ h: Double, _ d: Double, _ color: Color) {
        let a = BenchPoint(x, y, z), b = BenchPoint(x + w, y, z)
        let c = BenchPoint(x + w, y, z + d), e = BenchPoint(x, y, z + d)
        let f = BenchPoint(x, y + h, z), g = BenchPoint(x + w, y + h, z)
        let j = BenchPoint(x + w, y + h, z + d), k = BenchPoint(x, y + h, z + d)
        let planes = [[a, b, g, f], [b, c, j, g], [c, e, k, j], [e, a, f, k], [f, g, j, k]]
        for plane in planes.sorted(by: { $0.map(depth).reduce(0,+) < $1.map(depth).reduce(0,+) }) {
            face(plane, color: color, shade: color == Self.walnut ? Self.woodLight : color.opacity(0.72))
        }
    }

    func oval(_ center: BenchPoint, width: Double, height: Double, color: Color, faceZ: Bool = true) {
        let points = (0..<40).map { index in
            let angle = Double(index) * .pi / 20
            return BenchPoint(center.x + cos(angle) * width,
                              center.y + (faceZ ? sin(angle) * height : 0),
                              center.z + (faceZ ? 0 : sin(angle) * height))
        }
        face(points, color: color, edge: ink.opacity(0.7))
    }

    func feet(width: Double, depth d: Double) {
        for x in [-width, width - 17] {
            for z in [-d + 5, d - 21] { solid(x, -9, z, 17, 11, 16, ink) }
        }
    }
}

private struct BenchPainting: View, Animatable {
    var yaw: Double
    var lid: Double
    var paper: Double
    let draw: (GraphicsContext, Double, Double, Double) -> Void

    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { AnimatablePair(yaw, AnimatablePair(lid, paper)) }
        set { yaw = newValue.first; lid = newValue.second.first; paper = newValue.second.second }
    }

    var body: some View {
        Canvas { context, _ in draw(context, yaw, lid, paper) }
    }
}

private struct HeldObject: View {
    let book: CaseBook
    let play: (String) -> Void
    let fallback: (Int) -> Void
    let report: (String?) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduced
    @State private var angle: Double?
    @State private var opening: Double?
    @State private var paper: Double?
    @State private var slide: CGSize?
    @State private var caught = false
    @State private var travelPlayed = false
    @State private var braces = false
    @State private var latches = [false, false]
    @State private var hand: ObjectIdentifier?
    @State private var thumb: ObjectIdentifier?
    @State private var thumbPoint = CGPoint.zero
    @State private var start = CGPoint.zero
    @State private var startSlide = CGSize.zero
    @State private var startAngle = 0.0
    @State private var action = ""

    static let items = ["box", "camera", "suitcase"]
    private var count: Int { book.notes.findings.count }
    private var side: Int { book.notes.face }
    private var id: String { book.item.id }
    private var restingAngle: Double { side == 0 ? -0.26 : .pi - 0.23 }
    private var film: CGSize { slide ?? CGSize(width: book.notes.setting.map { Double($0 - 1) * 41 } ?? 42, height: 0) }
    private var lift: Double { opening ?? (count >= 2 ? 1 : 0) }
    private var sheet: Double { paper ?? (count == 3 ? 1 : 0) }
    private var easing: Animation? { reduced ? nil : .spring(response: 0.31, dampingFraction: 0.81) }

    var body: some View {
        GeometryReader { geometry in
            let scale = min((geometry.size.width - 16) / 324, geometry.size.height * 0.57 / 205)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.41)
            let projector = BenchLight(context: nil, yaw: angle ?? restingAngle,
                                       scale: scale, center: center)
            ZStack {
                RadialGradient(colors: [Color(red: 0.27, green: 0.40, blue: 0.34), baize, ink],
                               center: .center, startRadius: 12, endRadius: max(geometry.size.width, geometry.size.height) * 0.64)
                BenchPainting(yaw: angle ?? restingAngle, lid: lift, paper: sheet) { ctx, yaw, lid, paper in
                    var shadow = ctx
                    shadow.addFilter(.blur(radius: 13 * scale))
                    let width = (id == "suitcase" ? 265 : 237) * scale
                    shadow.fill(Path(ellipseIn: CGRect(x: center.x - width * 0.49, y: center.y + 58 * scale,
                                                      width: width, height: 24 * scale)), with: .color(.black.opacity(0.70)))
                    let light = BenchLight(context: ctx, yaw: yaw, scale: scale, center: center)
                    switch id {
                    case "box": drawBox(light, lift: lid, sheet: paper)
                    case "camera": drawCamera(light, lift: lid)
                    default: drawCase(light, lift: lid)
                    }
                }
                .accessibilityHidden(true)
                if id != "camera" && side == 1 && count >= 2 && sheet > 0.015 {
                    slidingPaper(projector)
                }
                ForEach(Array(targets(projector).enumerated()), id: \.offset) { _, marker in
                    Circle().strokeBorder(caught ? .mint : lamp.opacity(0.9), lineWidth: 1)
                        .frame(width: 21, height: 21)
                        .overlay(Circle().fill(caught ? .mint : lamp).frame(width: 4, height: 4))
                        .position(marker.0)
                        .opacity(action.isEmpty ? 1 : 0.48)
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
                BenchTouches(markers: targets(projector), receive: { phase, finger, point in
                    handle(phase, finger, point, projector)
                }, alternate: { index in
                    if id == "suitcase", side == 0, count == 0 {
                        clasp(index)
                    } else {
                        fallback(count)
                    }
                })
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            angle = restingAngle
            opening = count >= 2 ? 1 : 0
            paper = count == 3 ? 1 : 0
        }
        .onChange(of: side) { _, _ in
            if hand == nil {
                let turns = ((angle ?? restingAngle) - restingAngle) / (2 * .pi)
                withAnimation(easing) { angle = restingAngle + turns.rounded() * 2 * .pi }
            }
        }
        .onChange(of: count) { _, _ in
            if hand == nil {
                withAnimation(easing) {
                    opening = count >= 2 ? 1 : 0
                    paper = count == 3 ? 1 : 0
                }
            }
        }
        .onChange(of: book.notes.setting) { _, _ in
            if hand == nil { withAnimation(easing) { slide = nil } }
        }
    }

    private func targets(_ light: BenchLight) -> [(CGPoint, String)] {
        if count >= 3 { return [] }
        let description = book.item.findings[count].action
        if side == 0 && count == 0 {
            if id == "suitcase" {
                return [-72.0, 72].map { x in (light.project(BenchPoint(x, 42, 59)), description) }
            }
            return [(light.project(BenchPoint(id == "box" ? 88 : 76, id == "box" ? 56 : 61, 54)), description)]
        }
        guard side == 1 && count > 0 else { return [] }
        if count == 1 {
            let point = id == "box" ? BenchPoint(91, 51, -67)
                : id == "camera" ? BenchPoint(82, 16, -45) : BenchPoint(50, 43, -61)
            return [(light.project(point), book.word(id == "box" ? "motion_pin" : id == "camera" ? "motion_camera" : "motion_tray"))]
        }
        if id == "camera" {
            let p = light.project(BenchPoint(0, 61, -45))
            return [(CGPoint(x: p.x + film.width * light.scale, y: p.y + film.height * light.scale), book.word("motion_film"))]
        }
        return [(light.project(id == "box" ? BenchPoint(83, 55, -48) : BenchPoint(19, 39, -39)),
                 book.word("motion_pull"))]
    }

    private func handle(_ phase: ContactPhase, _ finger: ObjectIdentifier, _ point: CGPoint, _ light: BenchLight) {
        switch phase {
        case .down:
            let marks = targets(light)
            if action == "lift", id == "box", thumb == nil, braces, let held = hand {
                thumb = held
                thumbPoint = start
                hand = finger
                start = point
                return
            }
            guard hand == nil else { return }
            hand = finger
            start = point
            startAngle = angle ?? restingAngle
            startSlide = film
            travelPlayed = false
            report(nil)
            let close = marks.firstIndex { hypot($0.0.x - point.x, $0.0.y - point.y) <= max(30, 19 * light.scale) }
            switch (side, count, close) {
            case (0, 0, .some(let index)): action = "mark\(index)"
            case (1, 1, .some):
                action = "lift"
                if id == "box" { braces = true }
                play("pin-seat")
            case (1, 2, .some):
                action = id == "camera" ? "film" : "paper"
            default: action = "turn"
            }
        case .move:
            if finger == thumb {
                if hypot(point.x - thumbPoint.x, point.y - thumbPoint.y) > 28 {
                    settle(key: "motion_return")
                }
                return
            }
            guard finger == hand else { return }
            let dx = (point.x - start.x) / light.scale
            let dy = (point.y - start.y) / light.scale
            if action.hasPrefix("mark") && abs(dx) > 16 && abs(dx) > abs(dy) {
                action = "turn"
            }
            switch action {
            case "turn":
                angle = startAngle + max(-3.22, min(3.22, dx / 57))
            case "lift":
                if id == "box" && thumb == nil && abs(dx) > 63 {
                    settle(key: "motion_return")
                } else {
                    let travel = id == "suitcase" ? dy : -dy
                    opening = max(0, min(1, travel / (id == "box" ? 72 : 64)))
                    if lift > 0.19 && !travelPlayed {
                        travelPlayed = true
                        play(id == "box" ? "lid-hinge" : id == "suitcase" ? "tray-slide" : "pin-seat")
                    }
                }
            case "paper":
                paper = max(0, min(1, max(-dy, abs(dx) * 0.66) / 84))
                if sheet > 0.10 && !travelPlayed {
                    travelPlayed = true
                    play("paper-draw")
                }
            case "film":
                let x = max(-95, min(95, startSlide.width + dx))
                let y = max(-50, min(50, startSlide.height + dy * 0.65))
                slide = CGSize(width: x, height: y)
                let aligned = abs(x) < 9 && abs(y) < 11
                if aligned && !caught {
                    play("film-catch")
                    #if !targetEnvironment(simulator)
                    UISelectionFeedbackGenerator().selectionChanged()
                    #endif
                }
                caught = aligned
            default: break
            }
        case .up:
            if finger == thumb { settle(key: "motion_return"); return }
            guard finger == hand else { return }
            let dx = (point.x - start.x) / light.scale
            let dy = (point.y - start.y) / light.scale
            switch action {
            case "mark0", "mark1":
                if hypot(dx, dy) < 18 {
                    if id == "suitcase" { clasp(action == "mark0" ? 0 : 1) }
                    else { confirm(0) }
                }
                settle()
            case "turn":
                if abs(dx) >= 55 && abs(dx) > abs(dy) {
                    let next = 1 - side
                    let target = startAngle + (dx > 0 ? Double.pi : -Double.pi)
                    book.turn(to: next)
                    play("click")
                    hand = nil
                    action = ""
                    withAnimation(easing) { angle = target }
                } else {
                    settle(key: count == 1 && side == 1 ? "motion_touch_guide" : nil)
                }
            case "lift":
                if lift > 0.70 && (id != "box" || braces) {
                    if id == "box" { book.selectSetting(0) }
                    confirm(1)
                    settle()
                } else { settle(key: "motion_return") }
            case "paper":
                if sheet > 0.70 { confirm(2); settle() }
                else { settle(key: "motion_slip") }
            case "film":
                if caught {
                    book.selectSetting(1)
                    confirm(2)
                    settle()
                } else {
                    hand = nil
                    action = ""
                    report("motion_offset")
                    play("click")
                }
            default: settle()
            }
        case .cancel:
            if hand == finger || thumb == finger {
                if action == "film" { withAnimation(easing) { slide = startSlide } }
                settle(key: "motion_return")
            }
        }
    }

    private func clasp(_ index: Int) {
        guard latches.indices.contains(index), !latches[index] else { return }
        withAnimation(easing) { latches[index] = true }
        play("click")
        if latches.allSatisfy({ $0 }) { confirm(0) }
        else { report("motion_second_clasp") }
    }

    private func confirm(_ step: Int) {
        if book.inspect(step) {
            if step == 0 { play("click") }
            #if !targetEnvironment(simulator)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            report(step == 2 ? "motion_filed" : nil)
        }
    }

    private func settle(key: String? = nil) {
        hand = nil
        thumb = nil
        action = ""
        braces = false
        caught = false
        withAnimation(easing) {
            // The last angle may differ from the resting face by a complete turn.
            let turns = ((angle ?? restingAngle) - restingAngle) / (2 * .pi)
            angle = restingAngle + turns.rounded() * 2 * .pi
            opening = count >= 2 ? 1 : 0
            paper = count == 3 ? 1 : 0
            if id != "camera" || count == 3 { slide = nil }
        }
        if let key { report(key); play("click") }
    }

    private func drawBox(_ light: BenchLight, lift: Double, sheet: Double) {
        let rear = cos(light.yaw) < 0
        light.feet(width: 113, depth: 64)
        light.solid(-124, 0, -67, 248, 41, 134, BenchLight.walnut)
        let frontZ = rear ? -67.3 : 67.3
        for i in 0..<5 {
            let y = 7.0 + Double(i) * 5.8
            light.line([BenchPoint(-112, y, frontZ), BenchPoint(-38, y + 1, frontZ),
                        BenchPoint(42, y - 2, frontZ), BenchPoint(111, y + 0.8, frontZ)],
                       brass.opacity(i.isMultiple(of: 2) ? 0.72 : 0.38), width: 0.65)
        }
        if lift > 0.015 {
            light.face([BenchPoint(-113, 42, -61), BenchPoint(113, 42, -61), BenchPoint(113, 42, 61), BenchPoint(-113, 42, 61)],
                       color: ink, shade: burgundy, edge: brass)
            light.solid(-61, 42, 2, 119, 5, 31, brass)
            for x in stride(from: -55.0, to: 56, by: 8) {
                light.line([BenchPoint(x, 48, 2), BenchPoint(x, 48, 31)], lamp, width: 0.85)
            }
        }
        let theta = lift * 1.28
        func lid(_ x: Double, _ d: Double, _ t: Double = 0) -> BenchPoint {
            BenchPoint(x, 43 + sin(theta) * d + cos(theta) * t, -66 + cos(theta) * d - sin(theta) * t)
        }
        let border = [lid(-125, 0, 7), lid(125, 0, 7), lid(124, 133, 7), lid(-124, 133, 7)]
        light.face([lid(-124, 133), lid(124, 133), lid(124, 133, 7), lid(-124, 133, 7)], color: ink, shade: brass)
        light.face([lid(-125, 0), lid(-124, 133), lid(-124, 133, 7), lid(-125, 0, 7)], color: BenchLight.walnut)
        light.face([lid(125, 0), lid(124, 133), lid(124, 133, 7), lid(125, 0, 7)], color: BenchLight.walnut)
        light.face(border, color: BenchLight.walnut, shade: BenchLight.woodLight)
        for inset in [9.0, 15.0] {
            light.line([lid(-124 + inset, inset, 7.4), lid(124 - inset, inset, 7.4),
                        lid(124 - inset, 133 - inset, 7.4), lid(-124 + inset, 133 - inset, 7.4),
                        lid(-124 + inset, inset, 7.4)], brass, width: inset == 9 ? 1.7 : 0.65)
        }
        let inlay = (0..<32).map { i in
            let p = Double(i) * .pi / 16
            return lid(cos(p) * 27, 68 + sin(p) * 19, 8)
        }
        light.face(inlay, color: brass, shade: lamp)
        light.line([lid(-13, 60, 8.4), lid(-4, 73, 8.4), lid(2, 67, 8.4), lid(8, 77, 8.4), lid(15, 62, 8.4)], ink, width: 2)
        if rear {
            for x in [-92.0, 92] {
                light.solid(x - 13, 35, -70, 26, 13, 4, brass)
                let loose = x > 0
                let seated = braces || book.notes.setting == 0
                let shift = loose && !seated ? 5.5 * (1 - lift) : 0
                light.solid(x - 13 + shift, 48, -71, 27, 5, 6, loose && seated ? lamp : brass)
                light.oval(BenchPoint(x + 7, 42, -70.7), width: 1.7, height: 2, color: ink)
            }
            if lift > 0.08 && sheet < 0.99 {
                let x = 79 + sheet * -19
                let z = -43 - 12 * sheet
                let y = 44 + sheet * 22
                light.face([BenchPoint(x - 15, y, z - 13), BenchPoint(x + 16, y, z - 13),
                            BenchPoint(x + 16, y, z + 16), BenchPoint(x - 15, y, z + 16)], color: parchment, shade: lamp)
                light.line([BenchPoint(x - 12, y + 0.4, z), BenchPoint(x + 13, y + 0.4, z + 5)], burgundy, width: 0.8)
            }
        } else {
            light.solid(-15, 18, 67, 30, 22, 5, brass)
            light.oval(BenchPoint(0, 28, 72.3), width: 4, height: 6, color: ink)
        }
    }

    private func drawCamera(_ light: BenchLight, lift: Double) {
        let rear = cos(light.yaw) < 0
        light.solid(-117, 0, -40, 234, 94, 80, BenchLight.metal)
        light.solid(-112, 89, -39, 224, 11, 78, brass)
        light.solid(76, 100, 12, 21, 7, 23, ink)
        for x in [-107.0, 104] {
            let z = rear ? -40.5 : 40.5
            for offset in 0..<5 {
                let x = x + Double(offset) * 2.1
                light.line([BenchPoint(x, 9, z), BenchPoint(x, 82, z)], lamp.opacity(0.24), width: 0.55)
            }
        }
        if !rear {
            light.solid(-59, 11, 34, 118, 68, 22, ink)
            for (size, z, color) in [(42.0, 57.0, brass), (34, 61, ink), (26, 62, baize), (19, 62.5, .black)] {
                light.oval(BenchPoint(0, 47, z), width: size, height: size * 0.83, color: color)
            }
            light.oval(BenchPoint(-8, 55, 63), width: 6, height: 4, color: lamp.opacity(0.68))
            return
        }
        let gate = [BenchPoint(-86, 16, -41), BenchPoint(86, 16, -41), BenchPoint(86, 79, -41), BenchPoint(-86, 79, -41)]
        light.face(gate, color: ink, shade: BenchLight.metal, edge: brass)
        light.face([BenchPoint(-55, 24, -42), BenchPoint(55, 24, -42), BenchPoint(55, 72, -42), BenchPoint(-55, 72, -42)],
                   color: .black, edge: brass.opacity(0.8))
        for z in [-42.5, -43] {
            light.line([BenchPoint(-44, 72, z), BenchPoint(44, 72, z)], brass, width: 0.72)
        }

        if lift > 0.18 {
            let scratches = [BenchPoint(19, 63, -43), BenchPoint(3, 49, -43), BenchPoint(9, 48, -43), BenchPoint(-12, 33, -43)]
            light.line(scratches, caught ? .mint : lamp, width: 1.7)
            if count >= 2 {
                let movement = count == 3 ? CGSize.zero : film
                let p = light.project(BenchPoint(0, 61, -45))
                let x = p.x + movement.width * light.scale
                let y = p.y + movement.height * light.scale
                let r = CGRect(x: x - 50 * light.scale, y: y - 16 * light.scale,
                               width: 100 * light.scale, height: 55 * light.scale)
                let window = Path(roundedRect: r, cornerRadius: 3)
                let reflection = Path(roundedRect: r.offsetBy(dx: -movement.width * light.scale * 0.16,
                                                                   dy: 4 * light.scale), cornerRadius: 3)
                light.context.fill(reflection, with: .color(.black.opacity(0.22)))
                light.context.fill(window, with: .color(caught ? .mint.opacity(0.26) : Color(red: 0.77, green: 0.56, blue: 0.35).opacity(0.35)))
                light.context.stroke(window, with: .color(caught ? .mint : brass), lineWidth: light.scale)
                let offset = CGPoint(x: movement.width * light.scale, y: movement.height * light.scale)
                let trace = Path { path in
                    let points = scratches.map(light.project).map { CGPoint(x: $0.x + offset.x, y: $0.y + offset.y) }
                    path.move(to: points[0])
                    for point in points.dropFirst() { path.addLine(to: point) }
                }
                light.context.stroke(trace, with: .color(caught ? .mint : Color(red: 0.99, green: 0.71, blue: 0.40)),
                                     lineWidth: light.scale * 1.2)
                for lane in [r.minY + 4 * light.scale, r.maxY - 6 * light.scale] {
                    for column in 0..<8 {
                        let hole = CGRect(x: r.minX + (5 + 12 * Double(column)) * light.scale, y: lane,
                                          width: 5 * light.scale, height: 2.5 * light.scale)
                        light.context.fill(Path(roundedRect: hole, cornerRadius: 1), with: .color(ink.opacity(0.64)))
                    }
                }
            }
        }
        let a = lift * 2.36
        func door(_ x: Double, _ h: Double) -> BenchPoint { BenchPoint(x, 88 - cos(a) * h, -43 - sin(a) * h) }
        light.face([door(-104, 0), door(104, 0), door(104, 82), door(-104, 82)],
                   color: BenchLight.metal, shade: ink, edge: brass)
        light.line([door(-92, 64), door(92, 64)], brass, width: 1.25)
        light.line([door(76, 72), door(91, 72)], lamp, width: 3)
    }

    private func drawCase(_ light: BenchLight, lift: Double) {
        let rear = cos(light.yaw) < 0
        light.feet(width: 130, depth: 58)
        light.solid(-143, 0, -60, 286, 52, 120, BenchLight.leather)
        if rear && lift > 0.03 {
            let drawerZ = -58 - lift * 43
            light.solid(-116, 31, drawerZ, 232, 6, 104, ink)
            light.face([BenchPoint(-109, 39, drawerZ + 4), BenchPoint(109, 39, drawerZ + 4),
                        BenchPoint(109, 39, drawerZ + 81), BenchPoint(-109, 39, drawerZ + 81)],
                       color: baize, shade: burgundy, edge: brass)
            for dx in [-26.0, 11] {
                light.face([BenchPoint(dx, 40, -57), BenchPoint(dx + 33, 40, -57),
                            BenchPoint(dx + 31, 40, -18), BenchPoint(dx - 2, 40, -18)],
                           color: parchment, shade: lamp, edge: brass)
            }
            light.solid(-25, 38, drawerZ - 4, 50, 5, 5, brass)
        }
        if rear && lift < 0.18 {
            light.solid(29, 37, -66, 42, 9, 6, brass)
            light.line([BenchPoint(35, 43, -67), BenchPoint(64, 43, -67)], lamp)
        }
        let topDepth = 120 - (rear ? lift * 75 : 0)
        light.solid(-144, 51, 60 - topDepth, 288, 10, topDepth, BenchLight.leather)
        for x in [-105.0, 96] {
            light.face([BenchPoint(x, 61.4, 57 - topDepth), BenchPoint(x + 13, 61.4, 57 - topDepth),
                        BenchPoint(x + 13, 61.4, 57), BenchPoint(x, 61.4, 57)], color: ink, shade: burgundy, edge: brass)
        }
        let z = rear ? -60.8 : 60.8
        if !rear {
            let grip = (0...18).map { index in
                let t = Double(index) / 18
                return BenchPoint(-35 + 70 * t, 37 - sin(.pi * t) * 20, 62)
            }
            light.line(grip, ink, width: 9)
            light.line(grip, brass, width: 5.5)
        }
        for (index, x) in [-72.0, 72].enumerated() {
            let latched = count > 0 || latches[index]
            light.solid(x - 11, latched ? 22 : 39, z - 2, 22, 13, 5, brass)
            light.line([BenchPoint(x - 1, latched ? 29 : 46, z + (rear ? -2.8 : 2.8)),
                        BenchPoint(x + 3, latched ? 29 : 46, z + (rear ? -2.8 : 2.8))], lamp, width: 1.9)
        }
    }

    private func slidingPaper(_ light: BenchLight) -> some View {
        let anchor = light.project(id == "box" ? BenchPoint(83, 55, -48) : BenchPoint(19, 39, -39))
        let width = min(282, 191 * light.scale)
        return VStack(alignment: .leading, spacing: 5) {
            Text(book.word(id == "box" ? "motion_note_title" : "motion_manifest"))
                .font(.system(.caption, design: .serif, weight: .bold))
            Rectangle().fill(brass).frame(height: 1)
            if id == "box" {
                Text(book.item.visitors[0].name).font(.system(.title3, design: .serif).italic())
                Text(book.word("motion_note_match")).font(.system(.caption2, design: .serif))
            } else {
                Text(book.cardTitle("file.thermos") + " · " + book.cardTitle("file.puppet"))
                    .font(.system(.subheadline, design: .serif))
            }
        }
        .padding(12).frame(width: width, alignment: .leading)
        .foregroundStyle(ink)
        .background(LinearGradient(colors: [lamp, parchment], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(Rectangle().strokeBorder(brass, lineWidth: 1))
        .shadow(color: .black.opacity(0.5), radius: 5 + sheet * 8, x: 3, y: 8)
        .scaleEffect(0.35 + 0.65 * sheet)
        .rotationEffect(.degrees(-23 + sheet * 17))
        .position(x: anchor.x + (light.center.x - anchor.x) * sheet,
                  y: anchor.y - 124 * sheet * min(light.scale, 1.7))
        .opacity(min(1, sheet * 5))
        .allowsHitTesting(false)
        .accessibilityHidden(sheet < 0.95)
        .environment(\.layoutDirection, book.localeCode == "ar" ? .rightToLeft : .leftToRight)
    }
}

struct Desk: View {
    let book: CaseBook
    let wide: Bool
    let play: (String) -> Void
    @State private var hint = false
    @State private var filedObjection = false
    @State private var showNotebook = false
    @State private var motionMessage: String?
    @State private var showMechanismDetail = false
    @State private var stampDepth: Double = 0
    @State private var impression = false
    @State private var stamping = false
    @GestureState private var stampContact = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        switch book.notes.surface {
        case "talk": conversation
        case "receipt": form
        default: workbench
        }
    }

    private var workbench: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if HeldObject.items.contains(book.item.id) {
                    HeldObject(book: book, play: play, fallback: touchDetail) { motionMessage = $0 }
                } else {
                    ObjectStage(id: book.item.id, face: book.notes.face,
                                progress: book.notes.findings.count, immersive: true,
                                position: book.notes.setting ?? (book.item.id == "camera" && nextStep == 2 ? 0 : nil),
                                hotspot: touchPoint, hotspotLabel: touchLabel, drag: dragObject) {
                        if let step = nextStep { touchDetail(step) }
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 9) {
                        CaseHeading(book: book)
                        Button {
                            showNotebook = true
                        } label: {
                            Image(systemName: "book")
                                .font(.system(size: 19, weight: .medium))
                                .frame(width: 48, height: 48)
                                .background(ink.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(brass.opacity(0.65)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(book.word("notebook"))
                        .accessibilityIdentifier("open-notebook")
                    }
                    .padding(.horizontal, 17).padding(.top, 11)

                    if let objection = book.notes.objection, book.notes.objectionFolded != true {
                        VStack(spacing: 8) {
                            Docket(title: book.word("objection"), detail: book.item.contradictions[objection], selected: true)
                                .accessibilityIdentifier("objection")
                            ActionRow(title: book.word("fold_objection"), icon: "bookmark") {
                                book.foldObjection(true)
                            }
                            .accessibilityIdentifier("fold-objection")
                        }
                        .frame(maxWidth: 620)
                        .padding(.horizontal, 17).padding(.top, 8)
                        .frame(maxWidth: .infinity)
                    }
                    Spacer(minLength: 0)
                    if textSize.isAccessibilitySize && geometry.size.height < 750 {
                        ViewThatFits(in: .vertical) {
                            toolShelf
                            ScrollView { toolShelf }.frame(maxHeight: geometry.size.height * 0.48)
                        }
                    } else {
                        toolShelf
                    }
                }
            }
        }
        .sheet(isPresented: $showNotebook) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(book.word("notebook")).font(.system(.title2, design: .serif))
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button { showNotebook = false } label: {
                        Image(systemName: "xmark").frame(width: 48, height: 48)
                            .background(brass.opacity(0.16), in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(book.word("close_notebook"))
                    .accessibilityIdentifier("close-notebook")
                }
                ScrollView { notebook }
            }
            .padding(17)
            .foregroundStyle(lamp)
            .background(ink.ignoresSafeArea())
        }
        .sheet(isPresented: $showMechanismDetail) {
            VStack(alignment: .leading, spacing: 12) {
                ActionRow(title: book.word("close_detail"), icon: "xmark", filled: true) {
                    showMechanismDetail = false
                }
                .accessibilityIdentifier("close-mechanism-details")
                ScrollView {
                    Docket(title: book.word("try_again"), detail: book.word(book.item.id == "keys" ? "teeth_wrong" : "camera_wrong"))
                }
            }
            .padding(17)
            .foregroundStyle(lamp)
            .background(ink.ignoresSafeArea())
            .presentationDetents([.medium])
        }
    }

    private func dragObject(_ movement: CGSize) {
        guard abs(movement.width) > abs(movement.height) else { return }
        if book.notes.face == 1 && book.item.id == "camera" && nextStep == 2 {
            let position = (book.notes.setting ?? 0) + (movement.width > 0 ? 1 : -1)
            book.selectSetting(max(0, min(2, position)))
        } else if book.notes.face == 1 && book.item.id == "punch" && nextStep == 1 {
            book.selectSetting(0)
        } else {
            book.turn(to: 1 - book.notes.face)
        }
        hint = false
    }

    private var toolShelf: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let motionMessage {
                Text(book.word(motionMessage))
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .accessibilityIdentifier("motion-feedback")
            } else if HeldObject.items.contains(book.item.id), let guide = motionGuide {
                Text(book.word(guide)).font(.system(.caption, design: .serif)).foregroundStyle(lamp.opacity(0.9))
            }
            if let step = nextStep {
                if book.item.id == "keys" && step == 1 { toothPicker }
                if !book.settingOptions.isEmpty { settingPicker }
                if hint && ["camera", "keys"].contains(book.item.id) {
                    comparisonRetry
                } else if hint {
                    Docket(title: book.word("try_again"), detail: book.word(book.item.id + "_wrong"))
                        .accessibilityIdentifier("wrong-setting")
                }
                ActionRow(title: book.item.findings[step].action, icon: "hand.tap", filled: true) {
                    examine(step)
                }
                .accessibilityIdentifier("find-\(step)")
            } else if book.notes.findings.count < book.item.findings.count {
                Text(book.word("turn_hint")).font(.system(.subheadline, design: .serif))
            }
            HStack(spacing: 8) {
                rotation(0)
                Spacer(minLength: 0)
                if book.item.id == "box" || book.item.id == "metronome" {
                    Button {
                        if book.item.id == "box" { play("melody") } else { playTicks() }
                    } label: {
                        Image(systemName: "waveform").frame(width: 48, height: 44)
                            .background(ink.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(brass.opacity(0.55)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(book.word(book.item.id == "box" ? "listen_box" : "listen_tick"))
                    .accessibilityIdentifier(book.item.id == "box" ? "play-melody" : "play-ticks")
                }
                rotation(1)
            }
            if book.item.id == "metronome" {
                beatStrip
                Text(book.word("notes_tick"))
                    .font(.system(.caption, design: .monospaced))
                    .accessibilityIdentifier("sound-transcript")
            }
        }
        .frame(maxWidth: wide ? 690 : 580)
        .padding(.horizontal, 17).padding(.top, 13).padding(.bottom, 11)
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(colors: [ink.opacity(0.80), ink.opacity(0.98)], startPoint: .top, endPoint: .bottom)
        }
    }

    private var motionGuide: String? {
        if book.notes.face == 0 { return "motion_turn" }
        switch (book.item.id, book.notes.findings.count) {
        case ("box", 1): return "motion_pin"
        case ("camera", 1): return "motion_camera"
        case ("camera", 2): return "motion_film"
        case ("suitcase", 1): return "motion_tray"
        case (_, 2): return "motion_pull"
        default: return nil
        }
    }

    private var touchLabel: String? {
        guard let step = nextStep else { return nil }
        if book.notes.setting == nil, let setting = book.settingOptions.first, book.settingOptions.count == 1 {
            return book.word(setting)
        }
        if book.settingOptions.count > 1 && !(book.item.id == "camera" && book.notes.setting == 1) {
            return book.word(book.item.id + "_setting")
        }
        return book.item.findings[step].action
    }

    private var touchPoint: CGPoint? {
        guard let step = nextStep else { return nil }
        let points: [String: [CGPoint]] = [
            "box": [CGPoint(x: 232, y: 93), CGPoint(x: 87, y: 117), CGPoint(x: 111, y: 135)],
            "umbrella": [CGPoint(x: 168, y: 114), CGPoint(x: 169, y: 123), CGPoint(x: 177, y: 119)],
            "thermos": [CGPoint(x: 158, y: 107), CGPoint(x: 106, y: 135), CGPoint(x: 65, y: 163)],
            "punch": [CGPoint(x: 127, y: 119), CGPoint(x: 82, y: 139), CGPoint(x: 121, y: 162)],
            "mittens": [CGPoint(x: 195, y: 157), CGPoint(x: 94, y: 118), CGPoint(x: 158, y: 110)],
            "glasses": [CGPoint(x: 159, y: 143), CGPoint(x: 83, y: 106), CGPoint(x: 193, y: 115)],
            "metronome": [CGPoint(x: 166, y: 96), CGPoint(x: 175, y: 113), CGPoint(x: 190, y: 92)],
            "lantern": [CGPoint(x: 163, y: 104), CGPoint(x: 203, y: 110), CGPoint(x: 164, y: 104)],
            "puppet": [CGPoint(x: 84, y: 99), CGPoint(x: 224, y: 92), CGPoint(x: 250, y: 88)],
            "camera": [CGPoint(x: 155, y: 109), CGPoint(x: 196, y: 106), CGPoint(x: 194, y: 105)],
            "keys": [CGPoint(x: 151, y: 52), CGPoint(x: 267, y: 111), CGPoint(x: 198, y: 141)],
            "suitcase": [CGPoint(x: 162, y: 108), CGPoint(x: 154, y: 136), CGPoint(x: 159, y: 135)]
        ]
        return points[book.item.id]?[step]
    }

    private func touchDetail(_ step: Int) {
        if book.settingOptions.count == 1 && book.notes.setting == nil {
            book.selectSetting(0)
            play("click")
            hint = false
        } else if book.settingOptions.count > 1 &&
                    !(book.item.id == "camera" && book.notes.setting == 1) {
            book.selectSetting(((book.notes.setting ?? -1) + 1) % book.settingOptions.count)
            play("click")
            hint = false
        } else {
            examine(step)
        }
    }

    private var settingPicker: some View {
        let options = book.settingOptions
        return VStack(alignment: .leading, spacing: 6) {
            if book.item.id == "camera" && options.count == 3 {
                Text(book.word("camera_align_short")).font(.system(.subheadline, design: .serif))
                HStack(spacing: 8) {
                    ForEach(Array(options.enumerated()), id: \.element) { position, label in
                        cameraPosition(position, label: label)
                    }
                }
            } else {
                if options.count > 1 {
                    Text(book.word(book.item.id + "_setting")).font(.system(.body, design: .serif))
                }
                ForEach(Array(options.enumerated()), id: \.element) { position, label in
                    let selected = book.notes.setting == position
                    ActionRow(title: book.word(label),
                              icon: selected ? "checkmark.circle.fill" : "circle", filled: selected) {
                        setPosition(position)
                    }
                    .accessibilityAddTraits(selected ? [.isSelected] : [])
                    .accessibilityIdentifier("setting-\(position)")
                }
            }
        }
    }

    private func cameraPosition(_ position: Int, label: String) -> some View {
        let selected = book.notes.setting == position
        return Button { setPosition(position) } label: {
            Image(systemName: ["arrow.left", "viewfinder", "arrow.right"][position])
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
                .foregroundStyle(selected ? ink : lamp)
                .background(selected ? lamp : ink.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(brass.opacity(0.68)))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(book.word(label))
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .accessibilityIdentifier("setting-\(position)")
    }

    private func setPosition(_ position: Int) {
        book.selectSetting(position)
        play("click")
        hint = false
    }

    private var comparisonRetry: some View {
        HStack(spacing: 8) {
            Text(book.word(book.item.id == "keys" ? "keys_retry_short" : "camera_retry_short"))
                .font(.system(.subheadline, design: .serif, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(book.item.id == "keys" ? "wrong-teeth" : "wrong-setting")
            Spacer(minLength: 0)
            Button {
                showMechanismDetail = true
            } label: {
                Image(systemName: "info.circle").frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(book.word("why_mismatch"))
            .accessibilityIdentifier("mechanism-details")
        }
        .padding(.leading, 10)
        .foregroundStyle(ink)
        .background(parchment, in: RoundedRectangle(cornerRadius: 5))
    }

    @State private var pulse: Int? = nil
    @State private var beatTask: Task<Void, Never>?

    private var beatStrip: some View {
        HStack(spacing: 6) {
            ForEach(0..<5) { index in
                Circle().fill(pulse == index ? lamp : brass.opacity(0.48)).frame(width: 12, height: 12)
                if index < 4 { Rectangle().fill(brass.opacity(0.44)).frame(width: index == 2 ? 28 : 12, height: 1) }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityHidden(true)
    }

    private func playTicks() {
        play("ticks")
        beatTask?.cancel()
        beatTask = Task { @MainActor in
            for (index, wait) in [450, 450, 630, 450, 350].enumerated() {
                pulse = index
                try? await Task.sleep(for: .milliseconds(wait))
                if Task.isCancelled { return }
            }
            pulse = nil
        }
    }

    private var nextStep: Int? {
        let step = book.notes.findings.count
        guard step < book.item.findings.count, book.notes.face == (step == 0 ? 0 : 1) else { return nil }
        return step
    }

    private func examine(_ step: Int) {
        motionMessage = nil
        if book.inspect(step) {
            if book.item.id == "metronome" && step == 1 { playTicks() }
            else { play("click") }
            hint = false
        } else {
            hint = true
        }
    }

    private func rotation(_ face: Int) -> some View {
        Button {
            hint = false
            book.turn(to: face)
        } label: {
            Label(book.word(face == 0 ? "front" : "back"),
                  systemImage: face == 0 ? "arrow.counterclockwise" : "arrow.clockwise")
                .font(.system(.subheadline, design: .serif,
                              weight: book.notes.face == face ? .bold : .regular))
                .padding(.horizontal, 10)
                .frame(minHeight: 44)
                .background(book.notes.face == face ? baize : ink, in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(brass.opacity(0.55)))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(book.notes.face == face ? [.isSelected] : [])
        .accessibilityIdentifier("face-\(face)")
    }

    private var toothPicker: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(book.word("teeth_hint")).font(.system(.body, design: .serif))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                ForEach(0..<4) { tooth in
                    let selected = book.notes.teeth.contains(tooth)
                    ActionRow(title: book.word("tooth_\(tooth)"),
                              icon: selected ? "checkmark.square" : "square", filled: selected) {
                        hint = false
                        book.toggleTooth(tooth)
                    }
                    .accessibilityAddTraits(selected ? [.isSelected] : [])
                    .accessibilityIdentifier("tooth-\(tooth)")
                }
            }
        }
    }

    private var notebook: some View {
        VStack(alignment: .leading, spacing: 8) {
            if book.item.id == "box" {
                Text(book.word("notes_box")).font(.system(.caption, design: .monospaced))
                    .accessibilityIdentifier("sound-transcript")
            }
            if book.notes.findings.isEmpty {
                Text(book.word("empty_notebook"))
                    .font(.system(.body, design: .serif))
            }
            if let objection = book.notes.objection, book.notes.objectionFolded == true {
                ActionRow(title: book.word("read_objection"), icon: "bookmark") { filedObjection.toggle() }
                    .accessibilityIdentifier("read-objection")
                if filedObjection {
                    Docket(title: book.word("objection"), detail: book.item.contradictions[objection])
                        .accessibilityIdentifier("filed-objection")
                }
            }
            ForEach(book.item.findings.filter { book.notes.findings.contains($0.id) }) { finding in
                Docket(title: finding.title, detail: finding.detail)
                    .accessibilityIdentifier("observed-" + finding.id)
            }
        }
    }

    private var conversation: some View {
        let speaker = book.notes.speaker
        let visitor = book.item.visitors[speaker]
        let recorded = book.notes.questions[visitor.id]
        let chosen = book.notes.reread[visitor.id] ?? recorded
        return VStack(alignment: .leading, spacing: 13) {
            if wide {
                HStack(alignment: .center, spacing: 20) {
                    Portrait(id: book.item.id, index: speaker).frame(width: 200, height: 220)
                    Docket(title: visitor.name + " · " + visitor.role, detail: visitor.claim)
                }
            } else {
                Portrait(id: book.item.id, index: speaker).frame(height: 120)
                Docket(title: visitor.name + " · " + visitor.role, detail: visitor.claim)
            }
            if let chosen {
                Docket(title: visitor.questions[chosen], detail: visitor.answers[chosen], selected: true)
                    .accessibilityIdentifier("answer-\(chosen)")
                if book.item.id == "box" && speaker == 0 && chosen == 1 {
                    ObjectStage(id: "box", face: 1, progress: 1, wide: wide, position: 0)
                }
            }
            if recorded == nil || book.issued != nil {
                Text(book.word(book.issued == nil ? "question_limit" : "review"))
                    .font(.system(.subheadline, design: .serif))
                ForEach(visitor.questions.indices, id: \.self) { index in
                    ActionRow(title: visitor.questions[index], icon: "quote.bubble") {
                        book.ask(index)
                    }
                    .accessibilityIdentifier("question-\(index)")
                }
            }
            if book.item.id == "box" {
                ActionRow(title: book.word("listen_box"), icon: "waveform") { play("melody") }
                .accessibilityIdentifier("play-melody")
                Text(book.word("notes_box")).font(.system(.caption, design: .monospaced))
                    .accessibilityIdentifier("sound-transcript")
            }
            ActionRow(title: book.item.visitors[1 - speaker].name, icon: "person.crop.circle") {
                book.talk(1 - speaker)
            }
            .accessibilityIdentifier("other-visitor")
        }
        .frame(maxWidth: 760, alignment: .leading)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            if wide {
                HStack(alignment: .top, spacing: 20) {
                    recipients.frame(maxWidth: .infinity)
                    attachments.frame(maxWidth: .infinity)
                }
            } else {
                recipients
                attachments
            }
            let who = book.notes.owner.map { book.item.visitors[$0].name } ?? book.word("empty_owner")
            stampingDesk(recipient: who)
            if book.canStamp {
                Text(book.word("motion_stamp")).font(.system(.caption, design: .serif))
            }
            ActionRow(title: book.word("stamp"), icon: "seal", filled: true) {
                stampReceipt()
            }
            .opacity(book.canStamp ? 1 : 0.53)
            .disabled(!book.canStamp || stamping)
            .accessibilityIdentifier("stamp")
            if book.item.id == "suitcase" && !book.notes.findings.contains("match") {
                Text(book.word("suitcase_hint")).font(.system(.subheadline, design: .serif))
            }
        }
    }

    private func stampingDesk(recipient: String) -> some View {
        let evidence = book.notes.evidence.map { book.cardTitle($0) }.joined(separator: " + ")
        return ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 9) {
                Text(book.word("draft")).font(.system(.caption, design: .monospaced, weight: .semibold))
                Rectangle().fill(brass).frame(height: 1)
                Text(recipient).font(.system(.headline, design: .serif))
                Text(evidence).font(.system(.body, design: .serif))
            }
            .padding(14).padding(.trailing, 91)
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .foregroundStyle(ink)
            .background(LinearGradient(colors: [lamp, parchment], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(Rectangle().strokeBorder(brass.opacity(0.75)))
            .overlay(alignment: .bottomTrailing) {
                if impression {
                    Image(systemName: "seal").font(.system(size: 33, weight: .medium))
                        .rotationEffect(.degrees(-12)).foregroundStyle(burgundy)
                        .frame(width: 50, height: 38)
                        .padding(.trailing, 20.5).padding(.bottom, 2)
                        .accessibilityIdentifier("stamp-impression")
                }
            }
            .shadow(color: .black.opacity(0.45), radius: 6, y: 4)
            .offset(x: reduceMotion ? 0 : 8 - 8 * stampDepth, y: reduceMotion ? 0 : -6 + 6 * stampDepth)
            .accessibilityIdentifier("draft")
            ZStack {
                BenchPainting(yaw: stampDepth, lid: 0, paper: 0) { context, travel, _, _ in
                    let x = 45.5
                    let y = 43 + (reduceMotion ? 0 : travel * 37)
                    let foot = CGRect(x: x - 31, y: y + 36, width: 62, height: 17)
                    context.fill(Path(ellipseIn: foot.offsetBy(dx: 4, dy: 9)), with: .color(.black.opacity(0.25)))
                    context.fill(Path(roundedRect: foot, cornerRadius: 6), with: .linearGradient(
                        Gradient(colors: [lamp, brass, burgundy]), startPoint: CGPoint(x: x - 23, y: y + 36),
                        endPoint: CGPoint(x: x + 26, y: y + 54)))
                    context.fill(Path(roundedRect: CGRect(x: x - 10, y: y + 10, width: 20, height: 33), cornerRadius: 5), with: .color(brass))
                    context.fill(Path(ellipseIn: CGRect(x: x - 23, y: y - 5, width: 46, height: 26)), with: .linearGradient(
                        Gradient(colors: [Color(red: 0.66, green: 0.35, blue: 0.23), burgundy, ink]),
                        startPoint: CGPoint(x: x - 18, y: y), endPoint: CGPoint(x: x + 20, y: y + 22)))
                }
                .accessibilityHidden(true)
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 0)
                        .updating($stampContact) { _, held, _ in held = true }
                        .onChanged { value in
                            guard book.canStamp, !stamping else { return }
                            stampDepth = max(0, min(1, value.translation.height / 39))
                        }.onEnded { value in
                            guard !stamping else { return }
                            if value.translation.height > 27 { stampReceipt() }
                            else { releaseStamp() }
                        })
                    .onChange(of: stampContact) { _, held in
                        if !held && !stamping { releaseStamp() }
                    }
            }
            .frame(width: 91, height: 145)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(book.word("motion_stamp"))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { stampReceipt() }
            .accessibilityIdentifier("stamp-tool")
        }
        .padding(.horizontal, 5)
    }

    private func releaseStamp() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) { stampDepth = 0 }
    }

    private func stampReceipt() {
        guard book.canStamp, !stamping else { return }
        stamping = true
        let item = book.item.id
        let owner = book.notes.owner
        let evidence = book.notes.evidence
        Task { @MainActor in
            defer { stamping = false; stampDepth = 0; impression = false }
            withAnimation(reduceMotion ? nil : .easeIn(duration: 0.16)) { stampDepth = 1 }
            try? await Task.sleep(for: .milliseconds(155))
            guard book.item.id == item, book.notes.surface == "receipt", book.notes.owner == owner,
                  book.notes.evidence == evidence, book.canStamp else { return }
            play("stamp")
            #if !targetEnvironment(simulator)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            impression = true
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.24)) { stampDepth = 0 }
            try? await Task.sleep(for: .milliseconds(230))
            guard book.item.id == item, book.notes.surface == "receipt", book.notes.owner == owner,
                  book.notes.evidence == evidence else { return }
            _ = book.stamp()
        }
    }

    private var recipients: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.word("recipient")).font(.system(.title2, design: .serif))
                .accessibilityAddTraits(.isHeader)
            ForEach(book.visitorOrder.indices, id: \.self) { seat in
                let index = book.visitorOrder[seat]
                let selected = book.notes.owner == index
                ActionRow(title: book.item.visitors[index].name,
                          icon: selected ? "checkmark.circle.fill" : "circle", filled: selected) {
                    book.chooseOwner(index)
                }
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityIdentifier("owner-\(seat)")
            }
        }
    }

    @State private var showCards = false

    private var attachments: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.word(book.item.id == "suitcase" ? "archive_copies" : "evidence"))
                .font(.system(.title2, design: .serif)).accessibilityAddTraits(.isHeader)
            ForEach(0..<book.slots, id: \.self) { slot in
                let id = book.notes.evidence.indices.contains(slot) ? book.notes.evidence[slot] : nil
                ActionRow(title: id.map { book.cardTitle($0) } ?? book.word("empty_slot"),
                          icon: id == nil ? "plus.square.dashed" : "paperclip", filled: id != nil) {
                    showCards = true
                }
                .accessibilityIdentifier("slot-\(slot)")
            }
            ActionRow(title: book.word("cards"), icon: "rectangle.on.rectangle") { showCards = true }
                .accessibilityIdentifier("cards")
            if let guide = book.item.proofGuide {
                DisclosureGroup(book.word("proof_help")) {
                    Text(guide).font(.system(.subheadline, design: .serif))
                }
                .tint(lamp)
            }
        }
        .sheet(isPresented: $showCards) {
            VStack(alignment: .leading, spacing: 8) {
                ActionRow(title: book.word("done"), icon: "checkmark", filled: true) { showCards = false }
                    .accessibilityIdentifier("cards-done")
                Text(book.word("choose_card"))
                    .font(.system(.title2, design: .serif))
                    .accessibilityAddTraits(.isHeader)
                ScrollView {
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(book.cards, id: \.self) { id in evidenceCard(id) }
                    }
                }
                .accessibilityIdentifier("cards-scroll")
            }
            .padding(17)
            .foregroundStyle(lamp)
            .background(ink.ignoresSafeArea())
        }
    }

    private func evidenceCard(_ id: String) -> some View {
        let selected = book.notes.evidence.contains(id)
        return VStack(alignment: .leading, spacing: 0) {
            Docket(title: book.cardTitle(id), detail: book.cardDetail(id), selected: selected)
            ActionRow(title: book.word(selected ? "detach" : "attach"),
                      icon: selected ? "minus.circle" : "paperclip") {
                book.attach(id)
            }
            .disabled(!selected && book.notes.evidence.count >= book.slots)
            .accessibilityLabel(book.word(selected ? "detach" : "attach") + " · " + book.cardTitle(id))
            .accessibilityIdentifier("card-" + id)
        }
    }
}
