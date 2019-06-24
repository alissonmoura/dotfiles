set relativenumber

call plug#begin('~/.vim/plugins')
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'morhetz/gruvbox'
call plug#end()

set ttyfast                                        "more characters will be sent to the screen for redrawing
set ttimeout                                       "time waited for key press(es) to complete...
set ttimeoutlen=50                                 " ...makes for a faster key response
set nobackup                                       "disable backup and swap files
set noswapfile
set autoread                                       "automatically read changes in the file
set hidden                                         "hide buffers instead of closing them even if they contain unwritten changes
set backspace=indent,eol,start                     "make backspace behave properly in insert mode
set clipboard=unnamedplus                          "requires has('unnamedplus') to be 1
set wildmenu                                       "better menu with completion in command mode
set wildmode=longest:full,full
set completeopt=longest,menuone,preview            "better insert mode completions
set nowrap                                         "disable soft wrap for lines
set scrolloff=2                                    "always show 2 lines above/below the cursor
set showcmd                                        "display incomplete commands
set laststatus=2                                   "always display the status bar
set number                                         "display line numbers
set cursorline                                     "highlight current line
set colorcolumn=81                                 "display text width column
set splitbelow                                     "vertical splits will be at the bottom
set splitright                                     "horizontal splits will be to the right
set autoindent                                     "always set autoindenting on
set formatoptions-=cro                             "disable auto comments on new lines
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab "use two spaces for indentation
set incsearch                                      "incremental search highlight
set ignorecase                                     "searches are case insensitive...
set smartcase                                      " ..unless they contain at least one capital letter
set hlsearch                                       "highlight search patterns

autocmd! FileType c    setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd! FileType java setlocal ts=4 sts=4 sw=4 expandtab
autocmd! FileType make setlocal ts=8 sts=8 sw=8 noexpandtab

set t_Co=256                        "enable 256 colors
set background=dark
colorscheme gruvbox

"status line
set statusline=%=%m\ %c\ %P\ %f\    "modifiedflag, charcount, filepercent, filepath

"remove current line highlight in unfocused window
au VimEnter,WinEnter,BufWinEnter,FocusGained,CmdwinEnter * set cul
au WinLeave,FocusLost,CmdwinLeave * set nocul
"
"remove trailing whitespace on save
autocmd! BufWritePre * :%s/\s\+$//e

"The Leader
let mapleader="\<Space>"

nnoremap ! :!
nnoremap <leader>w :w<cr>
"replace the word under cursor
nnoremap <leader>* :%s/\<<c-r><c-w>\>//<left>
"toggle showing hidden characters
nnoremap <silent> <leader>s :set nolist!<cr>
"remove search highlight
nmap <leader>q :nohlsearch<CR>

"move lines around
nnoremap <leader>k :m-2<cr>==
nnoremap <leader>j :m+<cr>==
xnoremap <leader>k :m-2<cr>gv=gv
xnoremap <leader>j :m'>+<cr>gv=gv


"Ctags
set tags+=.git/tags
nnoremap <leader>ct :!ctags --tag-relative --extra=+f -Rf .git/tags --exclude=.git,pkg --languages=-javascript,sql<cr><cr>

"netrw
let g:netrw_banner=0
let g:netrw_winsize=20
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'
nnoremap <leader>n :Lexplore<CR>

"move to the window in the direction shown, or create a new window
nnoremap <silent> <C-h> :call WinMove('h')<cr>
nnoremap <silent> <C-j> :call WinMove('j')<cr>
nnoremap <silent> <C-k> :call WinMove('k')<cr>
nnoremap <silent> <C-l> :call WinMove('l')<cr>
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr())
    if (match(a:key,'[jk]'))
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction
