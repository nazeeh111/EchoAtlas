#!/bin/bash
# Filesystem failure injection only: no app, audio, permission or input events.
set -euo pipefail
PUBLISH="$(cd "$(dirname "$0")" && pwd)/publish_outputs.sh"
ROOT=$(mktemp -d /private/tmp/echoatlas-publish-test.XXXXXX)
trap 'rm -rf "$ROOT"' EXIT
mkdir "$ROOT/bin"
cat > "$ROOT/bin/mv" <<'SHIM'
#!/bin/bash
if [[ "${FAIL_STEP:-}" == promote && "$1" == */.echoatlas-publish.*/EchoAtlas.zip && "$1" != */previous/* ]] ||
   [[ "${FAIL_STEP:-}" == backup && "$1" == */outputs/EchoAtlas.zip ]] ||
   [[ "${FAIL_STEP:-}" == recover && ( "$1" == */.echoatlas-publish.*/EchoAtlas.zip && "$1" != */previous/* || "$1" == */previous/EchoAtlas.app ) ]]; then
  echo "Injected move failure: $FAIL_STEP" >&2
  exit 71
fi
exec /bin/mv "$@"
SHIM
cat > "$ROOT/bin/ditto" <<'SHIM'
#!/bin/bash
if [[ "${FAIL_STEP:-}" == copy ]]; then echo 'Injected copy failure' >&2; exit 71; fi
exec /usr/bin/ditto "$@"
SHIM
chmod +x "$ROOT/bin/mv" "$ROOT/bin/ditto"
for mode in success copy backup promote recover first-failure first-success; do
  CASE="$ROOT/$mode"
  mkdir -p "$CASE/new.app" "$CASE/outputs"
  printf 'new app' > "$CASE/new.app/data"
  printf 'new archive' > "$CASE/new.zip"
  if [[ "$mode" != first-* ]]; then
    mkdir "$CASE/outputs/EchoAtlas.app"
    printf 'old app' > "$CASE/outputs/EchoAtlas.app/data"
    printf 'old archive' > "$CASE/outputs/EchoAtlas.zip"
  fi
  STEP=$mode
  [[ "$mode" != first-failure ]] || STEP=promote
  status=0
  PATH="$ROOT/bin:$PATH" FAIL_STEP="$STEP" "$PUBLISH" "$CASE/new.app" "$CASE/new.zip" "$CASE/outputs" > "$CASE/log" 2>&1 || status=$?
  if [[ "$mode" == *success ]]; then
    [[ $status == 0 && $(cat "$CASE/outputs/EchoAtlas.app/data") == 'new app' && $(cat "$CASE/outputs/EchoAtlas.zip") == 'new archive' ]] || exit 1
  elif [[ "$mode" == first-failure ]]; then
    [[ $status == 71 && ! -e "$CASE/outputs/EchoAtlas.app" && ! -e "$CASE/outputs/EchoAtlas.zip" ]] || exit 1
  elif [[ "$mode" == recover ]]; then
    [[ $status == 71 && $(cat "$CASE/outputs/EchoAtlas.zip") == 'old archive' ]] || exit 1
    backup=("$CASE"/outputs/.echoatlas-publish.*/previous/EchoAtlas.app/data)
    [[ ${#backup[@]} == 1 && $(cat "${backup[0]}") == 'old app' ]] || exit 1
    /usr/bin/grep -q 'Previous artifacts are preserved' "$CASE/log" || exit 1
  else
    [[ $status == 71 && $(cat "$CASE/outputs/EchoAtlas.app/data") == 'old app' && $(cat "$CASE/outputs/EchoAtlas.zip") == 'old archive' ]] || exit 1
  fi
  if [[ "$mode" != recover ]]; then
    leftovers=("$CASE"/outputs/.echoatlas-publish.*)
    [[ ! -e "${leftovers[0]}" ]] || exit 1
  fi
  printf 'PASS output publication: %s\n' "$mode"
done
