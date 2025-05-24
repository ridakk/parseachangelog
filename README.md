# parseachangelog

[![Go CI](https://github.com/ridakk/parseachangelog/actions/workflows/test.yml/badge.svg)](https://github.com/ridakk/parseachangelog/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/ridakk/parseachangelog/branch/main/graph/badge.svg)](https://codecov.io/gh/ridakk/parseachangelog)

> Replace <OWNER> and <REPO> with your GitHub username and repository name after pushing.
> For coverage badge, sign up at [Codecov](https://about.codecov.io/) and connect your repo.

A Go library and CLI tool for parsing [Keep a Changelog](https://keepachangelog.com/) markdown files into structured JSON format.

## Features

- Parses Keep a Changelog compliant markdown files
- Converts to structured JSON format
- Multi-platform support (macOS, Windows, Linux)
- Comprehensive test suite
- Simple and efficient parsing

## Installation

```bash
go get github.com/ridakk/parseachangelog
```

## Usage

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

# Parse a changelog file
./parseachangelog -input CHANGELOG.md -output changes.json
```

## JSON Output Format

```json
{
  "versions": [
    {
      "version": "1.0.0",
      "date": "2024-05-06",
      "Added": ["Initial release"],
      "Changed": [],
      "Deprecated": [],
      "Removed": [],
      "Fixed": [],
      "Security": []
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

MIT
