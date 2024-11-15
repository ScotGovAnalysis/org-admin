# Analyse organisation members and outside collaborators
# Requires GitHub PAT. Set up using: usethis::create_github_token()

library(gh)
library(dplyr)
library(tidyr)

# 1 - Get tibble of members and outside collaborators ----

members <- 
  tibble(type = "org_member",
         member = gh("GET /orgs/{org}/members",
                     org = "ScotGovAnalysis",
                     per_page = 100)) %>%
  hoist(member, username = "login")

outside_colabs <- 
  tibble(type = "outside_colab",
         member = gh("GET /orgs/{org}/outside_collaborators",
                     org = "ScotGovAnalysis",
                     per_page = 100)) %>%
  hoist(member, username = "login")

all_users <- 
  bind_rows(members, outside_colabs) %>%
  rowwise() %>%
  mutate(public_info = list(gh("GET /users/{username}", 
                               username = username))) %>%
  ungroup() %>%
  hoist(public_info,
        name = "name",
        company = "company",
        email = "email")


# 2 - Summary of member type and whether email public ----

summary <- 
  all_users %>%
  group_by(type) %>%
  summarise(total = n(),
            email_available = sum(!is.na(email)),
            email_missing = sum(is.na(email)),
            .groups = "drop") 

summary


# 3 - Tibble of members to follow up ----

# Members of interest:
#  - SG staff who are outside collaborators
#  - Members with no public email address

follow_up <- 
  all_users %>%
  filter(type == "outside_colab" | is.na(email)) %>%
  select(type, username, email, name, company)


### END OF SCRIPT ###