#!/bin/bash

# Download install scripts
curl -H 'Authorization: token <generated_token>' -H 'Accept: application/vnd.github.v3.raw' -L https://api.github.com/repos/<github_username>/<github_repo_name>/contents/setup_arch.sh?ref=<repo_branch_name> -o setup_arch.sh
