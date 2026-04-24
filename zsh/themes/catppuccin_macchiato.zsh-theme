# Catppuccin Macchiato theme for Oh My Zsh.

ZSH_THEME_GIT_PROMPT_PREFIX="%F{252}on %F{147}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{210}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{157} clean%f"

PROMPT='%F{147}%n%f %F{251}in%f %F{111}%~%f $(git_prompt_info)
%(?.%F{157}.%F{210})>%f '
