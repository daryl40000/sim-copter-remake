#!/usr/bin/env bash
# Linux counterpart of RebuildUnrealCpp.bat. Pins the engine, the project, the
# editor target and -NoLiveCoding so a Live Coding session cannot leave a stale link.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$REPO_ROOT/SimCopterRemake/SimCopterRemake.uproject"
BUILD_TARGET="SimCopterRemakeEditor"
BUILD_CONFIG="Development"

if [[ "${1:-}" == "Shipping" ]]; then
	BUILD_TARGET="SimCopterRemake"
	BUILD_CONFIG="Shipping"
elif [[ -n "${1:-}" ]]; then
	echo "Usage: RebuildUnrealCpp.sh [Shipping]"
	echo "       UE_ROOT=/path/to/UnrealEngine ./RebuildUnrealCpp.sh"
	exit 1
fi

find_engine() {
	local candidate
	if [[ -n "${UE_ROOT:-}" ]]; then
		return 0
	fi
	for candidate in \
		"$HOME/Unreal Editor" \
		"$HOME/UnrealEngine" \
		"$HOME/UE_5.8" \
		"$HOME/UnrealEngine-5.8" \
		"$HOME/UnrealEngine/UE_5.8" \
		"/opt/UnrealEngine"
	do
		if [[ -x "$candidate/Engine/Build/BatchFiles/Linux/Build.sh" ]]; then
			UE_ROOT="$candidate"
			return 0
		fi
	done
	return 1
}

if ! find_engine; then
	echo "Unreal Engine 5.8 for Linux was not found."
	echo "Set UE_ROOT to the folder that contains Engine/, for example:"
	echo "  UE_ROOT=\"\$HOME/UnrealEngine\" ./RebuildUnrealCpp.sh"
	exit 1
fi

BUILD_SCRIPT="$UE_ROOT/Engine/Build/BatchFiles/Linux/Build.sh"
if [[ ! -x "$BUILD_SCRIPT" ]]; then
	echo "Unreal Build.sh was not found:"
	echo "  $BUILD_SCRIPT"
	exit 1
fi

if [[ ! -f "$PROJECT_FILE" ]]; then
	echo "Unreal project file was not found:"
	echo "  $PROJECT_FILE"
	exit 1
fi

echo "Engine:  $UE_ROOT"
echo "Target:  $BUILD_TARGET Linux $BUILD_CONFIG"

"$BUILD_SCRIPT" "$BUILD_TARGET" Linux "$BUILD_CONFIG" \
	-Project="$PROJECT_FILE" \
	-WaitMutex \
	-NoLiveCoding
