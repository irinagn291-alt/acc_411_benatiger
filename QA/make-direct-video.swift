import AVFoundation
import CoreGraphics
import Foundation

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
let asset = AVURLAsset(url: input)
let source = try await asset.loadTracks(withMediaType: .video)[0]
let nativeSize = try await source.load(.naturalSize)
let timeline = AVMutableComposition()
let track = timeline.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let canvas = CGSize(width: 1440, height: 1080)

func time(_ seconds: Double) -> CMTime { CMTime(seconds: seconds, preferredTimescale: 600) }
let sourceStart = time(26.8)
let sourcePivot = time(32.6)
let sourceEnd = time(45.9)
try track.insertTimeRange(CMTimeRange(start: sourceStart, end: sourceEnd), of: source, at: .zero)

let portraitScale = canvas.height / nativeSize.height
let landscapeScale = canvas.height / nativeSize.width
let portrait = CGAffineTransform(
    a: portraitScale, b: 0, c: 0, d: portraitScale,
    tx: (canvas.width - nativeSize.width * portraitScale) / 2, ty: 0
)
let landscape = CGAffineTransform(
    a: 0, b: -landscapeScale, c: landscapeScale, d: 0,
    tx: (canvas.width - nativeSize.height * landscapeScale) / 2, ty: canvas.height
)

func instruction(_ transform: CGAffineTransform, _ range: CMTimeRange) -> AVMutableVideoCompositionInstruction {
    let scene = AVMutableVideoCompositionInstruction()
    scene.timeRange = range
    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    layer.setTransform(transform, at: range.start)
    scene.layerInstructions = [layer]
    return scene
}
let pivot = sourcePivot - sourceStart
let duration = sourceEnd - sourceStart
let video = AVMutableVideoComposition()
video.frameDuration = CMTime(value: 1, timescale: 30)
video.renderSize = canvas
video.instructions = [
    instruction(portrait, .init(start: .zero, end: pivot)),
    instruction(landscape, .init(start: pivot, end: duration)),
]
let exporter = AVAssetExportSession(asset: timeline, presetName: AVAssetExportPreset1920x1080)!
exporter.videoComposition = video
try await exporter.export(to: output, as: .mov)
print("Exported \(duration.seconds) sec")
