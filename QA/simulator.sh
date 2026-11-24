#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root="$PWD"
run="$1"
shift
derived="$root/QA/build-fullscreen"
test_action=test
if [[ "$run" == ipad ]]; then
    derived="$root/QA/build"
    test_action=test-without-building
elif [[ "$run" == ipad-fullscreen ]]; then
    set -- "$@" -only-testing:LuckyTigerUITests/BureauUITests/test03CampaignFromEmptyLedger
fi
mkdir -p "$root/QA/evidence/$run"
evidence="$root/QA/evidence/$run"
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b > "$evidence/boot.log" 2>&1
xcrun simctl status_bar "$GF_SIMULATOR_UDID" override --time "03:17" --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState discharging --batteryLevel 100
if [[ "${TIGER_RECORD:-0}" == 1 ]]; then
    date -u +%FT%TZ > "$evidence/record-start.txt"
    xcrun simctl io "$GF_SIMULATOR_UDID" recordVideo --codec=h264 --force "$evidence/ui-run.mp4" > "$evidence/record.log" 2>&1 &
    video_pid=$!
    trap 'kill -INT "$video_pid" 2>/dev/null || true; wait "$video_pid" || true' EXIT
fi
set +e
xcodebuild -project LuckyTiger.xcodeproj -scheme LuckyTiger -configuration Debug \
    -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO \
    -derivedDataPath "$derived" -resultBundlePath "$evidence/UI.xcresult" \
    ARCHS=arm64 CODE_SIGNING_ALLOWED=NO "$@" "$test_action" 2>&1 | tee "$evidence/test.log"
status=${PIPESTATUS[0]}
set -e
if [[ -d "$evidence/UI.xcresult" ]]; then
    if xcrun xcresulttool export attachments --path "$evidence/UI.xcresult" --output-path "$evidence/attachments"; then
        python3 "$root/QA/export-frames.py" "$evidence"
    fi
fi
exit "$status"
