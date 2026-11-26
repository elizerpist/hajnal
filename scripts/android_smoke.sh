#!/usr/bin/env bash
set -u

mkdir -p evidence
adb shell wm size 412x892 || exit 1
adb shell wm density 160 || exit 1
cd android || exit 1
echo 'Running native picker and navigation test'
timeout 6m ./gradlew :app:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=hu.elizerpist.hajnal.StarterSmokeTest#nativePickerPersistenceAndNavigation --stacktrace 2>&1 | tee ../evidence/android-test.log
result=${PIPESTATUS[0]}
if [ "$result" -eq 0 ]; then
  adb shell am force-stop hu.elizerpist.hajnal || result=$?
fi
if [ "$result" -eq 0 ]; then
  adb shell am start -n hu.elizerpist.hajnal/.MainActivity || result=$?
fi
if [ "$result" -eq 0 ]; then
  echo 'Running force-stop and relaunch test'
  timeout 6m ./gradlew :app:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=hu.elizerpist.hajnal.StarterSmokeTest#verifyRelaunch --stacktrace 2>&1 | tee -a ../evidence/android-test.log
  result=${PIPESTATUS[0]}
fi
adb exec-out run-as hu.elizerpist.hajnal cat files/onboarding.png > ../evidence/onboarding.png || true
adb exec-out run-as hu.elizerpist.hajnal cat files/dashboard-closed.png > ../evidence/dashboard-closed.png || true
adb exec-out run-as hu.elizerpist.hajnal cat files/dashboard-open.png > ../evidence/dashboard-open.png || true
if [ "$result" -eq 0 ]; then
  test -s ../evidence/onboarding.png && test -s ../evidence/dashboard-closed.png && test -s ../evidence/dashboard-open.png || result=1
fi
if [ "$result" -eq 0 ]; then
  cd .. || exit 1
  echo 'Running artwork integration test'
  timeout 10m flutter test --no-pub integration_test/artwork_test.dart 2>&1 | tee evidence/artwork-test.log
  result=${PIPESTATUS[0]}
fi
exit "$result"
