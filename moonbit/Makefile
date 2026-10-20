BIN=cal

.PHONY: build run fmt test

build:
	moon build --target native --release
	mkdir -p bin
	cp _build/native/release/build/cmd/main/main.exe bin/$(BIN)

run: build
	./bin/$(BIN)

fmt:
	moon fmt

test:
	moon test --target native
