#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$SDK" ]]; then echo "ANDROID_HOME/ANDROID_SDK_ROOT is required"; exit 1; fi

PLATFORM="$(find "$SDK/platforms" -maxdepth 1 -type d -name 'android-*' | sort -V | tail -n 1)"
BUILD_TOOLS="$(find "$SDK/build-tools" -maxdepth 1 -type d -name '[0-9]*' | sort -V | tail -n 1)"
ANDROID_JAR="$PLATFORM/android.jar"
AAPT2="$BUILD_TOOLS/aapt2"
D8="$BUILD_TOOLS/d8"
ZIPALIGN="$BUILD_TOOLS/zipalign"
APKSIGNER="$BUILD_TOOLS/apksigner"

for f in "$ANDROID_JAR" "$AAPT2" "$D8" "$ZIPALIGN" "$APKSIGNER"; do
  [[ -f "$f" ]] || { echo "Missing Android SDK tool: $f"; exit 1; }
done

OUT="$ROOT/out"
rm -rf "$OUT"
mkdir -p "$OUT/classes" "$OUT/gen" "$OUT/res"

"$AAPT2" compile --dir "$ROOT/res" -o "$OUT/resources.zip"
"$AAPT2" link --manifest "$ROOT/AndroidManifest.xml" \
  -I "$ANDROID_JAR" \
  --java "$OUT/gen" \
  --auto-add-overlay \
  -o "$OUT/allinmyday-unsigned.apk" \
  "$OUT/resources.zip"

javac -source 8 -target 8 -classpath "$ANDROID_JAR" -d "$OUT/classes" \
  "$ROOT/src/com/allinmyday/MainActivity.java"

"$D8" --min-api 23 --lib "$ANDROID_JAR" --output "$OUT/dex" $(find "$OUT/classes" -name '*.class')

(cd "$OUT/dex" && zip -q "$OUT/allinmyday-unsigned.apk" classes.dex)
"$ZIPALIGN" -f 4 "$OUT/allinmyday-unsigned.apk" "$OUT/Allinmyday-trial-unaligned.apk"

KEYSTORE="$OUT/allinmyday-trial.jks"
keytool -genkeypair -keystore "$KEYSTORE" -storepass allinmyday -keypass allinmyday \
  -alias allinmyday -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Allinmyday, OU=Allinmyday, O=Allinmyday, C=IN" >/dev/null 2>&1

"$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:allinmyday --key-pass pass:allinmyday \
  --out "$OUT/Allinmyday-trial.apk" "$OUT/Allinmyday-trial-unaligned.apk"
"$APKSIGNER" verify --verbose "$OUT/Allinmyday-trial.apk"

echo "GREEN-CANDIDATE: $OUT/Allinmyday-trial.apk"
