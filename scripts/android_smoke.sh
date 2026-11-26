#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
adb shell wm size 412x892
adb shell wm density 160
test_apk="$(find build/app/outputs/apk/androidTest -name '*.apk' -print -quit)"
test -n "$test_apk"
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb install -r -t "$test_apk"
run_test() {
  local method="$1"
  local log="$2"
  timeout 6m adb shell am instrument -w \
    -e class "hu.elizerpist.hajnal.StarterSmokeTest#$method" \
    hu.elizerpist.hajnal.test/androidx.test.runner.AndroidJUnitRunner | tee "$log"
  grep -Eq '^OK \(1 test\)' "$log"
}
run_test nativePickerPersistenceAndNavigation evidence/android-first-test.log
adb shell am force-stop hu.elizerpist.hajnal
adb shell am start -n hu.elizerpist.hajnal/.MainActivity
run_test verifyRelaunch evidence/android-relaunch-test.log
cat evidence/android-first-test.log evidence/android-relaunch-test.log > evidence/android-test.log
adb shell cmd uimode night yes
adb shell am force-stop hu.elizerpist.hajnal
run_test nightPicker evidence/android-night-test.log
adb shell cmd uimode night no
run_test appLockPinAndBackground evidence/lock-native-test.log
run_test launcherIcon evidence/lock-launcher-test.log
for name in onboarding dashboard-closed dashboard-open picker-open picker-night lock-real-setup lock-launcher; do
  adb exec-out run-as hu.elizerpist.hajnal cat "files/$name.png" > "evidence/$name.png"
  python3 scripts/validate_png.py "evidence/$name.png"
done
# Collect screenshots before flutter test removes the integration app.
# Platform authentication is simulated; the actual app widgets are rendered.
(timeout 10m flutter test --no-pub integration_test/ci_integration_test.dart | tee evidence/artwork-test.log evidence/lock-visual-test.log) &
visual_pid=$!
ready=false
for attempt in $(seq 1 600); do
  if adb shell run-as hu.elizerpist.hajnal test -f files/lock-visual-ready 2>/dev/null; then
    ready=true
    break
  fi
  if ! kill -0 "$visual_pid" 2>/dev/null; then
    wait "$visual_pid"
    exit 1
  fi
  sleep 1
done
if [ "$ready" != true ]; then
  kill "$visual_pid" 2>/dev/null || true
  wait "$visual_pid" || true
  exit 1
fi
for name in lock-settings lock-pin-setup lock-biometric-step; do
  adb exec-out run-as hu.elizerpist.hajnal cat "files/$name.png" > "evidence/$name.png"
  python3 scripts/validate_png.py "evidence/$name.png"
done
adb shell run-as hu.elizerpist.hajnal touch files/lock-visual-copied
wait "$visual_pid"

# This emulator contains only test data. Remove the debug-signed package before
# testing the separately signed, normal profile APK and its upgrade path.
if adb shell pm path hu.elizerpist.hajnal | grep -q '^package:'; then
  adb uninstall hu.elizerpist.hajnal
fi
if adb shell pm path hu.elizerpist.hajnal.test | grep -q '^package:'; then
  adb uninstall hu.elizerpist.hajnal.test
fi
test -s "$RUNNER_TEMP/hajnal-previous.apk"
adb install -r "$RUNNER_TEMP/hajnal-previous.apk"
adb install -r -t "$RUNNER_TEMP/hajnal-signed-test.apk"
run_test prepareUpgrade evidence/signed-before-upgrade.log
adb exec-out cat /sdcard/Android/data/hu.elizerpist.hajnal/files/picker-before-upgrade.png > evidence/picker-before-upgrade.png
adb exec-out cat /sdcard/Android/data/hu.elizerpist.hajnal/files/picker-before-upgrade-theme.txt > evidence/picker-before-upgrade-theme.txt
adb install -r build/app/outputs/flutter-apk/app-profile.apk
adb shell am force-stop hu.elizerpist.hajnal
run_test verifyUpgradeAndCorrect evidence/signed-after-upgrade.log
adb exec-out cat /sdcard/Android/data/hu.elizerpist.hajnal/files/picker-after-upgrade.png > evidence/picker-after-upgrade.png
adb exec-out cat /sdcard/Android/data/hu.elizerpist.hajnal/files/picker-after-upgrade-theme.txt > evidence/picker-after-upgrade-theme.txt
adb shell am force-stop hu.elizerpist.hajnal
run_test verifyCorrectedRelaunch evidence/signed-relaunch.log
cat evidence/signed-before-upgrade.log evidence/signed-after-upgrade.log evidence/signed-relaunch.log > evidence/signed-upgrade-test.log
