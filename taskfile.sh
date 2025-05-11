#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Attempting to install Taskfile..."

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl first."
    echo "On Debian/Ubuntu: sudo apt update && sudo apt install curl"
    echo "On Fedora: sudo dnf install curl"
    echo "On macOS (with Homebrew): brew install curl"
    exit 1
fi

# Define the installation directory and binary path
INSTALL_DIR="/usr/local/bin"
TASK_BINARY="$INSTALL_DIR/task"

# Run the official Taskfile installation script
echo "Running the official Taskfile installer to install to $INSTALL_DIR..."
# Ensure the target directory exists and is writable, or use sudo if necessary.
# The official script handles sudo if needed for the default /usr/local/bin
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b "$INSTALL_DIR"

echo ""
echo "Taskfile installation script finished."
echo "-------------------------------------------------------------------"
echo "To verify the installation, try running:"
echo "  $TASK_BINARY --version"
echo ""
echo "If '$INSTALL_DIR' is not in your PATH, you might need to add it."
echo "You can typically do this by adding the following to your shell profile"
echo "(e.g., ~/.bashrc, ~/.zshrc, ~/.profile):"
echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
echo "Then, source your profile (e.g., source ~/.bashrc) or open a new terminal."
echo "-------------------------------------------------------------------"
echo ""

# Autocompletion setup
read -p "Do you want to attempt to set up shell autocompletion for Taskfile? (y/N): " choice
case "$choice" in
  y|Y )
    echo "Setting up autocompletion..."

    # Determine the shell
    CURRENT_SHELL=""
    if [ -n "$BASH_VERSION" ]; then
        CURRENT_SHELL="bash"
    elif [ -n "$ZSH_VERSION" ]; then
        CURRENT_SHELL="zsh"
    elif [ -n "$FISH_VERSION" ]; then # Fish sets $FISH_VERSION
        CURRENT_SHELL="fish"
    else
        # Fallback by checking the SHELL environment variable
        SHELL_PATH=$(ps -p $$ -o comm=) # Get current process name
        if [[ "$SHELL_PATH" == *"bash"* ]]; then
            CURRENT_SHELL="bash"
        elif [[ "$SHELL_PATH" == *"zsh"* ]]; then
            CURRENT_SHELL="zsh"
        elif [[ "$SHELL_PATH" == *"fish"* ]]; then
            CURRENT_SHELL="fish"
        else
            echo "Could not automatically determine your shell or it's not Bash, Zsh, or Fish."
            echo "You can try to generate completion script manually using:"
            echo "  $TASK_BINARY --completion <your-shell-name>"
            echo "And follow the instructions for your specific shell."
            exit 0
        fi
    fi

    echo "Detected shell: $CURRENT_SHELL"

    if ! command -v "$TASK_BINARY" &> /dev/null; then
        echo "Error: '$TASK_BINARY' command not found. This might be a PATH issue."
        echo "Please ensure '$INSTALL_DIR' is in your PATH and try setting up completion manually:"
        echo "  $TASK_BINARY --completion $CURRENT_SHELL"
        exit 1
    fi

    case "$CURRENT_SHELL" in
      bash)
        COMPLETION_DIR_BASH_USER="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
        COMPLETION_FILE_BASH="$COMPLETION_DIR_BASH_USER/task"
        mkdir -p "$COMPLETION_DIR_BASH_USER"
        echo "Generating Bash completion script to $COMPLETION_FILE_BASH..."
        "$TASK_BINARY" --completion bash > "$COMPLETION_FILE_BASH"
        echo ""
        echo "Bash completion script installed!"
        echo "Please ensure you have the 'bash-completion' package installed on your system."
        echo "(e.g., 'sudo apt install bash-completion' or 'brew install bash-completion@2')"
        echo "Then, source your ~/.bashrc or open a new terminal session for changes to take effect."
        echo "If it doesn't work, you might need to add:"
        echo "  source $COMPLETION_FILE_BASH"
        echo "to your ~/.bashrc file."
        ;;
      zsh)
        # Suggest a common user-owned directory for Zsh completions
        COMPLETION_DIR_ZSH="$HOME/.zsh/completion"
        COMPLETION_FILE_ZSH="$COMPLETION_DIR_ZSH/_task"
        mkdir -p "$COMPLETION_DIR_ZSH"
        echo "Generating Zsh completion script to $COMPLETION_FILE_ZSH..."
        "$TASK_BINARY" --completion zsh > "$COMPLETION_FILE_ZSH"
        echo ""
        echo "Zsh completion script installed!"
        echo "To enable it, add the following to your ~/.zshrc file if not already present:"
        echo "  fpath=($COMPLETION_DIR_ZSH \$fpath)"
        echo "  autoload -U compinit && compinit"
        echo "Then, restart your Zsh session or run 'source ~/.zshrc'."
        ;;
      fish)
        COMPLETION_DIR_FISH="$HOME/.config/fish/completions"
        COMPLETION_FILE_FISH="$COMPLETION_DIR_FISH/task.fish"
        mkdir -p "$COMPLETION_DIR_FISH"
        echo "Generating Fish completion script to $COMPLETION_FILE_FISH..."
        "$TASK_BINARY" --completion fish > "$COMPLETION_FILE_FISH"
        echo ""
        echo "Fish completion script installed!"
        echo "Fish should automatically pick up the completion. If not, try restarting your Fish session."
        ;;
      *)
        echo "Autocompletion setup for '$CURRENT_SHELL' is not automatically handled by this script."
        echo "You can generate the completion script using:"
        echo "  $TASK_BINARY --completion $CURRENT_SHELL"
        echo "And then follow the specific instructions for your shell to install it."
        ;;
    esac
    echo "Autocompletion setup finished."
    ;;
  * )
    echo "Skipping autocompletion setup."
    ;;
esac

echo "-------------------------------------------------------------------"
echo "Taskfile installation and setup complete."
