//
//  VideoEditorManager.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 19/01/2025.
//

import UIKit
import AVFoundation
import Photos

class VideoEditorManager {
	func createTemporaryDirectory() -> URL? {
		let tempDirectory = FileManager.default.temporaryDirectory
		let outputFileName = "watermarked_video.mp4"
		let outputURL = tempDirectory.appendingPathComponent(outputFileName)
		
		if FileManager.default.fileExists(atPath: outputURL.path) {
			do {
				try FileManager.default.removeItem(at: outputURL)
			} catch {
				print("Failed to remove existing file: \(error)")
				return nil
			}
		}
		
		return outputURL
	}
	
	func createVideo(inputURL: URL) async {
		let result = await makeBirthdayCard(fromVideoAt: inputURL)
		
		switch result {
		case .success(let videoURL):
			let saveResult = await saveVideoToLibrary(videoURL: videoURL)
			switch saveResult {
			case .success(_):
				print("SAVED")
			case .failure(let failure):
				print("Error: \(failure)")
			}
		case .failure(let failure):
			print("ERROR: \(failure)")
		}
	}
	
	func saveVideoToLibrary(videoURL: URL) async -> Result<Void, Error> {
		do {
			try await PHPhotoLibrary.shared().performChanges {
				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
			}
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	func makeBirthdayCard(fromVideoAt videoURL: URL) async -> Result<URL, Error> {
		print(videoURL)
		let asset = AVURLAsset(url: videoURL)
		let composition = AVMutableComposition()
		
		guard
			let compositionTrack = composition.addMutableTrack(
				withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
			let assetTrack = asset.tracks(withMediaType: .video).first
		else {
			print("Something is wrong with the asset.")
			let error = NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve file URL"])
			return .failure(error)
		}
		
		do {
			let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
			try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
			
			if let audioAssetTrack = try await asset.loadTracks(withMediaType: .audio).first,
			   let compositionAudioTrack = composition.addMutableTrack(
				withMediaType: .audio,
				preferredTrackID: kCMPersistentTrackID_Invalid) {
				try compositionAudioTrack.insertTimeRange(
					timeRange,
					of: audioAssetTrack,
					at: .zero)
			}
		} catch {
			print("ERROR: \(error)")
			return .failure(error)
		}
		
		compositionTrack.preferredTransform = assetTrack.preferredTransform
		let videoInfo = orientation(from: assetTrack.preferredTransform)
		
		let videoSize: CGSize
		if videoInfo.isPortrait {
			videoSize = CGSize(width: assetTrack.naturalSize.height, height: assetTrack.naturalSize.width)
		} else {
			videoSize = assetTrack.naturalSize
		}
		
		let videoLayer = CALayer()
		videoLayer.frame = CGRect(origin: .zero, size: videoSize)
		let overlayLayer = CALayer()
		overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
		
		videoLayer.frame = CGRect(x: 20, y: 20, width: videoSize.width - 40, height: videoSize.height - 40)
		
		addImage(to: overlayLayer, videoSize: videoSize)
		
		let outputLayer = CALayer()
		outputLayer.frame = CGRect(origin: .zero, size: videoSize)
		outputLayer.addSublayer(videoLayer)
		outputLayer.addSublayer(overlayLayer)
		
		let videoComposition = AVMutableVideoComposition()
		videoComposition.renderSize = videoSize
		videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
		videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
			postProcessingAsVideoLayer: videoLayer,
			in: outputLayer)
		
		let instruction = AVMutableVideoCompositionInstruction()
		instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
		videoComposition.instructions = [instruction]
		let layerInstruction = compositionLayerInstruction(for: compositionTrack, assetTrack: assetTrack)
		instruction.layerInstructions = [layerInstruction]
		
		guard let exportSession = AVAssetExportSession(
			asset: composition,
			presetName: AVAssetExportPresetHighestQuality)
		else {
			print("ERROR: Cannot create export session.")
			let error = NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot create export session."])
			return .failure(error)
		}
		
		let videoName = UUID().uuidString
		let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
			.appendingPathComponent(videoName)
			.appendingPathExtension("mov")
		
		exportSession.videoComposition = videoComposition
		exportSession.outputFileType = .mov
		exportSession.outputURL = exportURL
		await exportSession.export()
		return .success(exportURL)
	}
	
	private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
		var assetOrientation = UIImage.Orientation.up
		var isPortrait = false
		if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
			assetOrientation = .right
			isPortrait = true
		} else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
			assetOrientation = .left
			isPortrait = true
		} else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
			assetOrientation = .up
		} else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
			assetOrientation = .down
		}
		
		return (assetOrientation, isPortrait)
	}
	
	private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
		let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
		let transform = assetTrack.preferredTransform
		
		instruction.setTransform(transform, at: .zero)
		
		return instruction
	}
	
	private func addImage(to layer: CALayer, videoSize: CGSize) {
		let image = UIImage(named: "youtube")!
		let imageLayer = CALayer()
		
		let aspect: CGFloat = image.size.width / image.size.height
		let width = videoSize.width
		let height = width / aspect
		imageLayer.frame = CGRect(
			x: 0,
			y: -height * 0.15,
			width: width,
			height: height)
		
		imageLayer.contents = image.cgImage
		layer.addSublayer(imageLayer)
	}
}
