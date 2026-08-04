# ─── Environment ──────────────────────────────────────────────
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-R'

[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$PATH"

# ─── History ──────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt HIST_VERIFY SHARE_HISTORY APPEND_HISTORY

# ─── Shell options ────────────────────────────────────────────
setopt AUTO_CD INTERACTIVE_COMMENTS NO_BEEP PROMPT_SUBST

# ─── Completion ───────────────────────────────────────────────
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ─── Vi mode ──────────────────────────────────────────────────
# MUST precede fzf: `bindkey -v` resets the keymap
bindkey -v
export KEYTIMEOUT=1

# Cursor: block in normal, beam in insert
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      print -n '\e[1 q' ;;
    viins|main) print -n '\e[5 q' ;;
  esac
}
zle -N zle-keymap-select
function zle-line-init { print -n '\e[5 q' }
zle -N zle-line-init
preexec() { print -n '\e[5 q' }

# k/j search history by what's already typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

# v in normal mode → edit the command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Keys vi mode otherwise takes away
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line

# ─── fzf ──────────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
      source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
      source /usr/share/doc/fzf/examples/completion.zsh
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

  if command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
  elif command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  fi
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  if command -v fdfind >/dev/null 2>&1; then
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
  elif command -v fd >/dev/null 2>&1; then
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi

  if command -v batcat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:200 {}'"
  elif command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  fi
fi

# ─── Aliases ──────────────────────────────────────────────────
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v nvim   >/dev/null 2>&1 && alias vim='nvim'

alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# ─── Prompt ───────────────────────────────────────────────────
PROMPT='%F{%(#.blue.green)}┌──(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]
└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '

# ─── Autosuggestions ──────────────────────────────────────────
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)

  bindkey -M viins '^@' autosuggest-accept
  bindkey -M viins '^G' autosuggest-clear
fi

# ─── Completion extras ────────────────────────────────────────
zmodload zsh/complist
_comp_options+=(globdots)

# ─── eza (falls back to ls where unavailable) ─────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
fi

# ─── Jump shortcuts ───────────────────────────────────────────
alias dots='cd ~/dotfiles'
alias i3conf='cd ~/.config/i3'

# ─── Wallpaper ────────────────────────────────────────────────
if command -v feh >/dev/null 2>&1; then
  wp() {
    local d="$HOME/Pictures/wallpapers"
    local f
    if [ -n "${1:-}" ]; then
      f="$d/$1"
    elif command -v fzf >/dev/null 2>&1; then
      f="$(find "$d" -maxdepth 1 -type f | fzf --prompt='wallpaper> ')" || return
    else
      echo "usage: wp <filename>"; ls "$d"; return 1
    fi
    [ -f "$f" ] || { echo "no such file: $f"; return 1; }
    ln -sfn "$f" ~/.wallpaper && feh --bg-fill ~/.wallpaper && echo "set: $(basename "$f")"
  }
fi

# ─── ranger image preview (Debian path) ───────────────────────
[ -x /usr/lib/w3m/w3mimgdisplay ] && export W3MIMGDISPLAY_PATH=/usr/lib/w3m/w3mimgdisplay

# ─── Machine-local overrides (never committed) ────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ─── Syntax highlighting: MUST be the last line ───────────────
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
