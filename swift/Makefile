BIN=cal
SWIFTC=swiftc

.PHONY: build run fmt

build:
	mkdir -p bin .build/module-cache
	$(SWIFTC) -swift-version 6 -warnings-as-errors -O -module-cache-path .build/module-cache src/Calendar.swift src/main.swift -o bin/$(BIN)

run: build
	./bin/$(BIN)

fmt:
	swift format format --in-place --recursive src
