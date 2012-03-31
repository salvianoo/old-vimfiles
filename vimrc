" Load Pathogen {{{
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
set nocompatible                " no legacy vi
"}}}

" Basic Options {{{
syntax on                       " turn on syntax highlighting

set encoding=utf-8
set noswapfile
set modelines=0                 " security fix
set hidden                      " allow switching edited buffers without saving
set history=100
set number
set ruler                       " show the cursor position all
set showcmd                     " show current mode down the bottom
set autoindent                  " automatic indent new lines
set smartindent                 " be smart about it
" set nofoldenable
set shell=/bin/bash
"}}}

" Text Formatting {{{

set nowrap                      " do not wrap lines
set textwidth=80
set colorcolumn=+1              " this will highlight column 80
set formatoptions=qrn1
set scrolloff=3
set ttyfast
set softtabstop=2               " yep, two
set shiftwidth=2
set expandtab                   " use spaces, not tabs
set backspace=indent,eol,start  " backspace though everthing in insert mode
set splitbelow
" }}}

" UI {{{
set laststatus=2                " always show the status line
set visualbell                  " stop annoying bells
set cursorline                  " highlight cursor line
set list
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮,trail:·,nbsp:·
" }}}

" Font settings
set t_Co=256
set guifont=Menlo\ Regular\ for\ Powerline:h12

" Searching Settings {{{
set hlsearch                    " highlight matches
set incsearch                   " do incremental searching
set showmatch
set ignorecase                  " ignore case when searching...
set smartcase                   " only if they contain at least one capital letter
set gdefault
"}}}

" Basically this makes terminal Vim work sanely
set notimeout
set ttimeout
set ttimeoutlen=50

" Wildmenu Completion {{{
set wildmenu                        " enable ctrl-n and ctrl-p to scroll thur matches
set wildmode=list:longest

set wildignore+=.git                " Version control
set wildignore+=*.aux,*.out,*.toc   " LaTeX intermediate files
set wildignore+=*.DS_Store          " OSX bullshit
"}}}

colorscheme solarized
let g:solarized_visibility='low'

" Powerline fancy symbols
let g:Powerline_symbols = 'fancy'

" set background=dark
set background=light

if has("autocmd")
  filetype on                       " file type detection
  filetype plugin indent on
  " set ofu=syntaxcomplete#Complete

  " styles depending on file type
  au filetype html set omnifunc=htmlcomplete#CompleteTags
  au filetype css set omnifunc=csscomplete#CompleteCSS
  au filetype ruby setlocal ts=2 sts=2 sw=2 expandtab
  au filetype java setlocal ts=4 sts=4 sw=4 expandtab
  au filetype javascript setlocal ts=4 sts=4 sw=4 expandtab
  au filetype python setlocal ts=4 sts=4 sw=4 expandtab

  autocmd BufWritePre *.java,*.yml,*.rb,*.html,*.css,*.erb :call <sid>StripTrailingWhitespaces()

endif

" Folding ----------------------------------------------------------------- {{{

set foldlevelstart=0

set foldmethod=marker
" set foldnestmax=3
" set foldlevelstart=0

" Space to toggle folds
nnoremap <Space> za
vnoremap <Space> za

nnoremap zO zCzO

function! MyFoldText() " {{{
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3

    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let livpjune = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . "…" . ' '
endfunction
set foldtext=MyFoldText() " }}}

" }}}

"Keep search matches in the middle of the window and pulse the line when moving
"to them.
nnoremap n nzzzv
nnoremap N Nzzzv

" As seen on Vimcasts
"
function! <sid>StripTrailingWhitespaces()
  " preparation save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  %s/\s\+$//e
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" my first vimscript function
function! <sid>BackgroundToggle()
  if &background == "dark"
    set background=light
  else
    set background=dark
  endif
endfunction

"--TODO--
function! <sid>ShowDate()
  return system('date')
endfunction

" Remapping {{{

" Use comma as <leader> key instead of backslash
let mapleader=","
let maplocalleader="\\"

" Easier navigation betwen split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Quick Editing {{{

noremap <leader>ev <C-w>v<C-w>j:e ~/.vim/vimrc<cr>
noremap <leader>ep <C-w>v<C-w>j:e ~/.pentadactylrc<cr>
noremap <leader>et <C-w>v<C-w>j:e ~/.tmux.conf<cr>
noremap <leader>eb <C-w>v<C-w>j:e ~/.bash<cr> 
" }}}

" }}}

" double percentage sign in command mode is expanded
" to directory of current file - http://vimcasts.org/e/14
cnoremap %% <c-r>=expand('%:h').'/'<cr>

" CommandT {{{

map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>
map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>gg :topleft 25 :split Gemfile<cr>

let g:CommandTMaxHeight=12
" let g:CommandTMatchWindowAtTop=1

"}}}

" Function ShowRoutes
" thanks @garybernhardt
function! ShowRoutes()
  " Requires 'scratch plugin
  :topleft 50 :split __Routes__
  " Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
  " Delete everything
  :normal 1GdG
  " Put routes output in buffer
  :0r! rake -s routes
  " Size window to number of lines (1 plus rake output length)
  :exec ":normal " . line("$") . "_ "
  " Move cursor to bottom
  :normal 1GG
  " Delete empty trailing line
  :normal dd
endfunction
map <leader>gR :call ShowRoutes()<cr>

"faster shorcut for commenting. requires tComment
map <leader>c <c-_><c-_>

"shortuct for editing vimrc file in a new
" nmap ,ev :tabedit ~/.vim/vimrc<cr>

" As see on vimcast about edit command
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%

" Easier navigation betwen split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Switch between the currently open buffer and the previous one
nnoremap <leader><leader> <c-^>

" Space is so much easier than :
noremap ; :

" Easily move to start/end of line:
noremap H ^
noremap L g_

" Emacs binding in command line mode
cnoremap <c-a> <home>
cnoremap <c-e> <end>

"key mapping for tab navigation

" Map hashrocket as textmate
imap <c-l> <space>=><space>

"make <c-l> clear the highlight as well as redraw
nnoremap <leader><space> :nohls<cr>

inoremap jj <esc>

"I like that
nnoremap <localleader>= ==
vnoremap - =

nnoremap <leader>W :call <sid>StripTrailingWhitespaces()<cr>
nnoremap <leader>B :call <sid>BackgroundToggle()<cr>

"--TODO
" nnoremap <leader>Y :call <sid>ShowDate()<cr>

" NERDTree {{{
let NERDTreeHighlightCursorline=1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

au FileType nerdtree setlocal nolist
noremap <c-o> :NERDTreeToggle<cr>
" }}}

" YankRing
nnoremap <c-y> :YRShow<CR>

" Ack
noremap <leader>a :Ack

"normal mode
nnoremap <tab> %
"visual mode
vnoremap <tab> %

inoremap <c-space> <c-x><c-u>

" Send visual selection to gist.github.com as a private, filetyped Gist
" Requires the gist command line too (brew install gist)
vnoremap <leader>G :w !gist -t %:e \| pbcopy<cr>
vnoremap <leader>UG :w !gist -p \| pbcopy<cr>

" Fugitive {{{
noremap <leader>gd :Gdiff<cr>
noremap <leader>gs :Gstatus<cr>
noremap <leader>gb :Gblame<cr>

augroup ft_fugitive
  au!
  au BufNewFile,BufRead .git/index setlocal nolist
augroup END
" }}}

" Guard
augroup ft_guard
  au!
  au BufRead,BufNewFile Guardfile set ft=ruby
augroup END

" augroup cline
"   au!
"   au WinLeave * set nocursorline
"   au WinEnter * set cursorline
"   au InsertEnter * set nocursorline
"   au InsertLeave * set cursorline
" augroup END

"MiniBufExplorer
" let g:miniBufExplForceSyntaxEnable = 1

if has("gui_macvim")
  " Remove all the UI cruft
  " go is same of guioptions
  set go-=T
  set go-=l
  set go-=L
  set go-=r
  set go-=R

  " GUI
  au GUIEnter * set fullscreen

endif

" Resize split when the window is resized
au VimResized * exe "normal! \<c-w>="

" Window rezising
nnoremap <c-left> 5<c-w>>
nnoremap <c-right> 5<c-w><

"it's 2012"
noremap j gj
noremap k gk

noremap vv ^vg_
" Better Completion
set completeopt=menu,preview,longest

" Plugin for syntax of treetop files
set runtimepath+=~/.vim/plugin/treetop.vim

" tSlime plugin {{{
let g:tslime_ensure_trailing_newlines = 1
let g:tslime_normal_mapping = '<localleader>t'
let g:tslime_visual_mapping = '<localleader>t'
let g:tslime_vars_mapping = '<localleader>T'
"}}}

" Syntastic {{{
let g:syntastic_enable_signs = 1
let g:syntastic_check_on_open = 1
let g:syntastic_stl_format = '[%E{%e Errors}%B{, }%W{%w Warnings}]'
"}}}

" Substitute
noremap <leader>s :%s//<left>

" TMUX {{{
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" }}}

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Keep the cursor in place while joining lines
nnoremap J mzJ`z
