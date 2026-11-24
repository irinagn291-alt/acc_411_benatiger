#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
run="$1"
shift
root="$(cd ../../artifacts/genesis/com.tigerbureau.luckytiger/motion-qa && pwd)"
evidence="$root/$run"
mkdir -p "$evidence"
ready=false
for attempt in 1 2 3; do
    printf 'Boot attempt %s\n' "$attempt" >> "$evidence/boot.log"
    if xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b >> "$evidence/boot.log" 2>&1 &&
       xcrun simctl getenv "$GF_SIMULATOR_UDID" HOME >> "$evidence/boot.log" 2>&1; then
        ready=true
        break
    fi
    sleep 3
done
if [[ "$ready" != true ]]; then
    cat "$evidence/boot.log"
    exit 1
fi
xcrun simctl status_bar "$GF_SIMULATOR_UDID" override --time "03:17" --dataNetwork wifi \
    --wifiMode active --wifiBars 3 --batteryState discharging --batteryLevel 100 >> "$evidence/boot.log" 2>&1 || true
python3 -c 'import time; print(time.time())' > "$evidence/record-start.txt"
xcrun simctl io "$GF_SIMULATOR_UDID" recordVideo --codec=h264 --force "$evidence/ui-run.mp4" > "$evidence/record.log" 2>&1 &
video_pid=$!
trap 'kill -INT "$video_pid" 2>/dev/null || true; wait "$video_pid" || true' EXIT
set +e
xcodebuild -project LuckyTiger.xcodeproj -scheme LuckyTiger -configuration Debug \
    -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO \
    -derivedDataPath "$root/build-$run" -resultBundlePath "$evidence/UI.xcresult" \
    ARCHS=arm64 CODE_SIGNING_ALLOWED=NO "$@" test 2>&1 | tee "$evidence/test.log"
result=${PIPESTATUS[0]}
set -e
kill -INT "$video_pid" 2>/dev/null || true
wait "$video_pid" || true
trap - EXIT
if container=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.tigerbureau.luckytiger data); then
    if [[ -f "$container/Documents/motion-cues.tsv" ]]; then
        cp "$container/Documents/motion-cues.tsv" "$evidence/motion-cues.tsv"
    fi
fi
if [[ -d "$evidence/UI.xcresult" ]]; then
    xcrun xcresulttool export attachments --path "$evidence/UI.xcresult" --output-path "$evidence/attachments"
fi
exit "$result"
