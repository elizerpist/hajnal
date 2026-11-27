#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
python3 scripts/test_release_tools.py
python3 scripts/test_release_candidate.py
python3 scripts/test_failed_evidence.py
python3 scripts/test_android_failure_evidence.py
python3 scripts/test_welcome_svg.py
dart format --output=none --set-exit-if-changed lib test integration_test scripts/calendar_dst_check.dart
flutter analyze --no-pub
TZ=Europe/Budapest dart run scripts/calendar_dst_check.dart
flutter test --no-pub --reporter expanded | tee evidence/flutter-test.log
dart run build_runner build
git diff --exit-code -- lib/core/database/hajnal_database.g.dart
mkdir -p "$RUNNER_TEMP/hajnal-schema"
dart run drift_dev schema dump lib/core/database/hajnal_database.dart "$RUNNER_TEMP/hajnal-schema/"
diff -u drift_schemas/drift_schema_v4.json "$RUNNER_TEMP/hajnal-schema/drift_schema_v4.json"
