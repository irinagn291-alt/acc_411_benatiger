#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
run="$1"
shift
root="$(cd ../../artifacts/genesis/com.tigerbureau.luckytiger/deduction-qa && pwd)"
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
set +e
xcodebuild -project LuckyTiger.xcodeproj -scheme LuckyTiger -configuration Debug \
    -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO \
    -derivedDataPath "$root/build-$run" -resultBundlePath "$evidence/UI.xcresult" \
    ARCHS=arm64 CODE_SIGNING_ALLOWED=NO "$@" test > "$evidence/test.log" 2>&1
result=$?
set -e
if [[ -d "$evidence/UI.xcresult" ]]; then
    xcrun xcresulttool get test-results summary --path "$evidence/UI.xcresult" > "$evidence/summary.json"
    xcrun xcresulttool export attachments --path "$evidence/UI.xcresult" --output-path "$evidence/attachments"
fi
tail -30 "$evidence/test.log"
exit "$result"
