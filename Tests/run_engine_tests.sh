#!/bin/sh
# Compila y corre las pruebas del WorkoutEngine en macOS.
set -e
cd "$(dirname "$0")/.."
OUT="${TMPDIR:-/tmp}/watchfittime-enginetests"
xcrun swiftc -o "$OUT" \
    WatchFitTime/Model/WorkoutEngine.swift \
    WatchFitTime/Model/TimeFormatting.swift \
    Tests/EngineTests/main.swift
"$OUT"
