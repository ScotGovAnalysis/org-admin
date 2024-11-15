
# Requires GitHub PAT 
# Set up using: usethis::create_github_token()

library(gh)
library(purrr)
library(dplyr)

# Get all repositories in ScotGovAnalysis
all_repos <- 
  gh("GET /orgs/{org}/repos",
     org = "scotgovanalysis",
     .limit = Inf) %>%
  map_chr(\(x) x$name)

# Find all repositories with deployed GitHub Pages
all_pages_resp <- 
  all_repos %>%
  map(possibly(
    \(x) gh("GET /repos/ScotGovAnalysis/{repo}/pages/builds",
            repo = x)
  )) %>%
  compact()

# Function to extract name and owner of each Pages deployment
get_repo_info <- function(list) {
  
  repo <- unique(
    map_chr(
      list, 
      \(x) stringr::str_extract(x$url, "(?<=ScotGovAnalysis\\/)[A-Za-z_-]*")
    )
  )
  
  pusher <- unique(
    map_chr(
      list, 
      \(x) x$pusher$login
    )
  )
  
  tibble(repo_name = repo, pusher = list(pusher))
  
}

# Data frame of all pages deployments and owners
all_pages <- map_dfr(all_pages_resp, get_repo_info)

