//
//  StringConstants.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 17/01/2025.
//

import UIKit
import SwiftUI

final class StringConstants {
	static let watermarkTitle = "Watermark Editor"
	static let chooseVideo = "Choose video..."
	
	static let libraryAccessFailedTitle = "Access request failed"
	static let libraryAccessFailedMessage = "Please navigate to the settings in order to allow access to your library"
	static let goToSettings = "Go to Settings"
	static let okay = "Okay"
	
	static let libraryAccessDescription = "Watermarkly requires access to the\nphoto library in order to let user\nadd watermarks on the video."
}

final class Colors {
	static let primaryPink = UIColor(red: 235/255, green: 55/255, blue: 178/255, alpha: 1)
	static let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
	static let background = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
	static let background2 = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
	static let gray2 = UIColor(red: 142/255, green: 142/255, blue: 142/255, alpha: 1)
	static let grayText = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
}

extension UIColor {
	var suiColor: Color {
		return Color(uiColor: self)
	}
}
