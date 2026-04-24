#!/bin/sh

background=$1

echo $background


# Determine mode
if [ "$background" = "dark" ]; then
   # Vim
   echo "colorscheme molokai" > /home/$USER/.vimrc.color

   # Update terminal emulator
   kitty +kitten themes --reload-in=all "Dracula"
   # Vim watches ~/.vimrc.color and reloads itself
else
   # Vim
   echo "set background=$background" > /home/$USER/.vimrc.color
   echo "colorscheme solarized" >> /home/$USER/.vimrc.color

   # Update terminal emulator
   kitty +kitten themes --reload-in=all "Solarized Light"
   # Vim watches ~/.vimrc.color and reloads itself
fi

#   echo "set background=$background" > ~/.vimrc.color


