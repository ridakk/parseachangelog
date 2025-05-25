package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/ridakk/parseachangelog/parser"
)

var Version = "0.1.3" // This will be updated by the release process

func main() {
	inputFile := flag.String("input", "CHANGELOG.md", "Path to the changelog.md file")
	outputFile := flag.String("output", "", "Path to save the JSON output (default: stdout)")
	version := flag.String("version", "", "Optional: specific version to extract (e.g., '1.0.0' or 'Unreleased')")
	flag.Parse()

	// Read input file
	markdown, err := os.ReadFile(*inputFile)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		os.Exit(1)
	}

	// Parse changelog
	changelog, err := parser.ParseChangelog(string(markdown))
	if err != nil {
		fmt.Printf("Error parsing changelog: %v\n", err)
		os.Exit(1)
	}

	// Filter by version if specified
	if *version != "" {
		filteredVersions := []parser.Version{}
		for _, v := range changelog.Versions {
			if v.Version == *version {
				filteredVersions = append(filteredVersions, v)
				break
			}
		}
		changelog.Versions = filteredVersions
	}

	// Convert to JSON
	jsonBytes, err := changelog.ToJSON()
	if err != nil {
		fmt.Printf("Error converting to JSON: %v\n", err)
		os.Exit(1)
	}

	// Output to file or stdout
	if *outputFile != "" {
		err = os.WriteFile(*outputFile, jsonBytes, 0644)
		if err != nil {
			fmt.Printf("Error writing output file: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("JSON written to %s\n", *outputFile)
	} else {
		fmt.Println(string(jsonBytes))
	}
}
