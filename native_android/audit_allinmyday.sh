#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Allinmyday application-layer dependency gate.
# Android platform APIs and JDK tools are allowed; third-party application
# libraries/frameworks/engines/CDNs are not.
FORBIDDEN='flutter|react-native|react|three\.js|threejs|cdn|androidx|com\.google|org\.jetbrains|implementation[[:space:]]*\(|api[[:space:]]*\(|maven|npm|yarn|node_modules|cocoapods'

if grep -RInE --exclude='audit_allinmyday.sh' --exclude='DEPENDENCY_POLICY.md' "$FORBIDDEN" "$ROOT"; then
  echo "FAIL: forbidden third-party/runtime dependency reference found in native Allinmyday source."
  exit 1
fi

if find "$ROOT" -type f \( -name '*.aar' -o -name '*.jar' -o -name '*.so' \) | grep -q .; then
  echo "FAIL: bundled binary library found in native Allinmyday source."
  find "$ROOT" -type f \( -name '*.aar' -o -name '*.jar' -o -name '*.so' \)
  exit 1
fi

echo "PASS: Allinmyday native application layer contains no detected third-party runtime library, engine or CDN reference."
