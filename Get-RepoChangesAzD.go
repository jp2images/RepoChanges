package main

import (
    "encoding/base64"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "strings"
    "time"
)

type Repository struct {
    Name string `json:"name"`
}

type Branch struct {
    Name string `json:"name"`
}

type Commit struct {
    CommitID string `json:"commitId"`
    Author   struct {
        Name string `json:"name"`
        Date string `json:"date"`
    } `json:"author"`
    Comment string `json:"comment"`
}

func main() {
    // Default parameters
    organization := "BeckhoffUS"
    project := "TunnelWash"
    days := 1
    patFilePath := os.Getenv("USERPROFILE") + `\.ssh\Beckhoff-AzD-pat.txt`

    // Read the Personal Access Token (PAT) from the file
    pat, err := ioutil.ReadFile(patFilePath)
    if err != nil {
        log.Fatalf("Error reading PAT file: %v", err)
    }

    // Base64 encode the PAT for authentication
    auth := base64.StdEncoding.EncodeToString([]byte(":" + strings.TrimSpace(string(pat))))

    // Calculate the date range
    untilDate := time.Now().Format(time.RFC3339)
    sinceDate := time.Now().AddDate(0, 0, -days).Format(time.RFC3339)

    fmt.Printf("Returning results between the dates: %s through Today: %s\n", sinceDate, untilDate)

    // Fetch repositories
    reposURL := fmt.Sprintf("https://dev.azure.com/%s/%s/_apis/git/repositories?api-version=6.0", organization, project)
    reposResponse := makeRequest(reposURL, auth)

    var reposData struct {
        Count int           `json:"count"`
        Value []Repository `json:"value"`
    }
    if err := json.Unmarshal(reposResponse, &reposData); err != nil {
        log.Fatalf("Error parsing repositories response: %v", err)
    }

    fmt.Printf("Azure DevOps REPOSITORY Count: %d\n", reposData.Count)

    // Iterate through repositories
    for i, repo := range reposData.Value {
        fmt.Printf("Repository %d: %s\n", i+1, repo.Name)

        // Fetch branches
        branchesURL := fmt.Sprintf("https://dev.azure.com/%s/%s/_apis/git/repositories/%s/refs?filter=heads/&api-version=6.0", organization, project, repo.Name)
        branchesResponse := makeRequest(branchesURL, auth)

        var branchesData struct {
            Count int      `json:"count"`
            Value []Branch `json:"value"`
        }
        if err := json.Unmarshal(branchesResponse, &branchesData); err != nil {
            log.Fatalf("Error parsing branches response: %v", err)
        }

        pluralBranch := "branch"
        if branchesData.Count > 1 {
            pluralBranch = "branches"
        }
        fmt.Printf("Repository %s has %d %s\n", repo.Name, branchesData.Count, pluralBranch)

        // Iterate through branches
        for _, branch := range branchesData.Value {
            branchName := strings.Replace(branch.Name, "refs/heads/", "", 1)
            commitsURL := fmt.Sprintf("https://dev.azure.com/%s/%s/_apis/git/repositories/%s/commits?searchCriteria.itemVersion.version=%s&searchCriteria.fromDate=%s&api-version=6.0", organization, project, repo.Name, branchName, sinceDate)
            commitsResponse := makeRequest(commitsURL, auth)

            var commitsData struct {
                Count int      `json:"count"`
                Value []Commit `json:"value"`
            }
            if err := json.Unmarshal(commitsResponse, &commitsData); err != nil {
                log.Fatalf("Error parsing commits response: %v", err)
            }

            if commitsData.Count > 0 {
                fmt.Printf("   From branch: %s\n", branchName)
                for _, commit := range commitsData.Value {
                    fmt.Printf("\tCommit ID: %s\n", commit.CommitID)
                    fmt.Printf("\tAuthor:    %s\n", commit.Author.Name)
                    fmt.Printf("\tDate:      %s\n", commit.Author.Date)
                    fmt.Printf("\tComment:   %s\n", commit.Comment)
                    fmt.Println("\t-----")
                }
            }
        }
    }

    fmt.Println("Azure DevOps check complete. ✔️")
}

func makeRequest(url, auth string) []byte {
    client := &http.Client{}
    req, err := http.NewRequest("GET", url, nil)
    if err != nil {
        log.Fatalf("Error creating request: %v", err)
    }
    req.Header.Add("Authorization", "Basic "+auth)

    resp, err := client.Do(req)
    if err != nil {
        log.Fatalf("Error making request: %v", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        log.Fatalf("Error: received status code %d from %s", resp.StatusCode, url)
    }

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        log.Fatalf("Error reading response body: %v", err)
    }

    return body
}