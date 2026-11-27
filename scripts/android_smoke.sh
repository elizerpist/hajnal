#!/usr/bin/env bash
set -euo pipefail
adb_binary="$(type -P adb)"
adb() { timeout --kill-after=2s 30s "$adb_binary" "$@"; }
mkdir -p evidence
adb shell wm size 412x892
adb shell wm density 160
test_apk="$(find build/app/outputs/apk/androidTest -name '*.apk' -print -quit)"
test -n "$test_apk"
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb install -r -t "$test_apk"
capture_android_failure() {
  adb exec-out screencap -p > evidence/android-failure.png || true
  adb logcat -d -s 'flutter:*' 'AndroidRuntime:E' 'ActivityManager:I' > evidence/android-failure-logcat.txt || true
  adb shell uiautomator dump /sdcard/hajnal-failure.xml >/dev/null 2>&1 || true
  adb exec-out cat /sdcard/hajnal-failure.xml > evidence/android-failure-ui.xml || true
}
run_test() {
  local method="$1"
  local log="$2"
  if ! timeout 6m adb shell am instrument -w \
    -e class "hu.elizerpist.hajnal.StarterSmokeTest#$method" \
    hu.elizerpist.hajnal.test/androidx.test.runner.AndroidJUnitRunner | tee "$log" ||
    ! grep -Eq '^OK \(1 test\)' "$log"; then
    capture_android_failure
    return 1
  fi
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
run_test calendarDensity160 evidence/calendar-density160-test.log
adb exec-out run-as hu.elizerpist.hajnal cat files/calendar-density160.png > evidence/calendar-density160.png
python3 scripts/validate_png.py evidence/calendar-density160.png
adb shell wm size 618x1338
adb shell wm density 240
run_test calendarDensity240 evidence/calendar-density240-test.log
adb exec-out run-as hu.elizerpist.hajnal cat files/calendar-density240.png > evidence/calendar-density240.png
python3 scripts/validate_png.py evidence/calendar-density240.png
adb shell wm size 412x892
adb shell wm density 160
run_test appLockPinAndBackground evidence/lock-native-test.log
run_test launcherIcon evidence/lock-launcher-test.log
for name in onboarding dashboard-closed dashboard-open picker-open picker-night lock-real-setup lock-launcher; do
  adb exec-out run-as hu.elizerpist.hajnal cat "files/$name.png" > "evidence/$name.png"
  python3 scripts/validate_png.py "evidence/$name.png"
done
# Collect screenshots before flutter test removes the integration app.
# Platform authentication is simulated; the actual app widgets are rendered.
(timeout 5m flutter test --no-pub --no-dds integration_test/ci_integration_test.dart | tee evidence/artwork-test.log evidence/lock-visual-test.log) &
visual_pid=$!
ready=false
for attempt in $(seq 1 300); do
  if adb shell run-as hu.elizerpist.hajnal test -f files/lock-visual-ready 2>/dev/null; then
    ready=true
    break
  fi
  if ! kill -0 "$visual_pid" 2>/dev/null; then
    wait "$visual_pid" || true
    capture_android_failure
    exit 1
  fi
  sleep 1
done
if [ "$ready" != true ]; then
  kill "$visual_pid" 2>/dev/null || true
  wait "$visual_pid" || true
  capture_android_failure
  exit 1
fi
missing=false
for name in boarding-welcome-1 boarding-welcome-2 boarding-welcome-3 boarding-date boarding-motivation boarding-modules boarding-sponsor boarding-sponsor-expanded calendar-years calendar-months calendar-today-outline style-editor style-preview-card style-onboarding style-lock lock-settings lock-pin-setup lock-biometric-step; do
  if ! adb shell run-as hu.elizerpist.hajnal test -s "files/$name.png" ||
     ! adb exec-out run-as hu.elizerpist.hajnal cat "files/$name.png" > "evidence/$name.png" ||
     ! python3 scripts/validate_png.py "evidence/$name.png"; then
    echo "Missing or invalid screenshot: $name" >&2
    missing=true
  fi
done
adb shell run-as hu.elizerpist.hajnal touch files/lock-visual-copied
visual_result=0
wait "$visual_pid" || visual_result=$?
if [ "$visual_result" -ne 0 ] || [ "$missing" = true ]; then
  capture_android_failure
  exit 1
fi

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
