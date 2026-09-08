---
name: elevenlabs-audio
description: ElevenLabs é só para áudio - nunca para imagem ou vídeo. Use ao gerar voz, narração, TTS, dublagem, transcrição, ou ao precisar gerar/editar uma imagem, ícone, logo, ilustração, thumbnail ou vídeo.
---

# ElevenLabs = SÓ ÁUDIO

Regra dura de 25/08/2026.

**Permitido:** `creative_generate_speech`, `creative_transcribe_audio`,
`creative_list_voices`, `creative_design_voice`, agentes de voz.

**PROIBIDO, sem exceção:** `creative_generate_image`, `creative_generate_video`,
`creative_edit_image`. Não usar nem "só para testar".

## O que fazer quando a tarefa pede imagem

1. SVG escrito à mão, ou HTML→PNG pela pasta `~/Claude/ferramentas`.
2. Se nenhum dos dois servir, **perguntar ao Alexandre qual gerador usar**. Nunca
   escolher sozinho.

Ícone de app tem gerador próprio em `~/Claude/ferramentas`.

Contexto em `~/Claude/elevenlabs.md`.
