#!/bin/bash

# Base directory for projects
BASE_DIR="$HOME/Projects"

# Set the Array for Project/s
PROJECTS=()

# Set Session Name 
SESSION_NAME="Dev"

# Function to display usage
usage() {
    echo "Usage: $0 [-s|--session session_name] project1 [project2]"
    echo "  -s SESSION_NAME   Specify a custom session name (optional)."
    exit 1
}

# Parse all arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -s|--session)
      if [[ -n "$2" ]]; then
          SESSION_NAME="$2"
          shift 2
      else
          echo "Error: -s flag requires a session name." >&2
          usage
      fi
      ;;
  -*)
      echo "Unknown flag: $1" >&2
      usage
      ;;
  *)
      PROJECTS+=("$1")
      shift
      ;;
  esac
done

# Check remaining arguments (project names)
if [ ${#PROJECTS[@]} -lt 1 ]; then
    usage
fi

# Validate project directories
for project in "${PROJECTS[@]}"; do
    dir="$BASE_DIR/$project"
    if [ ! -d "$dir" ]; then
        echo "Project directory '$dir' does not exist."
        exit 1
    fi
done

# Check if TMUX session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Attaching to existing session '$SESSION_NAME'"
  tmux switch-client -t "$SESSION_NAME"
else
  if [ ${#PROJECTS[@]} -eq 2 ]; then
    # Create a new TMUX session
    echo "Creating new session '$SESSION_NAME'"
    tmux new-session -d -s $SESSION_NAME -c "$BASE_DIR/${PROJECTS[0]}" -n "Frontend"

    # In the 'Frontend' window, run NVIM
    tmux send-keys -t $SESSION_NAME:1 "nvim package.json" C-m
    tmux send-keys -t $SESSION_NAME:1 "\\"

    # In the 'Backend' window, run NVIM
    tmux new-window -t $SESSION_NAME:2 -c "$BASE_DIR/${PROJECTS[1]}" -n "Backend"
    tmux send-keys -t $SESSION_NAME:2 "nvim package.json" C-m
    tmux send-keys -t $SESSION_NAME:2 "\\"

    # Create the second window for 'Term'
    tmux new-window -t $SESSION_NAME:3 -c "$BASE_DIR/${PROJECTS[0]}" -n "Term"
    tmux send-keys -t $SESSION_NAME:3 "npm run dev"
    tmux split-window -t $SESSION_NAME:3 -h -c "$BASE_DIR/${PROJECTS[1]}"
    tmux send-keys -t $SESSION_NAME:3 "npm run dev"
  
    # Create the third window for 'Git'
    tmux new-window -t $SESSION_NAME:4 -c "$BASE_DIR/${PROJECTS[0]}" -n "Git"
    tmux send-keys -t $SESSION_NAME:4 "pglog -n 5" C-m
    tmux send-keys -t $SESSION_NAME:4 "git status" C-m
    tmux split-window -t $SESSION_NAME:4 -h -c "$BASE_DIR/${PROJECTS[1]}"
    tmux send-keys -t $SESSION_NAME:4 "pglog -n 5" C-m
    tmux send-keys -t $SESSION_NAME:4 "git status" C-m
  
    # Make sure the session gets attached properly
    tmux select-window -t $SESSION_NAME:1
    tmux switch-client -t $SESSION_NAME
  else
    # Create a new TMUX session
    echo "Creating new session '$SESSION_NAME'"
    tmux new-session -d -s $SESSION_NAME -c "$BASE_DIR/${PROJECTS[0]}" -n "Workspace"
  
    # In the 'Workspace' window, run NVIM
    tmux send-keys -t $SESSION_NAME:1 "nvim package.json" C-m
    tmux send-keys -t $SESSION_NAME:1 "\\"
  
    # Create the second window for 'Term'
    tmux new-window -t $SESSION_NAME:2 -c "$BASE_DIR/${PROJECTS[0]}" -n "Term"
    tmux send-keys -t $SESSION_NAME:2 "npm run dev"
  
    # Create the third window for 'Git'
    tmux new-window -t $SESSION_NAME:3 -c "$BASE_DIR/${PROJECTS[0]}" -n "Git"
    tmux send-keys -t $SESSION_NAME:3 "pglog -n 5" C-m
    tmux send-keys -t $SESSION_NAME:3 "git status" C-m
  
    # Make sure the session gets attached properly
    tmux select-window -t $SESSION_NAME:1
    tmux switch-client -t $SESSION_NAME
  fi
fi

# Check if session '0' exists and kill it
if tmux has-session -t 0 2>/dev/null; then
  echo "Closing existing session '0'"
  tmux kill-session -t 0
fi
