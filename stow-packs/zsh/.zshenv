@@ .. @@
 # Rust
 export PATH=$HOME/.cargo/bin:$PATH
 
+# Pyenv
+export PYENV_ROOT="$HOME/.pyenv"
+[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
+
+# NVM
+export NVM_DIR="$HOME/.nvm"
+
 # APIKEY - Replace with your actual keys
 # export OPENAI_API_KEY=your-openai-api-key
 # export OPENAI_BASE_URL="https://api.openai.com/v1"