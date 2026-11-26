#!/usr/bin/env bash
set -u

mkdir -p evidence
adb shell wm size 412x892 || exit 1
adb shell wm density 160 || exit 1
cd android || exit 1
./gradlew :app:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=hu.elizerpist.hajnal.StarterSmokeTest#nativePickerPersistenceAndNavigation --stacktrace > ../evidence/android-test.log 2>&1
result=$?
cat ../evidence/android-test.log
if [ "$result" -eq 0 ]; then
  adb shell am force-stop hu.elizerpist.hajnal || result=$?
fi
if [ "$result" -eq 0 ]; then
  adb shell am start -n hu.elizerpist.hajnal/.MainActivity || result=$?
fi
if [ "$result" -eq 0 ]; then
  ./gradlew :app:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=hu.elizerpist.hajnal.StarterSmokeTest#verifyRelaunch --stacktrace >> ../evidence/android-test.log 2>&1
  result=$?
  cat ../evidence/android-test.log
fi
adb exec-out run-as hu.elizerpist.hajnal cat files/onboarding.png > ../evidence/onboarding.png || true
adb exec-out run-as hu.elizerpist.hajnal cat files/dashboard-closed.png > ../evidence/dashboard-closed.png || true
adb exec-out run-as hu.elizerpist.hajnal cat files/dashboard-open.png > ../evidence/dashboard-open.png || true
if [ "$result" -eq 0 ]; then
  test -s ../evidence/onboarding.png && test -s ../evidence/dashboard-closed.png && test -s ../evidence/dashboard-open.png || result=1
fi
if [ "$result" -eq 0 ]; then
  cd .. || exit 1
  flutter test --no-pub integration_test/artwork_test.dart > evidence/artwork-test.log 2>&1
  result=$?
  cat evidence/artwork-test.log
fi
exit "$result"
