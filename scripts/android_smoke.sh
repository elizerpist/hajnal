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
for name in onboarding dashboard-closed dashboard-open; do
  adb exec-out run-as hu.elizerpist.hajnal cat "files/$name.png" > "evidence/$name.png"
  test -s "evidence/$name.png"
done
timeout 10m flutter test --no-pub integration_test/artwork_test.dart | tee evidence/artwork-test.log
# This emulator contains only test data. Remove the debug-signed package before
# testing the separately signed, normal profile APK and its upgrade path.
if adb shell pm path hu.elizerpist.hajnal | grep -q '^package:'; then
  adb uninstall hu.elizerpist.hajnal
fi
if adb shell pm path hu.elizerpist.hajnal.test | grep -q '^package:'; then
  adb uninstall hu.elizerpist.hajnal.test
fi
if [ -s "$RUNNER_TEMP/hajnal-previous.apk" ]; then
  install_apk="$RUNNER_TEMP/hajnal-previous.apk"
else
  install_apk=build/app/outputs/flutter-apk/app-profile.apk
fi
adb install -r "$install_apk"
adb install -r -t "$RUNNER_TEMP/hajnal-signed-test.apk"
run_test nativePickerPersistenceAndNavigation evidence/signed-before-upgrade.log
adb install -r build/app/outputs/flutter-apk/app-profile.apk
adb shell am force-stop hu.elizerpist.hajnal
run_test verifyRelaunch evidence/signed-after-upgrade.log
cat evidence/signed-before-upgrade.log evidence/signed-after-upgrade.log > evidence/signed-upgrade-test.log
