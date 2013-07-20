#!/bin/bash

DOTFILES_PATH=$(dirname $0)
DOTFILES_PATH=$(cd "$DOTFILES_PATH" && pwd)

OLD_DOTFILES_PATH=~/.old.dotfiles/

for dotfile_path in $DOTFILES_PATH/.[a-zA-Z]*; do
    if [[ "$dotfile_path" == "$DOTFILES_PATH/.git" ]]; then
        continue
    fi

    file_name=$(basename $dotfile_path)

    home_path=~/${file_name}

    if [[ -e "${home_path}" && ! ( -L "${home_path}" ) ]]; then
        mkdir -p "${OLD_DOTFILES_PATH}"
        mv "${home_path}" "${OLD_DOTFILES_PATH}${file_name}"
    elif [[ -L "${home_path}" ]]; then
        rm "${home_path}"
    fi

    echo "Linking ${dotfile_path/#$HOME/~} -> ${home_path/#$HOME/~}"
    ln -s "${dotfile_path}" "${home_path}"
done
