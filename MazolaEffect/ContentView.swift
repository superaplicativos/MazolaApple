//
//  ContentView.swift
//  MazolaEffect
//
//  UI principal em SwiftUI. Layout:
//  - Fundo preto fullscreen
//  - Botao central "Iniciar Camera" quando parado
//  - Botao flutuante no topo para alternar camera traseira/frontal
//  - Switch "Negativo" no rodape
//  - Botao "Parar" no rodape
//

import SwiftUI
import UIKit

struct ContentView: View {

    @StateObject private var cameraController = CameraController()

    @State private var isCameraRunning = false
    @State private var negativeEnabled = true
    @State private var facingLabel: String = "Tras"
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Camera preview (MTKView) — sempre montado, controlado por opacidade
            CameraViewRepresentable(
                controller: cameraController,
                onError: { message in
                    errorMessage = message
                    showError = true
                    isCameraRunning = false
                }
            )
            .ignoresSafeArea()
            .opacity(isCameraRunning ? 1 : 0)
            .allowsHitTesting(false)

            // Overlay de controles
            VStack {
                if isCameraRunning {
                    topControls
                }
                Spacer()
                if isCameraRunning {
                    bottomControls
                }
            }

            // Botao central quando parado
            if !isCameraRunning {
                startButton
            }
        }
        .preferredColorScheme(.dark)
        .alert("Erro", isPresented: $showError) {
            Button("OK", role: .cancel) { }
            Button("Abrir Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Subviews

    private var topControls: some View {
        HStack {
            Button(action: flipCamera) {
                Image(systemName: "camera.rotate")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Trocar camera")

            Spacer()

            Text("Camera: \(facingLabel)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
    }

    private var bottomControls: some View {
        HStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("Negativo")
                    .font(.caption)
                    .foregroundColor(.white)
                Toggle("", isOn: $negativeEnabled)
                    .labelsHidden()
                    .tint(.green)
                    .onChange(of: negativeEnabled) { newValue in
                        cameraController.setNegativeEnabled(newValue)
                    }
            }

            Button(action: stopCamera) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                    Text("Parar")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.7))
                .clipShape(Capsule())
            }
            .accessibilityLabel("Parar camera")
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 8)
    }

    private var startButton: some View {
        Button(action: startCamera) {
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 56))
                Text("Iniciar Camera")
                    .font(.title2.bold())
                Text("Toque para revelar a arte em negativo")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)
            .padding(36)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 12)
        }
        .accessibilityLabel("Iniciar camera")
    }

    // MARK: - Actions

    private func startCamera() {
        isCameraRunning = true
        // Da um respiro para o representable montar o UIView antes de chamar start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cameraController.startCamera()
        }
    }

    private func stopCamera() {
        cameraController.stopCamera()
        isCameraRunning = false
        facingLabel = "Tras"
    }

    private func flipCamera() {
        cameraController.flipCamera()
        facingLabel = (facingLabel == "Tras") ? "Frente" : "Tras"
    }
}

// MARK: - CameraController (ObservableObject wrapper)

final class CameraController: ObservableObject {
    fileprivate let uiController: CameraViewController

    init() {
        uiController = CameraViewController()
    }

    func startCamera() { uiController.startCamera() }
    func stopCamera()  { uiController.stopCamera() }
    func flipCamera()  { uiController.flipCamera() }
    func setNegativeEnabled(_ enabled: Bool) { uiController.setNegativeEnabled(enabled) }
}
