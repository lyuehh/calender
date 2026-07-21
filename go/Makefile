BIN=cal

.PHONY: build run fmt

build:
	go build -o bin/$(BIN) ./cmd/cal

run: build
	./bin/$(BIN)

fmt:
	gofmt -w .
