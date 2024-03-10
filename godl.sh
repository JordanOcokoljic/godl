#!/usr/bin/env bash

set -eu

BLANK=''

godl::help()
{
  case "${1:-$BLANK}" in
    'get')
      cat << END
usage: godl get <version>

The get command will download the specified version of Go from
https://go.dev/dl/ and unpack it into /usr/local/go. If necessary the
.profile file will also have 'export PATH=\$PATH:/usr/local/go/bin'
appended to ensure that your shell can locate the install.
END
    ;;
    'purge')
      cat << END
usage: godl purge

The purge command will remove the installed version of Go.
END
    ;;
    *)
      cat << END
usage: godl <command> [<args>]

godl accepts the following commands:
help    Shows this menu.
get     Installs the specified version of Go.
purge   Removes an existing Go install.

See 'godl help <command>' to read about the specifics of how the
commands work and what side effects, if any, they have.
END
    ;;
  esac
}

godl::_go_is_installed_()
{
  [ -d '/usr/local/go' ]
}

godl::_remove_go_install_()
{
  sudo rm -rf '/usr/local/go'
}

godl::_append_to_profile_if_missing_()
{
  local line="$1"

  if grep -Fxq "$line" ~/.profile
  then
    :
  else
    echo "$line" >> ~/.profile
  fi
}

godl::_update_profile_()
{
  godl::_append_to_profile_if_missing_ 'export PATH=$PATH:/usr/local/go/bin'
  godl::_append_to_profile_if_missing_ 'if command -v go &> /dev/null; then export PATH="$PATH:$(go env GOPATH)/bin"; fi'
}

godl::get()
{
  local version="$1"

  if [[ -z "$version" ]]; then
    echo 'godl: no version provided'
    exit 1
  fi

  if godl::_go_is_installed_; then
    read -p 'Go is already installed, overwrite? (y/n): ' -n 1 choice
    echo

    case "$choice" in
      'Y'|'y')
        godl::_remove_go_install_
      ;;
      *)
        echo 'Cancelling install'
        return
      ;;
    esac
  fi

  mkdir -p ~/.godltmp
  
  if curl --fail -L "https://go.dev/dl/go$version.linux-amd64.tar.gz" -o ~/.godltmp/go.tar.gz
  then
    echo "Download complete"
  else
    echo "Error downloading go$version - please double check the version number, or try again later"
    exit 1
  fi

  if sudo tar -C '/usr/local' -xzf ~/.godltmp/go.tar.gz
  then
    echo "Unpack complete"
  else
    echo "Error unpacking Go archive"
    exit 1
  fi

  rm -r ~/.godltmp

  godl::_update_profile_

  echo "Go $version successfully installed. You may need to run 'source ~/.profile' to ensure that your PATH is updated"
}

godl::purge()
{
  if godl::_go_is_installed_;
  then
    :
  else
    echo 'Go is not currently installed'
    return
  fi

  read -p 'Are you sure you want to remove your Go install? (y/n) ' -n 1 choice
  echo

  case "$choice" in
    'Y'|'y') ;;
    *)
      echo 'No changes were made'
      return
    ;;
  esac

  godl::_remove_go_install_
}

godl::main()
{
  local command="${1:-$BLANK}"
  local argument="${2:-$BLANK}"

  case "$command" in
    'get')
      godl::get "$argument"
    ;;
    'purge')
      godl::purge
    ;;
    'help')
      godl::help "$argument"
    ;;
    '')
      godl::help
      exit 1
    ;;
    *)
      echo "godl: '$command' is not a godl command. See 'godl help'."
    ;;
  esac
}

godl::main "$@"
