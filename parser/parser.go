package parser

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
)

// ChangeLog represents the entire changelog structure
type ChangeLog struct {
	Versions []Version `json:"versions"`
}

// Version represents a single version entry in the changelog
type Version struct {
	Version    string   `json:"version"`
	Date       string   `json:"date,omitempty"`
	Added      []string `json:"Added,omitempty"`
	Changed    []string `json:"Changed,omitempty"`
	Deprecated []string `json:"Deprecated,omitempty"`
	Removed    []string `json:"Removed,omitempty"`
	Fixed      []string `json:"Fixed,omitempty"`
	Security   []string `json:"Security,omitempty"`
}

// Change represents a single change entry
type Unreleased struct {
	Added   []string `json:"Added,omitempty"`
	Changed []string `json:"Changed,omitempty"`
	Fixed   []string `json:"Fixed,omitempty"`
	Removed []string `json:"Removed,omitempty"`
}

// ParseChangelog takes a markdown string and returns a ChangeLog struct
func ParseChangelog(markdown string) (*ChangeLog, error) {
	changelog := &ChangeLog{
		Versions: []Version{},
	}

	lines := strings.Split(markdown, "\n")
	currentVersion := ""
	currentSection := ""
	var currentVersionObj *Version

	for _, line := range lines {
		line = strings.TrimSpace(line)

		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "<!--") {
			continue
		}

		// Handle version headers
		if strings.HasPrefix(line, "## ") {
			parts := strings.Split(line[3:], " ")
			if len(parts) > 0 {
				version := strings.Trim(parts[0], "[]")
				currentVersion = version
				currentSection = ""

				date := ""
				if version != "Unreleased" && len(parts) > 1 {
					// First index is version, last index is date if different
					lastPart := parts[len(parts)-1]
					if lastPart != version {
						date = lastPart
					}
				}

				currentVersionObj = &Version{
					Version: version,
					Date:    date,
				}
				changelog.Versions = append(changelog.Versions, *currentVersionObj)
			}
			continue
		}

		// Handle section headers
		if strings.HasPrefix(line, "### ") {
			currentSection = strings.TrimSpace(line[4:])
			continue
		}

		// Handle list items
		if strings.HasPrefix(line, "- ") {
			item := strings.TrimSpace(line[2:])
			// Find the current version in the versions slice
			for i, v := range changelog.Versions {
				if v.Version == currentVersion {
					switch currentSection {
					case "Added":
						changelog.Versions[i].Added = append(changelog.Versions[i].Added, item)
					case "Changed":
						changelog.Versions[i].Changed = append(changelog.Versions[i].Changed, item)
					case "Deprecated":
						changelog.Versions[i].Deprecated = append(changelog.Versions[i].Deprecated, item)
					case "Removed":
						changelog.Versions[i].Removed = append(changelog.Versions[i].Removed, item)
					case "Fixed":
						changelog.Versions[i].Fixed = append(changelog.Versions[i].Fixed, item)
					case "Security":
						changelog.Versions[i].Security = append(changelog.Versions[i].Security, item)
					}
					break
				}
			}
		}
	}

	return changelog, nil
}

// ToJSON converts the changelog to JSON string
func (c *ChangeLog) ToJSON() ([]byte, error) {
	return json.MarshalIndent(c, "", "  ")
}

// PrintJSON prints the changelog in JSON format
func (c *ChangeLog) PrintJSON() {
	jsonBytes, err := c.ToJSON()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(jsonBytes))
}
