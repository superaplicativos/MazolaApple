# Mazola Effect (iOS)

> App nativo iOS (Swift / SwiftUI / AVFoundation / MetalKit) que abre a câmera do iPhone/iPad com **filtro negativo em tempo real**, projetado para visualizar quadros pintados em negativo e revelar a cor original.

Versão web (PWA) de referência: <https://superaplicativos.github.io/MazolaEffect/>

Repositório GitHub: <https://github.com/superaplicativos/MazolaApple>

---

## Índice

1. [Visão geral](#1-visão-geral)
2. [Stack técnico](#2-stack-técnico)
3. [Requisitos do ambiente de desenvolvimento](#3-requisitos-do-ambiente-de-desenvolvimento)
4. [Estrutura de arquivos](#4-estrutura-de-arquivos)
5. [Como abrir e rodar o projeto no Xcode](#5-como-abrir-e-rodar-o-projeto-no-xcode)
6. [Como gerar o `.xcodeproj` via XcodeGen (opcional)](#6-como-gerar-o-xcodeproj-via-xcodegen-opcional)
7. [Ícone do app](#7-ícone-do-app)
8. [Permissões](#8-permissões)
9. [Publicação na App Store](#9-publicação-na-app-store)
10. [Política de privacidade](#10-política-de-privacidade)
11. [Atualizar o app no futuro](#11-atualizar-o-app-no-futuro)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Visão geral

O **Mazola Effect** é um app simples, 100% offline, que abre a câmera do dispositivo e aplica um filtro de **cor negativa (CIColorInvert)** em tempo real sobre o feed de vídeo. Ele é voltado para uso artístico: apontar para um quadro pintado em negativo revela a pintura com as cores originais.

- **Plataformas:** iPhone e iPad com iOS 16.0+
- **Linguagem:** Swift 5.9+
- **Frameworks:** SwiftUI, AVFoundation, CoreImage, MetalKit
- **Permissões:** apenas câmera (`NSCameraUsageDescription`)
- **Rede:** nenhuma. Zero analytics, zero ads, zero rastreamento.
- **Bundle ID:** `com.superaplicativos.mazolaeffect`

---

## 2. Stack técnico

| Camada              | Tecnologia                                  |
| ------------------- | ------------------------------------------- |
| UI                  | SwiftUI + `UIViewControllerRepresentable`   |
| Camera              | `AVCaptureSession` + `AVCaptureVideoDataOutput` |
| Filtro              | `CIColorInvert` (Core Image)                |
| Render              | `MTKView` (MetalKit) + `CIContext(MTLDevice)` |
| Espelho frontal     | `CGAffineTransform(scaleX: -1, y: 1)` aplicado **antes** do invert |
| Orientação          | dinâmica (portrait, landscape, todas)       |
| Min iOS             | 16.0                                        |
| Dependencies        | nenhuma                                     |

---

## 3. Requisitos do ambiente de desenvolvimento

- macOS 13.5+ (Ventura ou superior)
- Xcode 15.0+ (com Swift 5.9)
- iOS 16.0+ SDK (já incluso no Xcode 15)
- Conta Apple Developer (pago, para publicar na App Store)
- iPhone/iPad físico recomendado (a câmera não funciona no Simulator)
- Opcional: [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Opcional: [Fastlane](https://fastlane.tools) (`brew install fastlane`)

---

## 4. Estrutura de arquivos

```
MazolaApple/
├── README.md
├── LICENSE
├── .gitignore
├── project.yml                     # spec XcodeGen
├── MazolaEffect/
│   ├── MazolaEffectApp.swift       # @main entry point
│   ├── ContentView.swift           # UI principal SwiftUI
│   ├── CameraViewController.swift  # UIViewController host do MTKView
│   ├── CameraViewRepresentable.swift # bridge SwiftUI ↔ UIKit
│   ├── CameraManager.swift         # AVCaptureSession + CIColorInvert
│   ├── FilterMetalView.swift       # MTKView subclass com CIContext
│   ├── Info.plist
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/     # Contents.json + icon-1024.svg
│   │   └── AccentColor.colorset/
│   └── Preview Content/
│       └── Preview Assets.xcassets/
├── docs/
│   ├── PRIVACY.md
│   ├── APP_STORE_METADATA.md
│   ├── SCREENSHOTS.md
│   └── SUBMISSION_CHECKLIST.md
└── fastlane/
    └── Fastfile
```

---

## 5. Como abrir e rodar o projeto no Xcode

Existem dois caminhos:

### Caminho A — abrir direto o `project.yml`

1. Instale o XcodeGen: `brew install xcodegen`
2. No terminal, na raiz do repo:
   ```bash
   cd /path/ao/MazolaApple
   xcodegen generate
   ```
3. Abra o `MazolaEffect.xcodeproj` gerado:
   ```bash
   open MazolaEffect.xcodeproj
   ```
4. Selecione um **dispositivo físico** (a câmera não funciona no Simulator).
5. Em **Signing & Capabilities**, selecione seu **Team** da Apple Developer.
6. `Cmd+R` para rodar.

### Caminho B — criar o projeto manualmente no Xcode

Se você não quiser usar o XcodeGen, crie um novo projeto **iOS > App** no Xcode com:

- Product Name: `Mazola Effect`
- Organization Identifier: `com.superaplicativos`
- Bundle Identifier resultante: `com.superaplicativos.mazolaeffect`
- Interface: **SwiftUI**
- Language: **Swift**
- Storage: **None**
- Minimum Deployments: **iOS 16.0**

Depois, arraste todos os arquivos `.swift` da pasta `MazolaEffect/` para o target do projeto e certifique-se de que o `Info.plist` do target tem a chave `NSCameraUsageDescription`.

---

## 6. Como gerar o `.xcodeproj` via XcodeGen (opcional)

```bash
brew install xcodegen
cd /path/ao/MazolaApple
xcodegen generate
open MazolaEffect.xcodeproj
```

O `project.yml` já está configurado com:

- Bundle ID: `com.superaplicativos.mazolaeffect`
- Deployment target: iOS 16.0
- TARGETED_DEVICE_FAMILY: `"1,2"` (iPhone + iPad)
- Swift 5.9
- Info.plist: `MazolaEffect/Info.plist`

---

## 7. Ícone do app

O placeholder está em:

```
MazolaEffect/Assets.xcassets/AppIcon.appiconset/icon-1024.svg
```

É um SVG com um "M" branco em fundo preto. A App Store e o Xcode 14+ aceitam um **único PNG 1024×1024** no AppIcon set, então você tem duas opções:

### Opção A — gerar o PNG 1024 com `sips`

```bash
cd MazolaEffect/Assets.xcassets/AppIcon.appiconset/

# SVG -> PNG usando rsvg-convert (brew install librsvg) ou qlmanage
qlmanage -t -s 1024 -o . icon-1024.svg
mv icon-1024.svg.png icon-1024.png

# ou, se tiver rsvg-convert:
rsvg-convert -w 1024 -h 1024 icon-1024.svg -o icon-1024.png

# validar
sips -g pixelWidth -g pixelHeight icon-1024.png
```

Depois atualize o `Contents.json` para apontar para `icon-1024.png`:

```json
{
  "images" : [
    {
      "filename" : "icon-1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  ...
}
```

### Opção B — Asset Catalog generator (Xcode 14+)

Apenas adicione um PNG 1024×1024 ao AppIcon.appiconset no Xcode e ele gera todos os tamanhos derivados automaticamente.

Tamanhos legados (1024, 180, 120, 87, 80, 60, 40, 20) só são necessários se você suportar iOS < 16. Como o deployment target é 16.0+, apenas o 1024 é necessário.

---

## 8. Permissões

O `Info.plist` declara apenas:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da camera para aplicar o filtro negativo em tempo real e revelar a pintura.</string>
```

E opcionalmente (caso queira permitir salvar screenshot):

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Salvar screenshots opcionalmente no rolo da camera.</string>
```

Nenhuma outra permissão é necessária.

---

## 9. Publicação na App Store

Consulte [`docs/SUBMISSION_CHECKLIST.md`](docs/SUBMISSION_CHECKLIST.md) para o passo-a-passo completo.

Resumo:

1. Arquivar o app no Xcode (`Product > Archive`).
2. Distribuir via **App Store Connect** ou **Fastlane**.
3. Preencher metadados (pronto em [`docs/APP_STORE_METADATA.md`](docs/APP_STORE_METADATA.md)).
4. Hospedar política de privacidade (use [`docs/PRIVACY.md`](docs/PRIVACY.md) como GitHub Page).
5. Gerar screenshots 6.7", 6.5", 5.5" (instruções em [`docs/SCREENSHOTS.md`](docs/SCREENSHOTS.md)).
6. Enviar para revisão (24–48h).

---

## 10. Política de privacidade

Pronta em [`docs/PRIVACY.md`](docs/PRIVACY.md). Como o app coleta zero dados, basta:

1. Hospedar o `docs/PRIVACY.md` como GitHub Page no próprio repo (ou usar a URL raw do GitHub):
   - Exemplo: <https://superaplicativos.github.io/MazolaApple/privacy/> (se ativar Pages)
   - Ou raw: <https://raw.githubusercontent.com/superaplicativos/MazolaApple/main/docs/PRIVACY.md>
2. Colar a URL no App Store Connect > App Information > Privacy Policy URL.

---

## 11. Atualizar o app no futuro

Para lançar uma nova versão:

1. No Xcode, abra o target `MazolaEffect` > **General**:
   - Bump em `Version` (ex.: `1.0.0` → `1.0.1`) — campo `MARKETING_VERSION` no project.yml.
   - Bump em `Build` (ex.: `1` → `2`) — campo `CURRENT_PROJECT_VERSION` no project.yml.
2. `Product > Archive`.
3. No Organizer, **Distribute App > App Store Connect**.
4. No App Store Connect, crie uma nova versão iOS do app, suba o build, preencha o "What's New" e envie para revisão.

---

## 12. Troubleshooting

| Erro / Sintoma                                          | Solução                                                                 |
| -------------------------------------------------------- | ----------------------------------------------------------------------- |
| `No signing certificate` ou `requires a provisioning profile` | Signing & Capabilities > selecione seu Team Apple Developer.            |
| Câmera não abre / `AVCaptureSession` não roda             | Teste em **dispositivo físico**. O Simulator não tem câmera.            |
| `Camera permission denied no app`                         | Ajustes > Mazola Effect > Camera > permitir.                            |
| `Build failed: xcodebuild exited with code 65`           | Abra o Report Navigator (Cmd+9) no Xcode e procure o erro vermelho. Geralmente é problema de signing ou Info.plist ausente. |
| `App Store Connect: Missing App Privacy Policy`          | Hospede `docs/PRIVACY.md` e cole a URL em App Store Connect > App Information. |
| App rejeitado: `Guideline 5.1.1 - Privacy`               | Confirme no questionário de privacidade do App Store Connect que você **não coleta dados**. O app não tem analytics nem ads. |
| Tela preta após iniciar a câmera                          | Verifique se o filtro `CIColorInvert` está aplicado e se `MTKView.framebufferOnly = false`. |
| Frontal aparece espelhada errada                          | O `CameraManager` já aplica `CGAffineTransform(scaleX: -1, y: 1)` antes do invert. Se o teste falhar, revise a ordem no `captureOutput(_:didOutput:from:)`. |

---

## Licença

MIT — veja [`LICENSE`](LICENSE).

## Links

- Versão web (PWA): <https://superaplicativativos.github.io/MazolaEffect/>
- Repo iOS: <https://github.com/superaplicativos/MazolaApple>
- Issues: <https://github.com/superaplicativos/MazolaApple/issues>
