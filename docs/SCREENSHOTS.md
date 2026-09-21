# Screenshots — Mazola Effect

A App Store exige screenshots para pelo menos **um** dos tamanhos de iPhone. Para máxima cobertura, gere para 6.7" e 6.5" (iPhone). iPad é opcional mas recomendado.

## Tamanhos obrigatórios / recomendados

| Dispositivo               | Tamanho            | Plataforma |
| ------------------------- | ------------------ | ---------- |
| iPhone 15 Pro Max / 14 Pro Max | 1290 × 2796 px | 6.7"      |
| iPhone 14 Plus / 13 Pro Max | 1284 × 2778 px     | 6.5"      |
| iPhone 8 Plus / 7 Plus    | 1242 × 2208 px     | 5.5"      |
| iPad Pro 12.9" (6ª gen)   | 2048 × 2732 px     | iPad       |

> Para Apps Universal (iPhone+iPad), gere **pelo menos iPhone 6.7"** e opcionalmente iPad 12.9".

## Como gerar via Xcode (manual)

1. Conecte um iPhone físico (recomendado: iPhone 14 Pro Max ou 15 Pro Max).
2. Rode o app em `Cmd+R`.
3. Capture cada estado do app:

   - **Screenshot 1:** tela inicial com botão "Iniciar Camera".
   - **Screenshot 2:** câmera rodando com filtro negativo aplicado.
   - **Screenshot 3:** câmera frontal espelhada + negativo.
   - **Screenshot 4:** switch "Negativo" desligado (preview sem filtro).
   - **Screenshot 5:** botão "Parar" em destaque.
   - **Screenshot 6:** demonstração apontando para uma pintura real (use uma foto de pintura).

4. No iPhone: `Cmd+Shift+3` para screenshot. As imagens ficam em Photos > Screenshots.
5. AirDrop para o Mac.
6. No Mac, use Preview ou Photoshop para **redimensionar** para o tamanho exato (ex.: 1290 × 2796).

## Como gerar via Fastlane Snapshot (automação)

Recomendado se você for atualizar screenshots frequentemente.

### Setup

```bash
cd /path/ao/MazolaApple
# Instalar fastlane se ainda nao tem
brew install fastlane

# Inicializar snapshot
fastlane snapshot init
```

### UI Tests mínimos

Crie um target de UI Test (File > New > Target > iOS UI Testing Bundle). No `MazolaEffectUITests.swift`:

```swift
import XCTest

final class MazolaEffectUITests: XCTestCase {
    func testScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UITEST_SCREENSHOTS", "YES"]
        app.launch()

        // 1. tela inicial
        snapshot("01_TelaInicial")

        // 2. iniciar camera
        app.buttons["Iniciar camera"].tap()
        Thread.sleep(forTimeInterval: 2)
        snapshot("02_CameraNegativo")

        // 3. trocar camera
        app.buttons["Trocar camera"].tap()
        Thread.sleep(forTimeInterval: 2)
        snapshot("03_FrontalEspelhada")

        // 4. desligar negativo
        let negativoSwitch = app.switches.firstMatch
        negativoSwitch.tap()
        Thread.sleep(forTimeInterval: 1)
        snapshot("04_SemFiltro")

        // 5. parar
        app.buttons["Parar camera"].tap()
        snapshot("05_Parado")
    }
}
```

### Gerar

```bash
fastlane snapshot --devices "iPhone 15 Pro Max,iPhone 14 Plus" --languages "pt-BR"
```

Saída: `fastlane/screenshots/pt-BR/` com todas as imagens prontas para upload.

### Compor screenshots com texto

```bash
fastlane frameit
```

`frameit` adiciona o frame do device + título abaixo. Veja: <https://docs.fastlane.tools/actions/frameit/>

## Checklist de screenshots

- [ ] 6.7" — 6 a 10 imagens (ou 3 a 10 por linguagem)
- [ ] 6.5" — 3 a 10 imagens
- [ ] 5.5" — 3 a 10 imagens (opcional se 6.7" + 6.5" já enviados)
- [ ] iPad 12.9" — 3 a 10 imagens (opcional para apps universais)
- [ ] PNG ou JPEG sem alpha
- [ ] Sem URLs ou botões falsos que confundam o usuário
- [ ] Sem menções a "Beta" ou "Apple"
- [ ] Texto legível na imagem (não muito pequeno)

## App Preview video (opcional, recomendado)

- Duração: 15 a 30 segundos
- Resolução igual a do screenshot (ex.: 1290 × 2796 para 6.7")
- Sem áudio com rights de terceiros
- Mostre o fluxo: tocar "Iniciar" → ver negativo → trocar câmera → desligar filtro → parar.
