export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.android/avd"
# platform-tools de proposito fora do PATH: o adb vem do pacote android-tools, e dois adb
# no PATH derrubam a conexao com o device sem dizer por que.
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin"
