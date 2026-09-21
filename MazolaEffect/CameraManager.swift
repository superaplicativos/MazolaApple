//
//  CameraManager.swift
//  MazolaEffect
//
//  Responsavel por configurar e controlar a AVCaptureSession,
//  capturar frames de video e aplicar o filtro CIColorInvert
//  antes de renderizar no FilterMetalView.
//

import AVFoundation
import CoreImage
import UIKit

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput image: CIImage)
    func cameraManager(_ manager: CameraManager, didEncounterError error: CameraManager.CameraError)
}

final class CameraManager: NSObject {

    // MARK: - Errors

    enum CameraError: LocalizedError {
        case permissionDenied
        case noCameraAvailable
        case cameraInUse
        case configurationFailed(String)
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "A permissao de camera foi negada. Abra Ajustes > Mazola Effect > Camera e ative o acesso."
            case .noCameraAvailable:
                return "Nenhuma camera disponivel neste dispositivo."
            case .cameraInUse:
                return "A camera esta em uso por outro aplicativo. Feche o outro app e tente novamente."
            case .configurationFailed(let reason):
                return "Falha ao configurar a camera: \(reason)"
            case .unknown(let error):
                return "Erro desconhecido: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Public state

    enum Facing: String { case back, front }

    weak var delegate: CameraManagerDelegate?

    private(set) var isRunning = false
    private(set) var facing: Facing = .back
    private(set) var negativeEnabled: Bool = true

    // MARK: - AV objects

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.superaplicativos.mazolaeffect.session")
    private let videoOutputQueue = DispatchQueue(label: "com.superaplicativos.mazolaeffect.video")
    private var videoInput: AVCaptureDeviceInput?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    private var deviceOrientation: CGImagePropertyOrientation = .up

    // MARK: - Public API

    func start() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.requestPermissionAndConfigureIfNeeded { [weak self] success in
                guard let self = self else { return }
                if success {
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    self.isRunning = self.session.isRunning
                }
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            self.isRunning = false
        }
    }

    func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.facing = (self.facing == .back) ? .front : .back
            self.configureSession(replacingInput: true)
        }
    }

    func setNegativeEnabled(_ enabled: Bool) {
        self.negativeEnabled = enabled
    }

    // MARK: - Permission

    private func requestPermissionAndConfigureIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            configureSession(replacingInput: false)
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.configureSession(replacingInput: false)
                    completion(true)
                } else {
                    self.notifyError(.permissionDenied)
                    completion(false)
                }
            }
        case .denied, .restricted:
            notifyError(.permissionDenied)
            completion(false)
        @unknown default:
            notifyError(.permissionDenied)
            completion(false)
        }
    }

    // MARK: - Session configuration

    private func configureSession(replacingInput: Bool) {
        session.beginConfiguration()

        // Preset: .photo prioriza qualidade para visualizacao de pinturas
        session.sessionPreset = .photo

        // Remove existing input if replacing
        if replacingInput, let currentInput = self.videoInput {
            session.removeInput(currentInput)
        }

        // Add new input
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera],
            mediaType: .video,
            position: (facing == .back) ? .back : .front
        )
        guard let device = discoverySession.devices.first else {
            session.commitConfiguration()
            notifyError(.noCameraAvailable)
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                self.videoInput = input
            } else {
                session.commitConfiguration()
                notifyError(.cameraInUse)
                return
            }
        } catch {
            session.commitConfiguration()
            notifyError(.configurationFailed(error.localizedDescription))
            return
        }

        // Configure video data output (only once)
        if !replacingInput {
            videoDataOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            } else {
                session.commitConfiguration()
                notifyError(.configurationFailed("nao foi possivel adicionar saida de video"))
                return
            }
        }

        // Mirror front camera so it feels natural (selfie-style)
        if let connection = videoDataOutput.connection(with: .video) {
            if facing == .front {
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = false // nos aplicamos o espelho manualmente no filtro
                }
            }
            // Orientation
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }

        session.commitConfiguration()
    }

    // MARK: - Orientation updates

    func updateDeviceOrientation(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait: deviceOrientation = .up
        case .portraitUpsideDown: deviceOrientation = .down
        case .landscapeLeft: deviceOrientation = .left
        case .landscapeRight: deviceOrientation = .right
        default: break
        }
    }

    // MARK: - Error notification

    private func notifyError(_ error: CameraError) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.cameraManager(self!, didEncounterError: error)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            .oriented(deviceOrientation)

        // Mirror for front camera BEFORE the invert filter
        if facing == .front {
            ciImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
            ciImage = ciImage.transformed(by: CGAffineTransform(translationX: ciImage.extent.width, y: 0))
        }

        if negativeEnabled {
            if let invertFilter = CIFilter(name: "CIColorInvert") {
                invertFilter.setValue(ciImage, forKey: kCIInputImageKey)
                if let output = invertFilter.outputImage {
                    ciImage = output
                }
            }
        }

        delegate?.cameraManager(self, didOutput: ciImage)
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didDrop sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // Frame descartado por atraso — sem acao necessaria.
    }
}
