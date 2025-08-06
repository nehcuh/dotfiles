@@ .. @@
 # Z
 if (( $+commands[zoxide] )); then
     eval "$(zoxide init zsh)"
     export _ZO_FZF_OPTS="--scheme=path --tiebreak=end,chunk,index \
            --bind=ctrl-z:ignore,btab:up,tab:down --cycle --keep-right \
            --border=sharp --height=45% --info=inline --layout=reverse \
            --tabstop=1 --exit-0 --select-1 \
            --preview '(eza --tree --icons --level 3 --color=always \
            --group-directories-first {2} || tree -NC {2} || \
            ls --color=always --group-directories-first {2}) 2>/dev/null | head -200'"
 else
     zinit ice wait lucid depth"1"
     zinit light agkozak/zsh-z
 fi
 
+# Pyenv
+if command -v pyenv >/dev/null 2>&1; then
+    eval "$(pyenv init -)"
+fi
+
+# Direnv
+if command -v direnv >/dev/null 2>&1; then
+    eval "$(direnv hook zsh)"
+fi
+
+# NVM
+[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
+[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
+
 # Git extras