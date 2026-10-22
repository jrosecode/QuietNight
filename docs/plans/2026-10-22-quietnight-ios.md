# QuietNight iOS Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Build an original privacy-first iOS snore tracker with a Rust analysis core and SwiftUI shell, specifically addressing recurring complaints about lost recordings, unclear pricing, false positives from partners/noise, inaccessible interfaces, and overconfident medical implications.

**Architecture:** SwiftUI owns iOS recording, playback, persistence, and UI. A dependency-free Rust crate performs deterministic signal feature extraction, adaptive baseline calibration, event classification, confidence scoring, and summary aggregation through a small C ABI. Data remains local; export is explicit. A Swift fallback analyzer keeps the sample app runnable before the Rust static library is linked.

**Tech Stack:** Rust 2021, Swift 5.9+, SwiftUI, AVFoundation, XCTest, Cargo tests, XcodeGen project specification.

---

### Task 1: Rust analysis contract

**Objective:** Implement deterministic frame analysis, adaptive calibration, event segmentation, confidence, and nightly summaries.

**Files:** `rust/quietnight-core/src/lib.rs`, `rust/quietnight-core/tests/analysis.rs`, `rust/quietnight-core/Cargo.toml`, `include/quietnight_core.h`

**TDD:** Add one failing behavior test at a time for silence, loud sustained periodic audio, transient rejection, partner/noise uncertainty, summary math, and invalid input; run the focused test before implementation, then the full Cargo suite.

### Task 2: iOS app shell and recording safety

**Objective:** Add a calm, accessible SwiftUI flow with preflight calibration, background-capable recording, crash-safe incremental session persistence, visible storage estimate, and recovery of interrupted sessions.

**Files:** `ios/QuietNight/**`, `project.yml`, `ios/QuietNightTests/**`

**TDD:** Test persistence/recovery and view-model state transitions before implementations. Use AVAudioRecorder with metering and write session metadata incrementally.

### Task 3: Timeline, playback, trends, experiments, and privacy

**Objective:** Display confidence-aware events on a timeline, allow playback/export/deletion, compare factors/remedies without implying causation, support VoiceOver/Dynamic Type, and explain local-only processing and medical limits.

**Files:** `ios/QuietNight/Features/**`, `ios/QuietNight/Resources/**`, `ios/QuietNightTests/**`

**TDD:** Test score formatting, trend comparison, filters, export manifest, and privacy/settings state before implementation.

### Task 4: Build integration and documentation

**Objective:** Add reproducible scripts for Rust iOS targets/XCFramework creation, XcodeGen setup, CI for Rust, architecture/product rationale, privacy policy, review evidence, and clear limitations.

**Files:** `scripts/**`, `.github/workflows/ci.yml`, `README.md`, `docs/**`, `LICENSE`

**Verification:** `cargo test --manifest-path rust/quietnight-core/Cargo.toml`, `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, project generation syntax checks, Swift source parse checks when full Xcode is available. Never claim an iOS build passed on a host without full Xcode.

### Task 5: Final review and publication

**Objective:** Review spec compliance, code quality, privacy, medical language, repository cleanliness, then publish to GitHub and verify the remote repository contents.

**Verification:** Clean git status, no secrets, remote README and commit SHA match local, repository is public, and all locally available checks pass.
