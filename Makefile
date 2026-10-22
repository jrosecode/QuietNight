test:
	cargo test --manifest-path rust/quietnight-core/Cargo.toml
check:
	cargo fmt --manifest-path rust/quietnight-core/Cargo.toml --check
	cargo clippy --manifest-path rust/quietnight-core/Cargo.toml --all-targets -- -D warnings
project:
	xcodegen generate
