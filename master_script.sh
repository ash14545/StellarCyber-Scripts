#!/bin/bash

# Check if jq is installed, if not, prompt to install
if ! command -v jq &>/dev/null; then
   read -p "jq is a required dependency that is currently not installed on your machine. Would you like to install it? (y/n): " choice
   if [ "$choice" == "y" ]; then
      if [[ "$(uname -s)" == "Linux" ]]; then
         sudo apt-get update
         sudo apt-get install -y jq
      elif [[ "$(uname -s)" == "Darwin" ]]; then
         brew install jq
      else
         echo "Unsupported OS. Please install jq manually."
         exit 1
      fi
   else
      echo "jq is not installed. Please install jq before running the script. This script will now exit."
      exit 0
   fi
fi

TITLE="
\033[1;33m╭━━━╮╭╮\033[0m╱╱╱\033[1;33m╭╮╭╮\033[0m╱╱╱╱╱╱\033[1;37m╭━━━╮\033[0m╱╱╱\033[1;37m╭╮//////
\033[1;33m┃╭━╮┣╯╰╮\033[0m╱╱\033[1;33m┃┃┃┃\033[0m╱╱╱╱╱╱\033[1;37m┃╭━╮┃\033[0m╱╱╱\033[1;37m┃┃/////////
\033[1;33m┃╰━━╋╮╭╋━━┫┃┃┃╭━━┳━╮\033[1;37m┃┃\033[0m╱\033[1;37m╰╋╮\033[0m╱\033[1;37m╭╰━┳━━┳━━┓/////////
\033[1;33m╰━━╮┃┃┃┃┃━┫┃┃┃┃╭╮┃╭╯\033[1;37m┃┃\033[0m╱\033[1;37m╭┫┃\033[0m╱\033[1;37m┃┃╭╮┃┃━┫╭╯//////
\033[1;33m┃╰━╯┃┃╰┫┃━┫╰┫╰┫╭╮┃┃\033[0m╱\033[1;37m┃╰━╯┃╰━╯┃╰╯┃┃━┫┃/////
\033[1;33m╰━━━╯╰━┻━━┻━┻━┻╯╰┻╯\033[0m╱\033[1;37m╰━━━┻━╮╭┻━━┻━━┻╯//
\033[0m╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱\033[1;37m╭━╯┃\033[0m///////
   ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱\033[1;37m╰━━╯\033[0m//
"

TOOLS_DIR="tools"
INFO_FILE="project.json"
REMOTE_INFO_URL="https://raw.githubusercontent.com/ash14545/StellarCyber-Scripts/main/project.json"

# Extract the version from project.json
VERSION=$(jq -r '.version' "$INFO_FILE")

# Function to check for updates
check_updates() {
   local remote_version=$(curl -s "$REMOTE_INFO_URL" | jq -r '.version')
   if [ "$remote_version" != "$VERSION" ]; then
      read -p "A new version ($remote_version) is available. Do you want to download it? (y/n): " choice
      if [ "$choice" == "y" ]; then
         # Download the entire repository
         curl -L "https://github.com/ash14545/StellarCyber-Scripts/archive/main.tar.gz" | tar -xz
         echo "Updated to version $remote_version. Please restart the script."
         exit 0
      fi
   else
      echo "You are using the latest version ($VERSION)."
   fi
}

# Function to download and set up option scripts
options_setup() {
   # Create the tools directory if it doesn't exist
   mkdir -p "$TOOLS_DIR"

   # Initialize counter
   local count=1

   # Download options from project.json and list them with index numbers
   jq -r '.options[] | "\(.name): \(.description)"' "$INFO_FILE" | while IFS=":" read -r name desc; do
      echo "$count) $name"
      ((count++))
   done
}

# Display main menu
master_menu() {
   while true; do
      clear
      echo -e "$TITLE"
      echo -e "\nThis is the Stellar Cyber master tool script."
      echo ""

      # Set up options
      options_setup

      echo -e "\nh) Help"
      echo "q) Quit"

      read -p "Enter your choice: " choice flag

      # Defining help flag
      if [ "$flag" == "-h" ]; then
         case $choice in
         h)
            echo -e "\nHelp Descriptions:\n"
            jq -r '.options[] | "\(.name): \(.description)"' "$INFO_FILE"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         q)
            echo "Quit the menu. This script will close."
            ;;
         *)
            if [[ $choice =~ ^[0-9]+$ ]]; then
               local index=$((choice - 1))
               local desc=$(jq -r --argjson index "$index" '.options[$index].description' "$INFO_FILE")

               if [ "$desc" != "null" ]; then
                  echo -e "\nHelp for Option $choice: $desc\n"
               else
                  echo "Invalid choice, please select a valid option."
               fi
            else
               echo "Invalid choice, please select a valid option."
            fi
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         esac

      # Defining options
      else
         case $choice in
         h)
            echo -e "\nHelp Descriptions:\n"
            jq -r '.options[] | "\(.name): \(.description)"' "$INFO_FILE"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         q)
            echo "Goodbye!"
            read -n 1 -s -r -p "Press any key to continue..."
            clear
            exit 0
            ;;
         *)
            # Check if the choice is a valid number
            if [[ $choice =~ ^[0-9]+$ ]]; then
               local index=$((choice - 1))
               local selected_script_url=$(jq -r --argjson index "$index" '.options[$index].url' "$INFO_FILE")

               if [ "$selected_script_url" != "null" ]; then
                  local selected_script="$TOOLS_DIR/$(basename "$selected_script_url")"
                  curl -o "$selected_script" "$selected_script_url"
                  chmod +x "$selected_script"
                  ./"$selected_script"
                  read -n 1 -s -r -p "Press any key to continue..."
               else
                  echo "Invalid choice, please select a valid option."
                  read -n 1 -s -r -p "Press any key to continue..."
               fi
            else
               echo "Invalid choice, please select a valid option."
               read -n 1 -s -r -p "Press any key to continue..."
            fi
            ;;
         esac
      fi
   done
}

# Check for updates
check_updates

# Display main menu
master_menu
