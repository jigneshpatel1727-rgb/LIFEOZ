#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Application-layer dependency gate. Build infrastructure (GitHub Actions,
# Android SDK/JDK tools) is intentionally outside this audit.

fail=0

# No third-party package/build manifests are allowed inside the native app.
forbidden_files=(
  "$ROOT/pubspec.yaml"
  "$ROOT/package.json"
  "$ROOT/yarn.lock"
  "$ROOT/package-lock.json"
  "$ROOT/settings.gradle"
  "$ROOT/build.gradle"
  "$ROOT/build.gradle.kts"
)
for f in "${forbidden_files[@]}"; do
  if [[ -f "$f" ]]; then
    echo "FAIL: third-party/cross-platform dependency manifest found: $f"
    fail=1
  fi
done

# Native source may use Android/JDK platform APIs, but not external runtime
# libraries, cross-platform frameworks, or CDN/engine references.
while IFS= read -r -d '' f; do
  if grep -nE '(^|[[:space:]])import[[:space:]]+(androidx|com\.google|org\.jetbrains|io\.flutter|react|com\.facebook|com\.three|three\.js)|https?://|cdn\.|node_modules|mavenCentral|jcenter' "$f"; then
    echo "FAIL: prohibited runtime dependency/reference in $f"
    fail=1
  fi
done < <(find "$ROOT/src" -type f \( -name '*.java' -o -name '*.kt' \) -print0)

# No precompiled third-party libraries are allowed in the application tree.
while IFS= read -r -d '' f; do
  echo "FAIL: bundled binary library found: $f"
  fail=1
done < <(find "$ROOT" -type f \( -name '*.aar' -o -name '*.jar' -o -name '*.so' \) -print0)

if (( fail != 0 )); then
  echo "Allinmyday dependency audit: FAILED"
  exit 1
fi

echo "Allinmyday dependency audit: PASSED"
