import AVFoundation
import AppKit

let source = URL(fileURLWithPath: CommandLine.arguments[1])
let frameTime = CMTime(seconds: Double(CommandLine.arguments[2])!, preferredTimescale: 600)
let asset = AVURLAsset(url: source)
let frames = AVAssetImageGenerator(asset: asset)
frames.appliesPreferredTrackTransform = true
frames.requestedTimeToleranceBefore = CMTime(seconds: 0.25, preferredTimescale: 600)
frames.requestedTimeToleranceAfter = CMTime(seconds: 0.25, preferredTimescale: 600)
frames.maximumSize = CGSize(width: 900, height: 900)
let frame = try frames.copyCGImage(at: frameTime, actualTime: nil)
try NSBitmapImageRep(cgImage: frame).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[3]))
