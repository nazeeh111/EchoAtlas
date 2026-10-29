#!/bin/bash
# Promote a tested app/archive pair without discarding the previous outputs on
# an ordinary command failure. No installation or application launch occurs here.
set -euo pipefail
if [[ $# != 3 ]]; then
  echo "Usage: $0 tested-app tested-zip output-directory" >&2
  exit 2
fi
APP=$1
ARCHIVE=$2
OUTPUT=$3
[[ -d "$APP" && -f "$ARCHIVE" ]] || { echo "Tested app and archive are required." >&2; exit 2; }
mkdir -p "$OUTPUT"
STAGE=$(mktemp -d "$OUTPUT/.echoatlas-publish.XXXXXX")
HAD_APP=false
HAD_ARCHIVE=false
[[ ! -e "$OUTPUT/EchoAtlas.app" ]] || HAD_APP=true
[[ ! -e "$OUTPUT/EchoAtlas.zip" ]] || HAD_ARCHIVE=true
PROMOTING=false
cleanup() {
  local status=$?
  trap - EXIT HUP INT TERM
  set +e
  local recovered=true
  if [[ $status != 0 && "$PROMOTING" == true ]]; then
    # Only remove an output when its original is backed up or it did not exist.
    for item in EchoAtlas.app EchoAtlas.zip; do
      if [[ -e "$STAGE/previous/$item" ]]; then
        if ! rm -rf "$OUTPUT/$item"; then recovered=false; continue; fi
        if ! mv "$STAGE/previous/$item" "$OUTPUT/$item"; then recovered=false; fi
      elif [[ "$item" == EchoAtlas.app && "$HAD_APP" == false ]] ||
           [[ "$item" == EchoAtlas.zip && "$HAD_ARCHIVE" == false ]]; then
        if ! rm -rf "$OUTPUT/$item"; then recovered=false; fi
      fi
    done
  fi
  if [[ "$recovered" == true ]]; then
    rm -rf "$STAGE"
  else
    echo "Output recovery failed. Previous artifacts are preserved in $STAGE/previous" >&2
  fi
  exit "$status"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
# Copying and all archive checks finish before promotion begins. The final moves
# stay inside the output directory, so each individual artifact rename is atomic.
ditto --noextattr --norsrc "$APP" "$STAGE/EchoAtlas.app"
cp "$ARCHIVE" "$STAGE/EchoAtlas.zip"
mkdir "$STAGE/previous"
PROMOTING=true
if [[ "$HAD_APP" == true ]]; then mv "$OUTPUT/EchoAtlas.app" "$STAGE/previous/EchoAtlas.app"; fi
if [[ "$HAD_ARCHIVE" == true ]]; then mv "$OUTPUT/EchoAtlas.zip" "$STAGE/previous/EchoAtlas.zip"; fi
mv "$STAGE/EchoAtlas.app" "$OUTPUT/EchoAtlas.app"
mv "$STAGE/EchoAtlas.zip" "$OUTPUT/EchoAtlas.zip"
