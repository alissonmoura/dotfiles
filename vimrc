""set relativenumber

call plug#begin('~/.vim/plugins')
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/grep.vim'
Plug 'dense-analysis/ale'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'ntpeters/vim-better-whitespace' " StripWhitespaces trailing
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf'

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

Plug 'fatih/molokai'
Plug 'altercation/vim-colors-solarized'
"Plug 'morhetz/gruvbox'
"Plug 'dracula/vim', { 'name': 'dracula' }

Plug 'SirVer/ultisnips'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Use release branch (recommend)
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"
Plug 'github/copilot.vim'
call plug#end()

set runtimepath^=~/.vim/bundle/ctrlp.vim

syntax on
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
set colorcolumn=100                                "display text width column
""set splitbelow                                     "vertical splits will be at the bottom
""set splitright                                     "horizontal splits will be to the right
set autoindent                                     "always set autoindenting on
set formatoptions-=cro                             "disable auto comments on new lines
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab "use two spaces for indentation
set incsearch                                      "incremental search highlight
set ignorecase                                     "searches are case insensitive...
set smartcase                                      " ..unless they contain at least one capital letter
set hlsearch                                       "highlight search patterns
set mouse=a
" Better command line completion
set wildmenu

if !has('nvim')
  set ttymouse=xterm2
endif

autocmd! FileType c    setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd! FileType java setlocal ts=4 sts=4 sw=4 expandtab
autocmd! FileType make setlocal ts=8 sts=8 sw=8 noexpandtab

"set t_Co=256                        "enable 256 colors
"set background=dark
"colorscheme gruvbox
"packadd! dracula
"syntax enable
"colorscheme dracula


let g:rehash256=1
let g:molokai_original=1
colorscheme molokai
"set background=light
"colorscheme solarized


"status line
set statusline=%=%m\ %c\ %P\ %f\    "modifiedflag, charcount, filepercent, filepath

"remove current line highlight in unfocused window
au VimEnter,WinEnter,BufWinEnter,FocusGained,CmdwinEnter * set cul
au WinLeave,FocusLost,CmdwinLeave * set nocul
"
"remove trailing whitespace on save
autocmd! BufWritePre * :%s/\s\+$//e

"The Leader
"nnoremap <SPACE> <Nop>
"let mapleader=" "
let mapleader=","

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


" go
" vim-go
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

let g:go_list_type = "quickfix"
"let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 1

let g:go_fmt_command="gopls"
let g:go_gopls_gofumpt=1

let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_autodetect_gopath = 1
let g:go_addtags_transform = "camelcase"
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_structs = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 1

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

augroup completion_preview_close
  autocmd!
  if v:version > 703 || v:version == 703 && has('patch598')
    autocmd CompleteDone * if !&previewwindow && &completeopt =~ 'preview' | silent! pclose | endif
  endif
augroup END

augroup go

  au!
  au Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  au Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
  au Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  au Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

  au FileType go nmap <Leader>dd <Plug>(go-def)
  au FileType go nmap <Leader>ss <Plug>(go-def-vertical)
  au FileType go nmap <Leader>dv <Plug>(go-doc-vertical)
  au FileType go nmap <Leader>db <Plug>(go-doc-browser)

  au FileType go nmap <leader>r  <Plug>(go-run)
  au FileType go nmap <leader>t  <Plug>(go-test)
  au FileType go nmap <leader>tf  <Plug>(go-test-func)
  au FileType go nmap <Leader>gt <Plug>(go-coverage-toggle)
  au FileType go nmap <Leader>i <Plug>(go-info)
  au FileType go nmap <Leader>gr <Plug>(go-rename)
  au FileType go nmap <silent> <Leader>l <Plug>(go-metalinter)
  au FileType go nmap <C-g> :GoDecls<cr>
  au FileType go nmap <leader>dr :GoDeclsDir<cr>
  au FileType go imap <C-g> <esc>:<C-u>GoDecls<cr>
  au FileType go imap <leader>dr <esc>:<C-u>GoDeclsDir<cr>
  au FileType go nmap <leader>rb :<C-u>call <SID>build_go_files()<CR>

  au filetype go inoremap <buffer> . .<C-x><C-o>

augroup END

""available linters
""'bingo', 'gobuild', 'gofmt', 'golangci-lint', 'golint', 'gometalinter', 'gopls', 'gosimple', 'gotype', 'govet', 'golangserver', 'staticcheck'
""not available
"", 'errcheck', 'stylecheck', 'goheader'
" ale
let g:ale_linters = {}
" ale
:call extend(g:ale_linters, {
    \"go": ['golint', 'go vet', 'gofmt', 'staticcheck', 'gosimple'], })

let g:go_metalinter_enabled = ['errcheck', 'stylecheck', 'goheader']

"""""" vim-go
"""""let g:go_def_mode='gopls'
"""""let g:go_info_mode='gopls'
"""""let g:go_autodetect_gopath = 1
"""""let g:go_addtags_transform = "camelcase"

"""""let g:go_fmt_command = "goimports"
"""""let g:go_list_type = "quickfix"
"""""let g:go_highlight_function_calls = 1
"""""
"""""let g:go_highlight_types = 1
"""""let g:go_highlight_fields = 1
"""""let g:go_highlight_functions = 1
"""""let g:go_highlight_extra_types = 1
"""""let g:go_highlight_generate_tags = 1
"""""let g:go_highlight_operators = 1
"""""
"""""
"""""let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
"""""let g:go_metalinter_autosave = 1
"""""autocmd FileType go nmap <Leader>i <Plug>(go-info)
"""""""let g:go_auto_sameids = 1

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


"""" fzf.vim
""set wildmode=list:longest,list:full
""set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
""let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

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

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  let g:CSApprox_loaded = 1

  " IndentLine
  let g:indentLine_enabled = 1
  let g:indentLine_concealcursor = ''
  let g:indentLine_char = '┆'
  let g:indentLine_faster = 1

  if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
  else
    if $TERM == 'xterm'
      set term=xterm-256color
    endif
  endif

endif

"*****************************************************************************
"" Autocmd Rules
"*****************************************************************************
"" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=200
augroup END
