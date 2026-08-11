BIN=cal

.PHONY: build run fmt

build:
	dart pub get
	mkdir -p bin
	dart compile exe bin/cal.dart -o bin/$(BIN)

run: build
	./bin/$(BIN)

fmt:
	dart format .
