package parser

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

// Helper function to compare JSON files
func compareJSONFiles(t *testing.T, got, want []byte, filename string) {
	gotMap := make(map[string]interface{})
	wantMap := make(map[string]interface{})

	if err := json.Unmarshal(got, &gotMap); err != nil {
		t.Errorf("Error unmarshaling got JSON: %v", err)
		return
	}

	if err := json.Unmarshal(want, &wantMap); err != nil {
		t.Errorf("Error unmarshaling want JSON: %v", err)
		return
	}

	if !reflect.DeepEqual(gotMap, wantMap) {
		t.Errorf("Output for %s does not match expected JSON\nGot: %s\nExpected: %s",
			filename, string(got), string(want))
	}
}

func TestParseChangelog(t *testing.T) {
	testDir := "../test/cases"
	files, err := os.ReadDir(testDir)
	if err != nil {
		t.Fatalf("Error reading test directory: %v", err)
	}

	for _, file := range files {
		if !strings.HasSuffix(file.Name(), ".md") {
			continue
		}

		inputPath := filepath.Join(testDir, file.Name())
		outputPath := filepath.Join(testDir, strings.ReplaceAll(strings.ReplaceAll(file.Name(), "input", "output"), ".md", ".json"))

		// Read input markdown
		markdown, err := os.ReadFile(inputPath)
		if err != nil {
			t.Errorf("Error reading %s: %v", inputPath, err)
			continue
		}

		// Parse changelog
		changelog, err := ParseChangelog(string(markdown))
		if err != nil {
			t.Errorf("Error parsing %s: %v", inputPath, err)
			continue
		}

		// Convert to JSON
		jsonBytes, err := changelog.ToJSON()
		if err != nil {
			t.Errorf("Error converting %s to JSON: %v", inputPath, err)
			continue
		}

		// Read expected output
		expectedJSON, err := os.ReadFile(outputPath)
		if err != nil {
			t.Errorf("Error reading %s: %v", outputPath, err)
			continue
		}

		// Compare JSON outputs
		compareJSONFiles(t, jsonBytes, expectedJSON, file.Name())
	}
}

func TestVersionFiltering(t *testing.T) {
	markdown := `# Changelog

## [Unreleased]
### Added
- New feature X
- New feature Y

## [1.0.0] - 2024-05-06
### Added
- Initial release
- Basic functionality

## [0.1.0] - 2024-04-25
### Added
- First prototype`

	changelog, err := ParseChangelog(markdown)
	if err != nil {
		t.Fatalf("Error parsing changelog: %v", err)
	}

	// Test cases
	testCases := []struct {
		name     string
		version  string
		expected int // expected number of versions
	}{
		{"Unreleased", "Unreleased", 1},
		{"unreleased", "unreleased", 1},
		{"UNRELEASED", "UNRELEASED", 1},
		{"Specific Version", "1.0.0", 1},
		{"Specific Version Lowercase", "1.0.0", 1},
		{"Non-existent Version", "2.0.0", 0},
		{"Empty Version", "", 3}, // should return all versions
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			filteredVersions := []Version{}
			if tc.version != "" {
				for _, v := range changelog.Versions {
					if strings.EqualFold(v.Version, tc.version) {
						filteredVersions = append(filteredVersions, v)
						break
					}
				}
			} else {
				filteredVersions = changelog.Versions
			}

			if len(filteredVersions) != tc.expected {
				t.Errorf("Expected %d versions for %s, got %d", tc.expected, tc.version, len(filteredVersions))
			}

			if tc.version != "" && len(filteredVersions) > 0 {
				if !strings.EqualFold(filteredVersions[0].Version, tc.version) {
					t.Errorf("Expected version %s, got %s", tc.version, filteredVersions[0].Version)
				}
			}
		})
	}
}
