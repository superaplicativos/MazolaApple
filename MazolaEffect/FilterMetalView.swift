//
//  FilterMetalView.swift
//  MazolaEffect
//
//  MTKView subclass que renderiza CIImage usando CIContext baseado em Metal.
//  Substitui o GLKView (deprecated) e mantem performance em tempo real.
//

import MetalKit
import CoreImage

final class FilterMetalView: MTKView {

    private var ciContext: CIContext?
    private var currentImage: CIImage?
    private var scale: CGFloat = UIScreen.main.scale

    // Sincroniza o acesso a currentImage entre a thread de video e a de render
    private let imageQueue = DispatchQueue(label: "com.superaplicativos.mazolaeffect.imagequeue")

    // MARK: - Init

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        commonInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        guard let _ = device ?? MTLCreateSystemDefaultDevice() else {
            fatalError("Metal nao suportado neste dispositivo")
        }
        commonInit()
    }

    private func commonInit() {
        guard let device = device else {
            fatalError("Sem dispositivo Metal disponivel")
        }
        // CIContext atrelado ao dispositivo Metal — render acelerado por hardware
        ciContext = CIContext(mtlDevice: device, options: [
            .useSoftwareRenderer: false,
            .workingColorSpace: CGColorSpaceCreateDeviceRGB()
        ])

        // Configuracao do drawable
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        isOpaque = true
        backgroundColor = .black
        contentScaleFactor = scale
        preferredFramesPerSecond = 60
        enableSetNeedsDisplay = false
        isPaused = false
    }

    // MARK: - Public

    func updateImage(_ image: CIImage) {
        imageQueue.sync {
            self.currentImage = image
        }
    }

    // MARK: - Render loop

    override func draw(_ rect: CGRect) {
        guard let drawable = currentDrawable,
              let ciContext = ciContext,
              let commandBuffer = ciContext.metalCommandQueue?.commandBuffer() else {
            return
        }

        var imageToRender: CIImage?
        imageQueue.sync {
            imageToRender = self.currentImage
        }

        guard let image = imageToRender else {
            return
        }

        let destination = CIRenderDestination(
            width: Int(drawable.layer.drawableSize.width),
            height: Int(drawable.layer.drawableSize.height),
            pixelFormat: colorPixelFormat,
            commandBuffer: commandBuffer,
            mtlTextureProvider: { () -> MTLTexture? in
                return drawable.texture
            }
        )

        // Ajusta o extent da imagem ao tamanho do drawable preservando aspect ratio
        let viewSize = drawable.layer.drawableSize
        let scaleX = viewSize.width / image.extent.width
        let scaleY = viewSize.height / image.extent.height
        let scaleFactor = max(scaleX, scaleY)
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        let centeredX = (viewSize.width - scaled.extent.width) / 2
        let centeredY = (viewSize.height - scaled.extent.height) / 2
        let centered = scaled.transformed(by: CGAffineTransform(translationX: centeredX, y: centeredY))

        do {
            _ = try ciContext.startTask(toRender: centered, to: destination)
            commandBuffer.present(drawable)
            commandBuffer.commit()
        } catch {
            // Falha pontual de render — nao precisamos crashar o app
            #if DEBUG
            print("FilterMetalView: render falhou: \(error.localizedDescription)")
            #endif
        }
    }
}
