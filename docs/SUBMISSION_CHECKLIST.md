# Checklist de Submissão — Mazola Effect

Passo-a-passo completo, do `git clone` ao envio para revisão.

## 1. Preparação

- [ ] 1.1 Ter macOS 13.5+ e Xcode 15+ instalados.
- [ ] 1.2 Ter conta **Apple Developer** ativa (paga, USD 99/ano).
- [ ] 1.3 Clonar o repo:
      ```bash
      git clone https://github.com/superaplicativos/MazolaApple.git
      cd MazolaApple
      ```
- [ ] 1.4 Instalar XcodeGen (opcional, recomendado):
      ```bash
      brew install xcodegen
      xcodegen generate
      open MazolaEffect.xcodeproj
      ```
- [ ] 1.5 Caso prefira não usar XcodeGen, criar um novo projeto iOS App no Xcode com:
      - Product Name: `Mazola Effect`
      - Org Identifier: `com.superaplicativos`
      - Bundle ID resultante: `com.superaplicativos.mazolaeffect`
      - Interface: SwiftUI
      - Language: Swift
      - Min Deployments: iOS 16.0

## 2. Configuração do target

- [ ] 2.1 Em **Signing & Capabilities**, selecionar seu Team Apple Developer.
- [ ] 2.2 Confirmar Bundle Identifier: `com.superaplicativos.mazolaeffect`.
- [ ] 2.3 Confirmar Version: `1.0.0`, Build: `1`.
- [ ] 2.4 Confirmar que `Info.plist` contém `NSCameraUsageDescription`.
- [ ] 2.5 Marcar "Automatically manage signing".
- [ ] 2.6 Selecionar deployment target: iOS 16.0.

## 3. Ícone

- [ ] 3.1 Gerar PNG 1024×1024 a partir de `MazolaEffect/Assets.xcassets/AppIcon.appiconset/icon-1024.svg`:
      ```bash
      qlmanage -t -s 1024 -o . icon-1024.svg
      mv icon-1024.svg.png icon-1024.png
      ```
- [ ] 3.2 Atualizar `Contents.json` para apontar para `icon-1024.png`.
- [ ] 3.3 No Xcode, abrir Assets.xcassets > AppIcon e arrastar o PNG 1024.

## 4. Build local de teste

- [ ] 4.1 Selecionar dispositivo físico (iPhone/iPad).
- [ ] 4.2 `Cmd+R` — rodar e testar:
  - [ ] Botão "Iniciar Camera" aparece.
  - [ ] Pediu permissão de câmera?
  - [ ] Filtro negativo aplicado em tempo real?
  - [ ] Trocar para frontal — imagem espelhada?
  - [ ] Desligar switch "Negativo" — imagem volta ao normal?
  - [ ] Botão "Parar" encerra a sessão (LED da câmera desliga)?
- [ ] 4.3 `Cmd+B` — build sem warnings.
- [ ] 4.4 `Cmd+Shift+B` — analyze sem issues.

## 5. Política de privacidade

- [ ] 5.1 Hospedar `docs/PRIVACY.md` em uma URL pública. Sugestões:
  - GitHub Page no próprio repo: <https://superaplicativos.github.io/MazolaApple/privacy/>
  - Ou usar a URL raw: <https://raw.githubusercontent.com/superaplicativos/MazolaApple/main/docs/PRIVACY.md>
- [ ] 5.2 Anotar a URL final:
      ```
      https://raw.githubusercontent.com/superaplicativos/MazolaApple/main/docs/PRIVACY.md
      ```

## 6. App Store Connect setup

- [ ] 6.1 Acessar <https://appstoreconnect.apple.com>.
- [ ] 6.2 Meus Apps > Novo App:
  - Plataformas: iOS
  - Nome: `Mazola Effect`
  - Idioma principal: Português (Brasil)
  - Bundle ID: `com.superaplicativos.mazolaeffect` (deve aparecer na lista se o signing estiver OK)
  - SKU: `mazolaeffect`
  - Acesso completo: Sim
- [ ] 6.3 Preencher Informações do App:
  - Subtítulo: `Câmera com filtro negativo para arte`
  - Categoria primária: Foto e Vídeo
  - Categoria secundária: Entretenimento
  - URL de suporte: `https://github.com/superaplicativos/MazolaApple`
  - URL de marketing: `https://superaplicativos.github.io/MazolaEffect/`
  - Política de privacidade: (URL do passo 5.2)
- [ ] 6.4 Preencher **App Privacy** ("Privacidade do App"):
  - Tipo de coleta de dados: **Não coletamos dados**
  - Confirme todas as perguntas marcando "Não".
- [ ] 6.5 Preencher **Classificação etária**:
  - Violência: Nenhum
  - Conteúdo adulto: Nenhum
  - Apostas: Não
  - Resultado: 4+
- [ ] 6.6 Preencher **Preço**:
  - Grátis
- [ ] 6.7 Preencher **Descrição**, **Keywords** e **Notas do revisor** — copiar de `docs/APP_STORE_METADATA.md`.

## 7. Screenshots

- [ ] 7.1 Gerar screenshots 6.7" (1290 × 2796) — ver `docs/SCREENSHOTS.md`.
- [ ] 7.2 Opcional: gerar 6.5", 5.5" e iPad.
- [ ] 7.3 Upload no App Store Connect > Versão 1.0.0 > Screenshots.

## 8. Archive & Upload

- [ ] 8.1 No Xcode: `Product > Archive` (deve estar em dispositivo iOS genérico).
- [ ] 8.2 No Organizer, selecionar o archive mais recente.
- [ ] 8.3 `Distribute App > App Store Connect > Upload`.
- [ ] 8.4 Aguardar processamento (5–30 min) — você recebe email quando pronto.
- [ ] 8.5 No App Store Connect > Versão 1.0.0 > Build > selecionar o build subido.

## 9. Envio para revisão

- [ ] 9.1 Revisar todos os campos.
- [ ] 9.2 `Adicionar para Revisão`.
- [ ] 9.3 Confirmar as regras de exportação (este app não usa cripto, marque "Nenhum").
- [ ] 9.4 Submeter.

## 10. Pós-revisão

- [ ] 10.1 Acompanhar status em App Store Connect > Status do App.
- [ ] 10.2 Tempo médio: 24–48h.
- [ ] 10.3 Se aprovado, aguardar até 24h para aparecer na App Store.
- [ ] 10.4 Se rejeitado, ler as notas do revisor, corrigir, subir novo build, reenviar.

## 11. Marketing pós-lançamento

- [ ] 11.1 Publicar URL da versão web: <https://superaplicativos.github.io/MazolaEffect/>
- [ ] 11.2 Compartilhar link da App Store.
- [ ] 11.3 Coletar feedback em <https://github.com/superaplicativos/MazolaApple/issues>.
