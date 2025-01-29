#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error: $1"
  exit 1
}


# Check if the required environment variables are set
if [[ -z "$GH_USER" || -z "$GH_PAT" ]]; then
  handle_error "GitHub username (GH_USER) and/or GitHub Personal Access Token (GH_PAT) are not set."
fi
FILENAME="python_3.13.0_$(date +%Y%m%d%H%M%S).nupkg"
GITHUB_REPO="action-ai-institute"
GITHUB_FEED_URL="https://nuget.pkg.github.com/$GITHUB_REPO/index.json"

# Check if the system is Debian GNU/Linux 11
if grep -q "Debian GNU/Linux 11" /etc/issue; then
  echo "Bootstrapping the Linux environment"
  echo "Installing .NET SDK"

  # Download and install the .NET SDK for Debian 11
  wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb

  # Update package list and install the .NET SDK
  sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
  
  
  wget https://www.nuget.org/api/v2/package/python/3.13.0 -O $FILENAME

  
  # Check if GitHub NuGet source already exists
  if !  dotnet nuget list source | grep -q "github"; then
    # Add the GitHub Packages NuGet source if it doesn't exist
    dotnet nuget add source $GITHUB_FEED_URL --name github --username $GH_USER --password $GH_PAT --store-password-in-clear-text || handle_error "Failed to add GitHub NuGet source"
    echo "Successfully added GitHub NuGet source"
  else
    echo "GitHub NuGet source already exists, skipping."
  fi
  
  dotnet nuget push $FILENAME --source github --api-key $GH_PAT --skip-duplicate
else
  echo "This script is designed to run on Debian GNU/Linux 11. Skipping installation."
fi
