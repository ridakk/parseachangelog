.PHONY: test lint format coverage debug build run build-all clean

# Run tests with coverage
coverage:
	go test -v -coverprofile=coverage.txt -covermode=atomic ./...
	go tool cover -html=coverage.txt -o coverage.html

test:
	go test -v ./...

# Run linters (optional)
lint:
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found, skipping linting"; \
	fi

# Format code
format:
	go fmt ./...

# Build the binary
debug:
	go build -gcflags="all=-N -l" -o parseachangelog ./main.go

# Build release binary for current platform
build:
	go build -o parseachangelog .

# Build for all platforms
build-all:
	@echo "Building for all platforms..."
	@mkdir -p dist
	GOOS=darwin GOARCH=amd64 go build -o dist/parseachangelog_darwin_amd64 ./main.go
	GOOS=darwin GOARCH=arm64 go build -o dist/parseachangelog_darwin_arm64 ./main.go
	GOOS=windows GOARCH=amd64 go build -o dist/parseachangelog_windows_amd64.exe ./main.go
	GOOS=linux GOARCH=amd64 go build -o dist/parseachangelog_linux_amd64 ./main.go
	GOOS=linux GOARCH=arm64 go build -o dist/parseachangelog_linux_arm64 ./main.go
	@echo "Build complete. Binaries are in the dist directory."

# Clean build artifacts
clean:
	rm -rf dist/
	rm -f parseachangelog
	rm -f parseachangelog.exe
	rm -f keep-changelog-parser

# Run with debug binary
run:
	./parseachangelog -input test/cases/input1.md -output test.json

test-all: format test coverage
	@echo "All checks passed!"
