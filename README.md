# Parse a Changelog

A Go library and CLI tool for parsing Keep a Changelog markdown files into structured JSON format.

[![Go Report Card](https://goreportcard.com/badge/github.com/ridakk/parseachangelog)](https://goreportcard.com/report/github.com/ridakk/parseachangelog)
[![GoDoc](https://godoc.org/github.com/ridakk/parseachangelog?status.svg)](https://godoc.org/github.com/ridakk/parseachangelog)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test](https://github.com/ridakk/parseachangelog/actions/workflows/test.yml/badge.svg)](https://github.com/ridakk/parseachangelog/actions/workflows/test.yml)
[![Coverage](https://codecov.io/gh/ridakk/parseachangelog/branch/main/graph/badge.svg)](https://codecov.io/gh/ridakk/parseachangelog)

## Features

- Parses Keep a Changelog compliant markdown files
- Converts to structured JSON format
- Multi-platform support (macOS, Windows, Linux)
- Comprehensive test suite
- Simple and efficient parsing
- Filter by specific version or unreleased changes

## Installation

### Using Install Script (Recommended)

The easiest way to install `parseachangelog` is using the install script:

```bash
curl -sSfL https://raw.githubusercontent.com/ridakk/parseachangelog/main/install.sh | sh
```

This will:
1. Detect your OS and architecture
2. Download the appropriate binary
3. Install it to `/usr/local/bin`

#### Installation Options

You can customize the installation using environment variables:

```bash
# Install without modifying PATH
curl -sSfL https://raw.githubusercontent.com/ridakk/parseachangelog/main/install.sh | PARSEACHANGELOG_NO_MODIFY_PATH=1 sh

# Install with verbose output
curl -sSfL https://raw.githubusercontent.com/ridakk/parseachangelog/main/install.sh | INSTALLER_PRINT_VERBOSE=1 sh

# Install from GitHub Enterprise
curl -sSfL https://raw.githubusercontent.com/ridakk/parseachangelog/main/install.sh | PARSEACHANGELOG_INSTALLER_GHE_BASE_URL=https://github.your-enterprise.com sh
```

### Manual Installation

Download the latest release from the [releases page](https://github.com/ridakk/parseachangelog/releases) and extract the binary to your PATH.

### From Source

```bash
git clone https://github.com/ridakk/parseachangelog.git
cd parseachangelog
make build
```

### As a Library

```go
package main

import (
    "fmt"
    "github.com/ridakk/parseachangelog/parser"
)

func main() {
    markdown := `## [1.0.0] - 2024-05-06
### Added
- Initial release`

    changelog, err := parser.ParseChangelog(markdown)
    if err != nil {
        panic(err)
    }

    jsonBytes, err := changelog.ToJSON()
    if err != nil {
        panic(err)
    }
    fmt.Println(string(jsonBytes))
}
```

### As a CLI Tool

```bash
# Build for your platform
make build

# Parse entire changelog (defaults to CHANGELOG.md and outputs to stdout)
./parseachangelog

# Parse only unreleased changes
./parseachangelog -version Unreleased

# Parse a specific version
./parseachangelog -version 1.0.0

# Parse a custom changelog file
./parseachangelog -input custom-changelog.md

# Parse and save to a file
./parseachangelog -input CHANGELOG.md -output changes.json

# Combine options
./parseachangelog -input CHANGELOG.md -version 1.0.0 -output version.json
```

## JSON Output Format

```json
{
  "versions": [
    {
      "version": "Unreleased",
      "Added": [
        "New feature X",
        "New feature Y"
      ],
      "Changed": [
        "Bug A",
        "Bug B"
      ]
    },
    {
      "version": "1.0.0",
      "date": "2024-05-06",
      "Added": [
        "Initial release",
        "Basic functionality"
      ],
      "Fixed": [
        "Minor bug fixes"
      ]
    }
  ]
}
```

## Development

### Prerequisites
- Go 1.21 or later
- Make (for build commands)
- Docker (for running GitHub Actions locally)

### Build Commands
```bash
# Build for current platform
make build

# Build for all platforms
make build-all

# Run tests
make test

# Run linters
make lint

# Format code
make format
```

### Running GitHub Actions Locally

You can run GitHub Actions locally using [act](https://github.com/nektos/act). This is useful for testing workflows before pushing to GitHub.

1. Install act:
```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Windows
choco install act-cli
```

2. Run test workflows:
```bash
# Run test workflow
act -W .github/workflows/test.yml

# Run install test workflow
act -W .github/workflows/install-test.yml

# Run both workflows
act -W .github/workflows/test.yml -W .github/workflows/install-test.yml
```

3. Run with verbose output:
```bash
act -v
```

Note: Some workflows might require secrets or environment variables. You can provide these in `.env` and `.secrets` files.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
