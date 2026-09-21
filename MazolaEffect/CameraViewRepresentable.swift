//
//  CameraViewRepresentable.swift
//  MazolaEffect
//
//  Bridge SwiftUI <-> UIKit (CameraViewController hospedando FilterMetalView/MTKView).
//

import SwiftUI
import CoreImage

struct CameraViewRepresentable: UIViewControllerRepresentable {

    let controller: CameraController
    var onError: (String) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        // Configura o callback de erro antes de devolver
        controller.uiController.onError = onError
        return controller.uiController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Mantem o callback de erro sincronizado caso a closure tenha mudado
        uiViewController.onError = onError
    }
}
