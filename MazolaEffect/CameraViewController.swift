//
//  CameraViewController.swift
//  MazolaEffect
//
//  UIViewController hospedeiro do FilterMetalView (MTKView).
//  Encapsula o setup de Auto Layout, orientacao e lifecycle da camera.
//

import UIKit
import CoreImage
import AVFoundation

final class CameraViewController: UIViewController {

    // MARK: - Public properties

    var onCameraStarted: (() -> Void)?
    var onCameraStopped: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Private properties

    private let cameraManager = CameraManager()
    private var metalView: FilterMetalView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupMetalView()
        configureCameraManager()
        registerOrientationNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateOrientation(UIDevice.current.orientation)
    }

    // MARK: - Setup

    private func setupMetalView() {
        let device = MTLCreateSystemDefaultDevice()
        metalView = FilterMetalView(frame: .zero, device: device)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.backgroundColor = .black
        view.addSubview(metalView)

        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureCameraManager() {
        cameraManager.delegate = self
    }

    private func registerOrientationNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }

    // MARK: - Public API

    func startCamera() {
        cameraManager.start()
        onCameraStarted?()
    }

    func stopCamera() {
        cameraManager.stop()
        metalView.updateImage(CIImage.empty())
        onCameraStopped?()
    }

    func flipCamera() {
        cameraManager.flipCamera()
    }

    func setNegativeEnabled(_ enabled: Bool) {
        cameraManager.setNegativeEnabled(enabled)
    }

    // MARK: - Orientation

    @objc private func deviceOrientationDidChange() {
        updateOrientation(UIDevice.current.orientation)
    }

    private func updateOrientation(_ orientation: UIDeviceOrientation) {
        cameraManager.updateDeviceOrientation(orientation)
    }
}

// MARK: - CameraManagerDelegate

extension CameraViewController: CameraManagerDelegate {

    func cameraManager(_ manager: CameraManager, didOutput image: CIImage) {
        // A MTKView roda o draw loop em thread propria; atualizar a imagem e thread-safe
        DispatchQueue.main.async { [weak self] in
            self?.metalView.updateImage(image)
        }
    }

    func cameraManager(_ manager: CameraManager, didEncounterError error: CameraManager.CameraError) {
        DispatchQueue.main.async { [weak self] in
            self?.onError?(error.errorDescription ?? "Erro desconhecido na camera.")
        }
    }
}
