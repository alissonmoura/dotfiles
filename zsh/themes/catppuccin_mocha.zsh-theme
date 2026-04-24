# Catppuccin Mocha theme for Oh My Zsh.

ZSH_THEME_GIT_PROMPT_PREFIX="%F{246}on %F{111}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{203}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{151} clean%f"

PROMPT='%F{111}%n%f %F{246}in%f %F{183}%~%f $(git_prompt_info)
%(?.%F{151}.%F{203})>%f '
