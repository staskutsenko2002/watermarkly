//
//  UIKNavigationBarView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 06/02/2025.
//

import UIKit

final class UIKNavigationBarView: UIView {
	// MARK: - Properties
	let title: String?
	let backButtonModel: UIKButtonModel?
	let rightButtonModel: UIKButtonModel?
	
	// MARK: - UI
	private var backButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 25, weight: .bold)
		label.textColor = Colors.white
		return label
	}()
	
	private var rightButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 10
		stackView.axis = .horizontal
		return stackView
	}()
	
	// MARK: - Init
	init(title: String? = nil, backButtonModel: UIKButtonModel? = nil, rightButtonModel: UIKButtonModel? = nil) {
		self.title = title
		self.rightButtonModel = rightButtonModel
		self.backButtonModel = backButtonModel
		super.init(frame: .zero)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Setup methods
private extension UIKNavigationBarView {
	func setup() {
		addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
		])
		
		if let backButtonModel {
			backButton.setImage(UIImage(named: backButtonModel.icon), for: .normal)
			backButton.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
			
			stackView.addArrangedSubview(backButton)
			backButton.heightAnchor.constraint(equalToConstant: backButtonModel.size).isActive = true
			backButton.widthAnchor.constraint(equalToConstant: backButtonModel.size).isActive = true
		}
		
		titleLabel.text = title
		stackView.addArrangedSubview(titleLabel)
		
		if let rightButtonModel {
			rightButton.setImage(UIImage(named: rightButtonModel.icon), for: .normal)
			rightButton.addTarget(self, action: #selector(didPressRightButton), for: .touchUpInside)
			
			stackView.addArrangedSubview(rightButton)
			rightButton.heightAnchor.constraint(equalToConstant: rightButtonModel.size).isActive = true
			rightButton.widthAnchor.constraint(equalToConstant: rightButtonModel.size).isActive = true
		}
	}
}

// MARK: - Selectors
@objc private extension UIKNavigationBarView {
	func didPressBackButton() {
		backButtonModel?.onClick()
	}
	
	func didPressRightButton() {
		rightButtonModel?.onClick()
	}
}

struct UIKButtonModel {
	let icon: String
	let size: CGFloat
	let onClick: () -> Void
	
	init(icon: String, size: CGFloat = 20, onClick: @escaping () -> Void) {
		self.icon = icon
		self.size = size
		self.onClick = onClick
	}
}
