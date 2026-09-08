---
name: trabalho-visual
description: Consultar o registry shadcn ANTES de escrever qualquer componente de interface do zero. Use sempre que a tarefa envolver algo que o usuário vê - tela de app, página web, componente, layout, NUI, formulário, dashboard, tema, ícone, modal, tabela, card, navegação, onboarding, estado vazio - em React, Next.js, React Native ou Expo. Vale também para componente pequeno.
---

# Trabalho visual: registry antes do zero

Antes de escrever qualquer código de interface do zero:

1. Consultar o MCP `shadcn` e buscar componentes ou blocos que resolvam a tarefa.
2. Listar para o Alexandre o que foi encontrado, com nome e uma linha do que faz.
3. Perguntar se ele quer usar algum desses ou partir para código próprio.
4. Só escrever do zero se ele recusar as opções ou se nada no registry servir.

Nunca pular a consulta alegando que a tarefa é simples. Componente pequeno também passa.

## React Native e Expo

Usar o framework `react-native` na busca e priorizar equivalentes do
**React Native Reusables**.

## Precedência: design system do projeto manda

Projeto que já tem design system próprio e documentado continua mandando. O caso de
referência é o **MeuEscolar** (`FormUI.tsx` / `UI.tsx`).

Ali a consulta ao registry serve para peça que o design system ainda **não** cobre. Não
serve para substituir componente existente, nem para reabrir decisão visual já fechada
com o Alexandre.

## Quando o registry não é o caminho

Interface nativa de sistema (GTK, Qt, layer-shell do Hyprland) não tem equivalente no
registry, que é React/web. Nesses casos a consulta se resolve rápido: reportar que nada
serve e seguir com o toolkit nativo.
