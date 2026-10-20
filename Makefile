LANGUAGES=go rust dart crystal zig moonbit swift

.PHONY: build test $(LANGUAGES)

build: $(LANGUAGES)

$(LANGUAGES):
	$(MAKE) -C $@ build

test: build
	$(MAKE) -C moonbit test
	python3 tests/conformance.py
