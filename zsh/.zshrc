export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
export EDITOR='nvim'
eval "$(oh-my-posh init zsh --config ~/.poshthemes/atomic.omp.json)"
#eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.zsh_aliases
function __tmux_status__() {
  [[ -z ${TMUX} ]] && return 1
  local -r separator=''
  [[ ${KEYMAP} == 'vicmd' ]] \
    && local -r \
      mode="#[fg=black,bg=green]#{?#{==:#{pane_current_command},zsh}, -- NORM -- #[default]#[fg=green]#[bg=blue]#{?client_prefix,#[bg=yellow],}${separator},}" \
    || local -r \
      mode="#[fg=blue,bg=black]#{?#{==:#{pane_current_command},zsh}, -- INS -- #[default]#[fg=black]#[bg=blue]#{?client_prefix,#[bg=yellow],}${separator},}"
  tmux set -g status-left "${mode}#[fg=black,bg=blue]#{?client_prefix,#[bg=yellow],} S/#S #[default]#[fg=blue]#{?client_prefix,#[fg=yellow],}${separator}"
}
zle -N zle-line-init __tmux_status__
zle -N zle-keymap-select __tmux_status__

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='git ls-files --cached --others --exclude-standard'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'head -n 400 {}'"
export FZF_ALT_C_COMMAND='find . -type d'
export FZF_ALT_C_OPTS="--preview 'ls -1 {}'"
export FZF_CTRL_R_OPTS="--height 60% --layout=reverse --border"
export FZF_DEFAULT_OPTS="
    --height 80% --reverse --border=sharp --margin=0,1
    --prompt=' ' --color=light
"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
    --preview 'bat --color=always --style=header,grid {}'
    --preview-window=right:60%
"
export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'
"
function rgf() {
    rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}
fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}

zle -N fzf-z-search
bindkey '^z' fzf-z-search

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

fdoclog() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && docker logs -f --tail=200 "$cid"
}

fdcntre() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -m -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && echo $cid | xargs docker container restart
}

fdocrm() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -m -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && echo $cid | xargs docker container rm -f
}

fdocimrm() {
  local cid
  cid=$(docker image ls -a | sed 1d | fzf -m -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && echo $cid | xargs docker image rm -f
}
function prev(){
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

search_history() {
  BUFFER=$(history | grep -i "$BUFFER" | fzf)
  CURSOR=${#BUFFER}
}

zle -N search_history
export PATH=$PATH:~/go/bin
alias tree="tree -I 'node_modules|.git|.venv|__pycache__' -a -N"
alias lgit="lazygit"
alias doc="lazydocker"
#source ~/fzf-git.sh/fzf-git.sh
# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}
    --preview 'bat --color=always --style=header,grid {}'
    --preview-window=right:60%
"

[ -s "/home/ichio/.bun/_bun" ] && source "/home/ichio/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

dockerlogin() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && docker exec -it "$cid" /bin/bash
}
dockerlog() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && docker logs -f --tail=200 "$cid"
}
dockerrestert() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -m -q "$1" | awk '{print $1}')  
  [ -n "$cid" ] && echo $cid | xargs docker container restart
}

gadd() {
  local out q n addfiles
  while out=$(
      git status --short |
      awk '{if (substr($0,2,1) !~ / /) print $2}' |
      fzf-tmux --multi --exit-0 --expect=ctrl-d); do
    q=$(head -1 <<< "$out")
    n=$[$(wc -l <<< "$out") - 1]
    addfiles=(`echo $(tail "-$n" <<< "$out")`)
    [[ -z "$addfiles" ]] && continue
    if [ "$q" = ctrl-d ]; then
      git diff --color=always $addfiles | less -R
    else
      git add $addfiles
    fi
  done
}
