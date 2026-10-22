#!/usr/bin/env bash
set -euo pipefail
rustup target add aarch64-apple-ios aarch64-apple-ios-sim
cargo build --release --manifest-path rust/quietnight-core/Cargo.toml --target aarch64-apple-ios
cargo build --release --manifest-path rust/quietnight-core/Cargo.toml --target aarch64-apple-ios-sim
rm -rf build/QuietNightCore.xcframework
xcodebuild -create-xcframework -library target/aarch64-apple-ios/release/libquietnight_core.a -headers include -library target/aarch64-apple-ios-sim/release/libquietnight_core.a -headers include -output build/QuietNightCore.xcframework
