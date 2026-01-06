#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVBOX_DIR="$ROOT_DIR/docker-samples/ubuntu25.04-devbox"
CONTAINER_NAME="${DOTFILES_TEST_CONTAINER_NAME:-devbox}"
REMOTE_REPO_DIR="/tmp/dotfiles-under-test"
STRICT="${STRICT:-false}"
NO_BUILD="${NO_BUILD:-false}"
KEEP="${KEEP:-false}"

usage() {
  cat <<'EOF'
Usage: scripts/test-linux-install.sh [options]

Runs non-destructive Linux install integration checks inside the devbox container.

Options:
  --strict        Fail if default install prints missing-package warnings
  --no-build      Do not rebuild the devbox image
  --keep          Keep container running after tests
  --down          Stop the devbox stack after tests
  -h, --help      Show help

Env:
  DOTFILES_TEST_CONTAINER_NAME   Container name (default: devbox)
EOF
}

DOWN_AFTER=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true; shift ;;
    --no-build) NO_BUILD=true; shift ;;
    --keep) KEEP=true; shift ;;
    --down) DOWN_AFTER=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker not found" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker is not running" >&2
  exit 1
fi

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

compose_args=(-f "$DEVBOX_DIR/docker-compose.yml")

echo "[INFO] Starting devbox container ($CONTAINER_NAME)..."
if [[ "$NO_BUILD" == "true" ]]; then
  (cd "$DEVBOX_DIR" && compose "${compose_args[@]}" up -d)
else
  (cd "$DEVBOX_DIR" && compose "${compose_args[@]}" up -d --build)
fi

cleanup() {
  if [[ "$DOWN_AFTER" == "true" ]]; then
    echo "[INFO] Stopping devbox stack..."
    (cd "$DEVBOX_DIR" && compose "${compose_args[@]}" down -v) || true
  elif [[ "$KEEP" != "true" ]]; then
    echo "[INFO] Leaving devbox stack running (use --down to stop)"
  fi
}
trap cleanup EXIT

echo "[INFO] Waiting for container to be ready..."
for _ in {1..30}; do
  if docker exec "$CONTAINER_NAME" true >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker exec "$CONTAINER_NAME" true >/dev/null 2>&1 || {
  echo "[ERROR] Container '$CONTAINER_NAME' not reachable via docker exec" >&2
  exit 1
}

echo "[INFO] Syncing repo into container: $REMOTE_REPO_DIR"
tar -C "$ROOT_DIR" \
  --exclude=.git \
  --exclude=stow-packs/sensitive \
  -cf - . | docker exec -i "$CONTAINER_NAME" bash -lc "
    set -euo pipefail
    rm -rf '$REMOTE_REPO_DIR'
    mkdir -p '$REMOTE_REPO_DIR'
    tar -xf - -C '$REMOTE_REPO_DIR'
    chmod +x '$REMOTE_REPO_DIR/scripts/install.sh'
  "

run_case() {
  local name="$1"
  local cmd="$2"

  echo "[INFO] Case: $name"
  docker exec "$CONTAINER_NAME" bash -lc "set -euo pipefail; $cmd"
}

assert_symlink_exists() {
  local home_dir="$1"
  local rel_path="$2"
  docker exec "$CONTAINER_NAME" bash -lc "
    set -euo pipefail
    test -L '$home_dir/$rel_path'
    target=\$(readlink -f '$home_dir/$rel_path')
    test -e \"\$target\"
  "
}

base_env() {
  cat <<EOF
export DOTFILES_NON_INTERACTIVE=true
export DOTFILES_SKIP_MIRROR_DETECT=1
export DOTFILES_SKIP_BREWFILE=true
export DOTFILES_BREWFILE_INSTALL=false
export DOTFILES_SET_DEFAULT_SHELL=false
EOF
}

case_clean_home="/tmp/dotfiles-test-home-clean"
run_case "clean-install" "
  $(base_env)
  rm -rf '$case_clean_home' && mkdir -p '$case_clean_home'
  HOME='$case_clean_home' DOTFILES_CONFLICT_OVERWRITE=false '$REMOTE_REPO_DIR/scripts/install.sh' > /tmp/dotfiles-test-clean.log 2>&1
  echo '[INFO] clean-install: ok'
"
assert_symlink_exists "$case_clean_home" ".zshrc"
assert_symlink_exists "$case_clean_home" ".config/git/ignore"
assert_symlink_exists "$case_clean_home" ".npmrc"
assert_symlink_exists "$case_clean_home" ".pip.conf"

if [[ "$STRICT" == "true" ]]; then
  run_case "strict-default-packages" "
    if rg -n \"Package .* not found, skipping\" /tmp/dotfiles-test-clean.log >/dev/null; then
      echo '[ERROR] Missing packages in default install:' >&2
      rg -n \"Package .* not found, skipping\" /tmp/dotfiles-test-clean.log >&2
      exit 1
    fi
  "
fi

case_conflict_home="/tmp/dotfiles-test-home-conflict"
run_case "conflict-abort" "
  $(base_env)
  rm -rf '$case_conflict_home' && mkdir -p '$case_conflict_home'
  echo 'existing npmrc' > '$case_conflict_home/.npmrc'
  set +e
  HOME='$case_conflict_home' DOTFILES_CONFLICT_OVERWRITE=false '$REMOTE_REPO_DIR/scripts/install.sh' > /tmp/dotfiles-test-conflict.log 2>&1
  code=\$?
  set -e
  if [[ \$code -eq 0 ]]; then
    echo '[ERROR] Expected conflict-abort to fail but it succeeded' >&2
    exit 1
  fi
  rg -n \"Conflicts detected\" /tmp/dotfiles-test-conflict.log >/dev/null
"

case_overwrite_home="/tmp/dotfiles-test-home-overwrite"
run_case "conflict-overwrite" "
  $(base_env)
  rm -rf '$case_overwrite_home' && mkdir -p '$case_overwrite_home'
  echo 'existing npmrc' > '$case_overwrite_home/.npmrc'
  HOME='$case_overwrite_home' DOTFILES_CONFLICT_OVERWRITE=true '$REMOTE_REPO_DIR/scripts/install.sh' > /tmp/dotfiles-test-overwrite.log 2>&1
  ls -d '$case_overwrite_home'/.dotfiles-backup-* >/dev/null
"
assert_symlink_exists "$case_overwrite_home" ".npmrc"

echo "[INFO] All Linux install integration checks passed"
