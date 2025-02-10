//
//  VideoProject.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 07/02/2025.
//

import UIKit

struct VideoProject {
	let id: String
	var name: String
	let creationDate: Date
	let videoURL: URL
	let thumbnail: UIImage
	var watermark: Watermark?
}

struct Watermark {
	var type: WatermarkType
	var subtype: WatermarkSubtype
	var coord: (x: Float, y: Float)
	var opacity: Float
}

enum WatermarkType {
	case text(String)
	case image(UIImage)
}

enum WatermarkSubtype {
	case original
	case repeating
}
