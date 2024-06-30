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

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

TITLE="
\033[1;33m╭━━━╮╭╮\033[0m╱╱╱\033[1;33m╭╮╭╮\033[0m╱╱╱╱╱╱\033[1;37m╭━━━╮\033[0m╱╱╱\033[1;37m╭╮//////
\033[1;33m┃╭━╮┣╯╰╮\033[0m╱╱\033[1;33m┃┃┃┃\033[0m╱╱╱╱╱╱\033[1;37m┃╭━╮┃\033[0m╱╱╱\033[1;37m┃┃/////////
\033[1;33m┃╰━━╋╮╭╋━━┫┃┃┃╭━━┳━╮\033[1;37m┃┃\033[0m╱\033[1;37m╰╋╮\033[0m╱\033[1;37m╭┃╰━┳━━┳━┓/////////
\033[1;33m╰━━╮┃┃┃┃┃━┫┃┃┃┃╭╮┃╭╯\033[1;37m┃┃\033[0m╱\033[1;37m╭┫┃\033[0m╱\033[1;37m┃┃╭╮┃┃━┫╭╯//////
\033[1;33m┃╰━╯┃┃╰┫┃━┫╰┫╰┫╭╮┃┃\033[0m╱\033[1;37m┃╰━╯┃╰━╯┃╰╯┃┃━┫┃/////
\033[1;33m╰━━━╯╰━┻━━┻━┻━┻╯╰┻╯\033[0m╱\033[1;37m╰━━━┻━╮╭┻━━┻━━┻╯//
\033[0m//╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱\033[1;37m╭━╯┃\033[0m///////
   ╱╱╱╱╱╱/╱╱╱╱╱╱╱╱╱╱╱╱╱╱\033[1;37m╰━━╯\033[0m//
"

TOOLS_DIR="tools"
INFO_FILE="project.json"
REMOTE_INFO_URL="https://raw.githubusercontent.com/ash14545/StellarCyber-Scripts/main/project.json"

# Extract the version from project.json
VERSION=$(jq -r '.version' "$INFO_FILE")
remote_version=$(curl -s "$REMOTE_INFO_URL" | jq -r '.version')
VER_MSG="A new version ($remote_version) is available. You are currently using version ($VERSION)."

# Function to check for updates
check_updates() {
   if [ "$remote_version" != "$VERSION" ]; then
      read -p "A new version ($remote_version) is available. Do you want to download it? (y/n): " choice
      if [ "$choice" == "y" ]; then
         # Download the entire repository
         curl -L "https://github.com/ash14545/StellarCyber-Scripts/archive/main.tar.gz" | tar -xz --strip-components=1
         echo "Updated to version $remote_version. Please restart the script."
         exit 0
      fi
   else
      VER_MSG="You are using the latest version ($VERSION)"
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
      echo "$VER_MSG"
      echo ""

      # Set up options
      options_setup

      echo -e "\nh) Help"
      echo "q) Quit"
      echo "c) Clean up"
      echo ""

      read -p "Enter your choice: " choice flag

      # Defining help flag
      if [ "$flag" == "-h" ]; then
         case $choice in
         h)
            clear
            echo -e "$TITLE"
            echo -e "\nHelp Descriptions:\n"
            jq -r '.options[] | "\(.name): \(.description)"' "$INFO_FILE"
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         q)
            clear
            echo -e "$TITLE"
            echo -e "\nQuit Description:\n"
            echo "Quit the menu. This script will close."
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         c)
            clear
            echo -e "$TITLE"
            echo -e "\nClean Up Description:\n"
            echo "Clear all locally downloaded tools. Leaves it how you found it. No footprints!"
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         *)
            if [[ $choice =~ ^[0-9]+$ ]]; then
               local index=$((choice - 1))
               local script_name=$(jq -r --argjson index "$index" '.options[$index].name' "$INFO_FILE")
               local desc=$(jq -r --argjson index "$index" '.options[$index].description' "$INFO_FILE")

               if [ "$desc" != "null" ]; then
                  clear
                  echo -e "$TITLE"
                  echo -e "\n$script_name Description:\n"
                  echo -e "$desc\n"
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
            clear
            echo -e "$TITLE"
            echo -e "\nHelp Descriptions:\n"
            jq -r '.options[] | "\(.name): \(.description)"' "$INFO_FILE"
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
         q)
            echo "Goodbye!"
            read -n 1 -s -r -p "Press any key to continue..."
            clear
            exit 0
            ;;
         c)
            # cd ../ and delete the script directory
            clear
            echo -e "$TITLE"
            read -p "This will delete all Stellar Cyber master tool script files. Would you like to continue? (y/n): " choice
            if [ "$choice" == "y" ]; then
               echo -e "\nCleaning up in progress...\n"
               # execution begins here
               directory_name=$(pwd)
               cd ../
               rm -r "$directory_name"

               echo -e "\nClean up complete. The script will now quit..."
               echo ""
               read -n 1 -s -r -p "Press any key to continue..."
               exit 0
            else
               echo -e "\nNo files were deleted..."
               echo ""
               read -n 1 -s -r -p "Press any key to continue..."
            fi

            ;;
         *)
            # Check if the choice is a valid number
            if [[ $choice =~ ^[0-9]+$ ]]; then
               local index=$((choice - 1))
               local selected_script_url=$(jq -r --argjson index "$index" '.options[$index].url' "$INFO_FILE")
               local script_name=$(jq -r --argjson index "$index" '.options[$index].name' "$INFO_FILE")

               if [ "$selected_script_url" != "null" ]; then
                  local selected_script="$TOOLS_DIR/$(basename "$selected_script_url")"
                  echo "Running $script_name..."
                  curl -o "$selected_script" "$selected_script_url" -s
                  chmod +x "$selected_script"
                  echo ""
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