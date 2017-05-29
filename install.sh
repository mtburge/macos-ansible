#!/bin/sh

user="${USER}"
repo="https://github.com/itsmattburgess/macos-ansible.git"

# Text formatting
bold=$(tput bold)
normal=$(tput sgr0)

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

echo() {
  printf "$1\n"
}

confirm() {
    read -r -p "${1}" response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Last chance to change your mind
if ! confirm "Are you sure you wish to provision this machine? [Y/n]: "; then
  exit
fi

# Exit if the scripts run into any errors
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
set -e

# Ensure Apple's command line tools are installed
if ! command -v cc >/dev/null; then
  echo "${bold}XCode:${normal} Installing..."
  xcode-select --install
else
  echo "${bold}XCode:${normal} Skipping, already installed."
fi

# Install Homebrew
if ! command -v brew >/dev/null; then
  echo "${bold}Homebrew:${normal} Installing..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
else
  echo "${bold}Homebrew:${normal} Skipping, already installed."
fi

# Install Ansible (http://docs.ansible.com/intro_installation.html).
if ! command -v ansible >/dev/null; then
  echo "${bold}Ansible:${normal} Installing..."
  brew install ansible
else
  echo "${bold}Ansible:${normal} Skipping, already installed."
fi

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Download and install the dotfiles
if [ -d "${HOME}/.dotfiles" ]; then
  echo "${bold}Dotfiles:${normal} Skipping, already installed."
else
  echo "${bold}Dotfiles:${normal} Installing..."
  git clone https://github.com/itsmattburgess/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles/bin && ./install
fi

# Clone the repository to your local drive.
if [ -d "${HOME}/.macos-ansible" ]; then
  echo "${bold}Playbook:${normal} Skipping, already downloaded."
else
  echo "${bold}Playbook:${normal} Cloning..."
  git clone $repo $HOME/.macos-ansible
fi

# Move to the install directory
cd $HOME/.macos-ansible

echo "${bold}Ansible:${normal} Installing roles..."
ansible-galaxy install -r requirements.yml

echo "${bold}Running ansible playbook for user ${user}...${normal}"
ansible-playbook playbook.yml -e install_user=${user} -i hosts --ask-become-pass
