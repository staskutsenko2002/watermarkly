//
//  VideoEditorViewController.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 06/02/2025.
//

import UIKit
import AVKit
import SwiftUI
import Combine

final class VideoEditorViewController: UIViewController {
	// MARK: - Private properties
	private let viewModel: VideoEditorViewModel
	private var cancellable = Set<AnyCancellable>()
	
	// MARK: - UI
	private var player: AVPlayer!
	private var playerLayer: AVPlayerLayer!
	
	private lazy var navigationView: UIView = {
		let backButton = UIKButtonModel(icon: "close_arrow") { [weak self] in
			self?.showCloseAlert()
		}
		let rightButton = UIKButtonModel(icon: "check") { [weak self] in
			self?.viewModel.save()
			self?.addTextWatermark()
		}
		let view = UIKNavigationBarView(title: "Editor", backButtonModel: backButton, rightButtonModel: rightButton)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let videoView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Colors.background
		return view
	}()
	
	private let editingContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
		return view
	}()
	
	private lazy var playbackControlButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "pause"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.addTarget(self, action: #selector(didPressControlButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var soundButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "sound"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.addTarget(self, action: #selector(didPressSoundButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var opacityButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.setImage(UIImage(named: "opacity"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.addTarget(self, action: #selector(didPressOpacityButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var editingStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [playbackControlButton, soundButton, opacityButton])
		stackView.distribution = .fillEqually
		stackView.spacing = 10
		stackView.axis = .horizontal
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private lazy var opacitySlider: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isHidden = true
		slider.addTarget(self, action: #selector(didChangeSlider), for: .valueChanged)
		slider.tintColor = Colors.primaryPink
		slider.maximumValue = 1
		slider.minimumValue = 0
		slider.value = 1
		return slider
	}()
	
	private var labelWatermark: UILabel?
	private var imageWatermark: UIImageView?
	
	// MARK: - Life cycle
	init(viewModel: VideoEditorViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSubcription()
		setupSubviews()
		setupPlayer()
	}
	
	override func viewDidLayoutSubviews() {
	  super.viewDidLayoutSubviews()
	  playerLayer.frame = videoView.bounds
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		setPause()
	}
	
	deinit {
	  NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
	}
}

// MARK: - Setup methods
private extension VideoEditorViewController {
	func setupSubcription() {
		viewModel.$isPlaying.sink { [weak self] isPlaying in
			guard let self else { return }
			DispatchQueue.main.async {
				if isPlaying {
					self.setPlay()
				} else {
					self.setPause()
				}
			}
		}
		.store(in: &cancellable)
		
		viewModel.$isMuted.sink { [weak self] isMuted in
			guard let self else { return }
			DispatchQueue.main.async {
				if isMuted {
					self.setMuted()
				} else {
					self.setSound()
				}
			}
			
		}
		.store(in: &cancellable)
	}
	
	func setupSubviews() {
		view.backgroundColor = Colors.background
		view.addSubview(navigationView)
		view.addSubview(videoView)
		view.addSubview(editingContainerView)
		view.addSubview(editingStackView)
		view.addSubview(opacitySlider)
		
		NSLayoutConstraint.activate([
			navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			navigationView.heightAnchor.constraint(equalToConstant: 50),
			
			videoView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
			videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			videoView.bottomAnchor.constraint(equalTo: editingContainerView.topAnchor),
			
			editingContainerView.heightAnchor.constraint(equalToConstant: 140),
			editingContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			editingContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			editingContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			editingStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			editingStackView.topAnchor.constraint(equalTo: editingContainerView.topAnchor, constant: 16),
			
			opacitySlider.leadingAnchor.constraint(equalTo: editingStackView.trailingAnchor, constant: 16),
			opacitySlider.topAnchor.constraint(equalTo: editingContainerView.topAnchor, constant: 10),
			opacitySlider.trailingAnchor.constraint(equalTo: editingContainerView.trailingAnchor, constant: -16),
			
			playbackControlButton.heightAnchor.constraint(equalToConstant: 20),
			playbackControlButton.widthAnchor.constraint(equalToConstant: 20),
			
			soundButton.heightAnchor.constraint(equalToConstant: 20),
			soundButton.widthAnchor.constraint(equalToConstant: 20),
			
			opacityButton.heightAnchor.constraint(equalToConstant: 20),
			opacityButton.widthAnchor.constraint(equalToConstant: 20),
		])
	}
	
	func setupPlayer() {
		player = AVPlayer(url: viewModel.videoURL)
		
		playerLayer = AVPlayerLayer(player: player)
		playerLayer.frame = videoView.frame
		videoView.layer.addSublayer(playerLayer)
		viewModel.isMuted = false
		viewModel.isPlaying = true
		
		NotificationCenter.default.addObserver(
			forName: .AVPlayerItemDidPlayToEndTime,
			object: nil,
			queue: nil
		) { [weak self] _ in
			self?.setRestart()
		}
	}
}

// MARK: - Control methods
private extension VideoEditorViewController {
	func setPlay() {
		player.play()
		UIView.transition(with: playbackControlButton, duration: 0.2, options: .transitionCrossDissolve) {
			self.playbackControlButton.setImage(UIImage(named: "pause"), for: .normal)
		}
	}
	
	func setPause() {
		player.pause()
		UIView.transition(with: playbackControlButton, duration: 0.2, options: .transitionCrossDissolve) {
			self.playbackControlButton.setImage(UIImage(named: "play"), for: .normal)
		}
	}
	
	func setMuted() {
		player.isMuted = true
		UIView.transition(with: soundButton, duration: 0.2, options: .transitionCrossDissolve) {
			self.soundButton.setImage(UIImage(named: "sound_muted"), for: .normal)
		}
	}
	
	func setSound() {
		player.isMuted = false
		UIView.transition(with: soundButton, duration: 0.2, options: .transitionCrossDissolve) {
			self.soundButton.setImage(UIImage(named: "sound"), for: .normal)
		}
	}
	
	func setRestart() {
		player.seek(to: .zero)
		setPlay()
	}
	
	// MARK: - Adding watermark
	func addTextWatermark() {
		// reset
		labelWatermark?.removeFromSuperview()
		labelWatermark = nil
		opacityButton.isHidden = true
		opacitySlider.isHidden = true
		
		// setup
		labelWatermark = UILabel()
		labelWatermark?.text = "Tap text here"
		labelWatermark?.textColor = .white
		labelWatermark?.textAlignment = .center
		opacityButton.isHidden = false
		labelWatermark?.font = .systemFont(ofSize: 20, weight: .semibold)
		labelWatermark?.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
		labelWatermark?.center = videoView.convert(videoView.center, from: view)
		labelWatermark?.isUserInteractionEnabled = true
		let drapGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanWatermark(_:)))
		labelWatermark?.addGestureRecognizer(drapGesture)
		guard let labelWatermark else { return }
		videoView.addSubview(labelWatermark)
	}
	
	// MARK: - Alert
	func showCloseAlert() {
		let alert = UIAlertController(title: "Cancel Editing", message: "Are you sure you want to cancel video editing? Your progress won't be saved.", preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
			self?.viewModel.close()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		present(alert, animated: true)
		
	}
}

// MARK: - Selectors
@objc private extension VideoEditorViewController {
	func didPressControlButton() {
		viewModel.isPlaying.toggle()
	}
	
	func didPressSoundButton() {
		viewModel.isMuted.toggle()
	}
	
	func didPressOpacityButton() {
		opacitySlider.isHidden.toggle()
	}
	
	func didChangeSlider() {
		labelWatermark?.layer.opacity = opacitySlider.value
	}
	
	func didPanWatermark(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: videoView)
				
		if let gestureView = gesture.view {
			gestureView.center = CGPoint(x: gestureView.center.x + translation.x,
										 y: gestureView.center.y + translation.y)
		}
		
		gesture.setTranslation(.zero, in: view)
	}
}
