
# Requires GitHub PAT 
# Set up using: usethis::create_github_token()

library(gh)
library(purrr)
library(dplyr)

# Get organisation members

members <- 
  gh("GET /orgs/{org}/members",
     org = "ScotGovAnalysis",
     per_page = 100) |>
  map_chr(\(x) x$login)

# Get public emails for members

email_fn <- function(user) {
  gh("GET /users/{username}", username = user)$email
}

email <-
  members |>
  map_dfr(
    \(x) tibble(user = x, email = email_fn(x))
  )
  