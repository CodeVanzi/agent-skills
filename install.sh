#!/usr/bin/env bash
# Instala as skills deste repositório para Claude Code, Codex e Antigravity
# (incluindo o Antigravity rodando dentro do T3 Code), via symlinks.
#
# Uso:
#   ./install.sh            # cria/atualiza os symlinks em todos os agentes
#   ./install.sh --update   # baixa as versões mais novas das skills de upstream.txt e depois instala
#
# Pode rodar quantas vezes quiser (idempotente). Rode de novo depois de:
#   - git pull neste repo
#   - instalar um agente novo ou o T3 recriar o perfil do Antigravity
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
T3_HOME="${T3_HOME:-$HOME/.t3}"

update_upstream() {
  local tmp repo path name
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  while read -r repo path _; do
    [[ -z "${repo:-}" || "$repo" == \#* ]] && continue
    name="$(basename "$path")"
    if [[ ! -d "$tmp/$repo" ]]; then
      echo "↓ clonando $repo"
      git clone --depth 1 -q "https://github.com/$repo" "$tmp/$repo"
    fi
    if [[ ! -f "$tmp/$repo/$path/SKILL.md" ]]; then
      echo "✗ $repo/$path não tem SKILL.md, pulando" >&2
      continue
    fi
    rm -rf "${SKILLS_DIR:?}/$name"
    cp -r "$tmp/$repo/$path" "$SKILLS_DIR/$name"
    echo "✓ atualizada: $name ($repo/$path)"
  done < "$REPO_DIR/upstream.txt"
}

# Pastas de skills globais de cada agente.
targets() {
  echo "$HOME/.claude/skills"                 # Claude Code
  echo "$HOME/.codex/skills"                  # Codex
  echo "$HOME/.gemini/antigravity-cli/skills" # Antigravity CLI (fora do T3)
  if [[ -d "$HOME/.gemini/config" ]]; then echo "$HOME/.gemini/config/skills"; fi
  # Antigravity dentro do T3 Code: perfil isolado por hash
  local d
  for d in "$T3_HOME"/userdata/providers/antigravity/*/; do
    [[ -d "$d" ]] || continue
    echo "${d}config/skills"
    echo "${d}antigravity-cli/skills"
  done
}

link_all() {
  local target skill name dest link
  mkdir -p "$SKILLS_DIR"
  while read -r target; do
    mkdir -p "$target"
    # remove symlinks antigos que apontam para skills deste repo que não existem mais
    for link in "$target"/*; do
      if [[ -L "$link" && "$(readlink "$link")" == "$SKILLS_DIR"/* && ! -e "$link" ]]; then
        rm -f "$link" && echo "  − removido link quebrado: $link"
      fi
    done
    for skill in "$SKILLS_DIR"/*/; do
      [[ -f "${skill}SKILL.md" ]] || continue
      name="$(basename "$skill")"
      dest="$target/$name"
      if [[ -e "$dest" && ! -L "$dest" ]]; then
        echo "  ! $dest já existe e não é symlink, deixei como está" >&2
        continue
      fi
      ln -sfn "${skill%/}" "$dest"
    done
    echo "✓ $target"
  done < <(targets)
}

if [[ "${1:-}" == "--update" ]]; then
  update_upstream
fi
link_all
echo "Pronto. Skills: $(cd "$SKILLS_DIR" && ls -d */ 2>/dev/null | tr -d / | tr '\n' ' ')"
echo "Abra uma conversa nova nos agentes para eles carregarem as skills."
