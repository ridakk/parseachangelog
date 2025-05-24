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
