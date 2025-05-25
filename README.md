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

# Parse a changelog file (defaults to CHANGELOG.md and outputs to stdout)
./parseachangelog

# Parse a custom changelog file
./parseachangelog -input custom-changelog.md

# Parse and save to a file
./parseachangelog -input CHANGELOG.md -output changes.json
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
