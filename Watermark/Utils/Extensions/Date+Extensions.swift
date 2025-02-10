//
//  Date+Extensions.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//

import Foundation

extension Date {
	func toShortFormat() -> String {
		formatted(date: .numeric, time: .omitted)
	}
}
