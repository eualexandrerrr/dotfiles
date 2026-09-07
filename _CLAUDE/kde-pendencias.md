# Pendencias conhecidas do KDE

- ~~**Dolphin nao persiste modo de visao**~~ -- **resolvido em 07/09/2026**, ver secao abaixo.
- O cursor `Windows-modern-dark-cursors` do tema nunca existiu no disco; usamos Fluent-dark.
- Menu iniciar do Windows Modern: Locais vem de `rightColumnItems` (config do plasmoid), nao
  dos XDG dirs -- mudar XDG nao muda o menu.

## Resolvido -- borda grossa nas janelas (07/09/2026)

Borda grossa em volta de toda janela, mais retangulo escuro vazando nos cantos arredondados.
Era o efeito **`kwin4_effect_shapecorners`** (`Radius=12`), que recorta **toda** janela --
independente de decoracao e de estilo de widget. Por isso o sintoma sobreviveu a trocar
padding do tema Aurorae, a trocar decoracao (Aurorae -> Klassy) e a trocar Kvantum
(Win11OS-dark -> LayanBlack): nenhum deles era o culpado.

Desligado em dois lugares, porque um so nao segura:

```
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_shapecornersEnabled false
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect kwin4_effect_shapecorners
```

e o `loadEffect kwin4_effect_shapecorners` saiu da `etapa_recarregar()` do `setup.sh` -- ele
forcava o carregamento a cada refresh, mesmo com o efeito desabilitado no `kwinrc`. Conferir
com `isEffectLoaded` (tem que dar `false`). O Plasma 6.5+ ja arredonda canto de janela
nativamente, entao o efeito era redundante.

**Metodo:** quando o sintoma sobrevive a troca de um componente, esse componente esta
inocente. Isolar o que e comum a todos os testes vale mais que trocar a peca que parece
culpada.


## Resolvido -- modo de visao do Dolphin (07/09/2026)

A nota antiga dizia que o Dolphin "nao grava view_properties". Grava: desde a **Version=4**
ele guarda as propriedades no **extended attribute** `user.kde.fm.viewproperties#1` do
diretorio, e **apaga o `.directory`** depois de salvar. Fonte: `ViewProperties::save()` ->
`cleanDotDirectoryFile()`, em `dolphin/src/views/viewproperties.cpp`. Por isso versionar
`.directory` nao adiantava -- some no primeiro save.

Ordem de leitura em `ViewProperties::loadProperties()`: **`.directory` primeiro** (se tiver
grupo `[Dolphin]` ou `[Settings]`), xattr depois. Um `.directory` velho anula o xattr.

Comportamento pedido -- detalhes em toda pasta, menos as que o usuario mudar:

| Chave | Valor | Efeito |
|:--|:--|:--|
| `dolphinrc` `GlobalViewProps` | `false` | cada pasta guarda a sua; sem isso, mudar uma muda todas |
| xattr de `view_properties/global` | `ViewMode=1` | default de quem nao tem propria, via `defaultProperties()` |

`ViewMode`: **0 icones, 1 detalhes, 2 compacto** (`dolphin_directoryviewpropertysettings.kcfg`).

O **tamanho** dos itens nao vem do xattr e sim do `dolphinrc`: `[DetailsMode] PreviewSize`. No
xattr existe `ZoomLevel`, mas o default e `-1`, e com `-1` o Dolphin cai no `PreviewSize` --
por isso o valor certo mora no `settings.conf`, versionado no git, em vez do xattr, que nao
entra no repo. A escala do zoom e `16, 22, 32, 48, 64, 96, 128, 256` (indice 0 a 7), entao
cada passo do Ctrl+scroll pula uma dessas casas.

O `settings.conf` forcava `PreviewSize=32` enquanto o default do Dolphin e
`KIconLoader::SizeLarge`, ou seja `48`. Dava exatamente um Ctrl+scroll pra cima de diferenca,
e o `apply.sh` revertia o ajuste manual a cada `setup.sh`. Corrigido para `48`.

Aplicado por `kde/dolphin-visao.sh`, chamado na etapa `kde` do `setup.sh`. xattr nao entra no
git, entao o script e o unico jeito de isso sobreviver ao format. Conferir:

```
getfattr -n 'user.kde.fm.viewproperties#1' ~/.local/share/dolphin/view_properties/global
```

## Pendente -- "Folder" nao traduzido na coluna Tipo

A coluna Tipo mostra `Folder` em vez de `Pasta`. Ja descartado: locale do sistema e do
processo (`LANG=pt_BR.UTF-8`, `LANGUAGE=pt_BR`), traducao presente nos dados
(`<comment xml:lang="pt-BR">Pasta` em `/usr/share/mime/inode/directory.xml`), `.mo` do
shared-mime-info instalado, `mime.cache` atualizado, sem banco MIME local sobrepondo.
Hipotese restante: o Qt nao casa `xml:lang="pt-BR"` (hifen) com o locale `pt_BR`
(sublinhado) ao resolver `QMimeType::comment()`. Confirmar exige compilar um teste em C++
contra o Qt -- o `qml6` nao roda headless nesta maquina.
