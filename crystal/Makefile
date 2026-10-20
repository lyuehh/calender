BIN=cal

.PHONY: build run fmt

build:
	mkdir -p bin
	crystal build src/cal.cr -o bin/$(BIN) --release

run: build
	./bin/$(BIN)

fmt:
	crystal tool format src/cal.cr
