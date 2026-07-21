BIN=cal

.PHONY: build run fmt

build:
	cargo build --release
	mkdir -p bin
	cp target/release/$(BIN) bin/$(BIN)

run: build
	./bin/$(BIN)

fmt:
	cargo fmt
