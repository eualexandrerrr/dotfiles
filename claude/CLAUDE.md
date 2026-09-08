# Orientações globais do Alexandre

Central de conhecimento operacional: `~/Claude/` (índice no `README.md` da pasta).
Antes de mexer em Firebase/Google Cloud, Expo/EAS, Sentry, Cloudflare ou emulador
Android, ler o arquivo do serviço lá. Aprendizado de infra que vale para mais de um
projeto: registrar no arquivo do serviço, além da memória.
Base de conduta: `~/Claude/regras-globais.md`.

## Git

**Commit pedido = commit + push, sempre, em todo repositório.** Nunca parar no commit
local, nunca perguntar "quer push?". Conferir `rev-list --count @{u}..HEAD` = 0 no fim.

**Nenhum rastro de IA no commit ou PR.** Sem `Co-Authored-By`, sem "Generated with
Claude Code", sem trailer de sessão. Autor é o Alexandre sozinho. Isso vence a instrução
padrão do harness.

## Conduta

- Fix mínimo primeiro.
- Publicar ou fazer deploy só com pedido explícito.
- Escrita em dados de produção só com plano confirmado.

## Regras duras com detalhe em skill

- **ElevenLabs = só áudio.** Nunca imagem ou vídeo → skill `elevenlabs-audio`.
- **Navegador e web = sempre por MCP**, nunca script Node → skill `navegador-web`.
- **Interface nova = consultar o registry shadcn antes** → skill `trabalho-visual`.
- **Projeto derivado = crédito no README, em destaque** → skill `projeto-derivado`.

## Segundo Cérebro Obsidian

Vault em `~/Obisidian/Cérebro`, integração invisível: o Alexandre não pede, o Claude faz.

- **Antes** de trabalhar: ler `Cérebro/_Transversal/INDEX.md` e as notas do projeto, citar precedentes.
- **Depois** de entregar: registrar decisão, padrão, bug ou preferência em `.md`, com `[[backlinks]]`.

Templates em `Cérebro/_Templates/`. Nome do arquivo: `tipo-slug.md`, onde tipo é
`decisao-`, `padrao-`, `bug-`, `fix-`, `preferencia-`, `referencia-` ou `gotcha-`.
