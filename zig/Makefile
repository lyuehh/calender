BIN=cal

.PHONY: build run fmt

build:
	mkdir -p bin
	zig build-exe src/main.zig -O ReleaseSafe -lc -femit-bin=bin/$(BIN)

run: build
	./bin/$(BIN)

fmt:
	zig fmt src/main.zig
