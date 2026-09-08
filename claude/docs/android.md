# Android SDK e emulador

Instalado por `bin/android-sdk.sh`, chamado pela etapa `install_android_sdk` do `install.sh`
(entre `install_node_tools` e `configure_nvidia`). Roda sozinho tambem:

```
~/.dotfiles/bin/android-sdk.sh          # instala o que falta e cria os AVDs
~/.dotfiles/bin/android-sdk.sh avds     # so os AVDs, sem baixar nada
~/.dotfiles/bin/android-sdk.sh estado   # o que existe e o que falta
```

E idempotente: rodar de novo confere o hardware dos AVDs e nao recria nada.

## Onde fica o que

| | caminho |
|---|---|
| SDK | `~/Android/Sdk` (sem Android Studio, sem root) |
| AVDs | `~/.android/avd` |
| `adb` | `/usr/bin/adb`, do pacote `android-tools` |
| `emulator`, `avdmanager` | do SDK, entram no PATH pelo `.zprofile` |

**`platform-tools` fica de proposito fora do PATH.** O `adb` e o do pacote do sistema; dois
`adb` no PATH derrubam a conexao com o device sem dizer por que.

Pacotes do `packages.txt` que isso exige (ja estavam la): `android-tools`, `android-udev`,
`jdk17-openjdk`, `unzip`, `python`.

## Os AVDs

| AVD | porta | serial | quando |
|---|---:|---|---|
| `Main_Debug` | 5554 | `emulator-5554` | sempre |
| `Main_Debug_2` | 5556 | `emulator-5556` | quando precisa de dois ao mesmo tempo |

Pixel 5, Android 16 (API 36, `google_apis`), **12 GB de RAM, 8 nucleos**, heap de 1 GB,
dados de 8 GB, teclado do host ligado, sem moldura de aparelho.

A RAM nao e exagero: no padrao de 2 GB do Android Studio um dev build React Native / Expo
(Hermes + Metro + Firebase + mapas) engasga, trava e derruba o app, e o tempo se perde
cacando bug que nao existe.

Imagem `google_apis` e **nao** `google_apis_playstore`: a de Play Store bloqueia `adb root`,
e sem root nao da para aplicar locale nem fuso por `setprop`.

Boot headless com KVM aqui: ~25 s.

```
emulator -avd Main_Debug -port 5554 -no-window -gpu swiftshader_indirect -no-boot-anim
until [ "$(adb -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r')" = 1 ]; do sleep 3; done
```

## Duas armadilhas do cmdline-tools 16 que o script contorna

**`avdmanager create avd -d <device>` morre com `Could not load devices from
<system-image>/devices.xml`.** O arquivo simplesmente nao existe na system image. Escrever um
`devices.xml` vazio de schema 8 nessa pasta resolve; sem `-d` ele nem chega a perguntar.

**Com `XDG_CONFIG_HOME` definido o AVD nasce no lugar errado.** O `avdmanager` grava em
`$XDG_CONFIG_HOME/.android/avd`, enquanto `adb` e `emulator` leem `~/.android`. O script move
a pasta e reescreve o `path=` do `.ini`.

De quebra: o `avdmanager` pergunta "Do you wish to create a custom hardware profile?" e so
aceita a resposta de um tty -- com stdin redirecionado ele desiste calado, sem criar nada e
saindo com codigo 0. Por isso a criacao roda dentro de um pty (Python).

## Quem consome isso

A **RCode** (`~/Apps/desktop/RCode`) sobe os dois AVDs e espelha a tela do Android dentro de
uma aba dela, com toque e teclado -- ela acha o SDK sozinho procurando `~/Android/Sdk`. AVD
novo entra na lista `AVDS` do `bin/android-sdk.sh`, nunca criado na mao.
