---
name: maestro-bug
description: Reproduzir um bug relatado de app Expo/React Native no emulador Android com o Maestro MCP, transformar em fluxo YAML e entregar evidência (commands.json, screenshots, logcat, vídeo). Usar quando o Alexandre pedir para reproduzir, confirmar ou investigar um bug de tela, GPS, notificação, rede ou estado do app no emulador.
---

# /maestro-bug — reproduzir bug no emulador

Manual completo: `C:\Users\Alexandre\Downloads\Apps\claude/docs\maestro.md` (Maestro) e
`claude/docs\emulador-reproducao.md` (estado do device por adb). Ler os dois antes de começar.

## Entrada

Relato do usuário (texto, print, mensagem de WhatsApp, issue do Sentry). Extrair e escrever antes
de tocar no emulador:

- **Conta**: email ou uid de quem viu o bug.
- **Tela e ação**: onde estava, o que tocou, o que esperava, o que viu.
- **Estado**: GPS (parado, em rota, coordenadas), rede (offline, ruim), app em background ou
  morto, hora/dia, tema, permissões, versão do app.

## Passos

1. **Device**: `node claude/docs/emulador.js pronto <app>`. Depois `list_devices` no MCP → `emulator-5554`.
2. **Conta**: auto-login DEV do app (`node scripts/gerar-token-debug.js EMAIL` no MeuEscolar) e
   reabrir o app. Nunca digitar senha em YAML.
3. **Estado do device**: só o que o relato exige, com as receitas de `emulador-reproducao.md`
   (`geo fix`, `svc wifi disable`, `am kill`, Doze, `cmd uimode`, `date`). Anotar cada comando
   usado — ele entra no relatório.
4. **Explorar pelo MCP**: `inspect_screen` → `run` com YAML inline de vários passos →
   `inspect_screen`. Copiar `txt`/`rid` literalmente. Teclado aberto → `hideKeyboard` antes de
   inspecionar. Screenshot só para ambiguidade visual.
5. **Não reproduziu?** Relatar exatamente o que foi tentado e o que a tela mostrou. Não forçar.
6. **Reproduziu** → gravar `.maestro/repro/<id>-<slug>.yaml` a partir de `.maestro/repro/_modelo.yaml`
   (`tags: [repro]`, `startRecording` + `stopRecording` em `onFlowComplete`, `takeScreenshot`
   antes e depois). Rodar **pela CLI** para ter artefato:

   ```powershell
   maestro --device emulator-5554 test --test-output-dir artefatos-maestro --flatten-debug-output .maestro\repro\<id>-<slug>.yaml
   ```

7. **Diagnóstico** pelos artefatos, nesta ordem: `commands.json` (passo `FAILED`, `duration ≈ 17000`
   = elemento não apareceu) → screenshot e `screen-hierarchy` do passo → `logs/crash-report.txt` /
   `anr-report.txt` → `logs/device-logcat.txt` na janela do timestamp (`ReactNativeJS`,
   `AndroidRuntime`, `TaskService`, `LocationTaskConsumer`).
8. **Depois do fix**: rodar o fluxo de novo. Passou e o cenário vale → promover (tirar `repro`,
   mover para a raiz ou pasta da feature). Senão, apagar.

## Saída (sempre neste formato)

- **Reproduzido**: sim / não / parcial, em uma frase.
- **Passos mínimos**: lista numerada, com o estado do device (comandos adb) e o YAML.
- **Evidência**: caminhos de `commands.json`, screenshots, vídeo, logcat; trecho decisivo do
  logcat em bloco de código.
- **Causa provável**: arquivo e função, se já ficou claro; senão, "não determinado" e o que falta.
- **Fluxo salvo**: caminho em `.maestro/repro/`.

## Nunca

- `adb shell input tap X Y`, `uiautomator dump` na mão, `point:` como seletor.
- `sleep`/espera fixa no lugar de `assertVisible`/`extendedWaitUntil`.
- Afirmar dado vivo (hora, contagem, nome real) em fluxo que vai virar regressão.
- Inventar texto de seletor a partir de screenshot.
- Escrever em dados de produção para "ajudar" a reproduzir sem plano confirmado.
