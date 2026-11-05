# agent-skills

Minhas skills de agentes (Claude Code, Codex, Antigravity, inclusive dentro do T3 Code), sincronizadas entre computadores.

## Instalar num computador novo

```bash
git clone https://github.com/CodeVanzi/agent-skills ~/.agent-skills
~/.agent-skills/install.sh
```

## Atualizar

```bash
cd ~/.agent-skills && git pull && ./install.sh
```

## Adicionar skills

- **De outro repositório:** adicione uma linha em `upstream.txt` (ex.: `anthropics/skills skills/webapp-testing`) e rode `./install.sh --update`.
- **Minha própria skill:** crie `skills/<nome>/SKILL.md`.

Depois: `git add -A && git commit -m "..." && git push`, e nos outros computadores `git pull && ./install.sh`.

## Como funciona

As skills ficam em `skills/`. O `install.sh` cria symlinks para elas em:

| Agente | Pasta |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| Antigravity CLI | `~/.gemini/antigravity-cli/skills/` |
| Antigravity no T3 Code | `~/.t3/userdata/providers/antigravity/*/{config,antigravity-cli}/skills/` |

Rode `./install.sh` de novo se o T3 recriar o perfil do Antigravity ou se você instalar um agente novo.
