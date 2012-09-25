"  /===================================================\
"  | Vimfiles by Salviano Ludgério                     |
"  | - http://twitter.com/salvianoo                    |
"  | Many tricks were stolen from Steve Losh dotfiles  |
"  | - http://github.com/sjl/dotfiles                  |
"  \===================================================/

" Load Plugins {{{
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin indent on
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
set nofoldenable
set shell=/bin/bash
set laststatus=2                " always show the status line
set visualbell                  " stop annoying bells
set cursorline                  " highlight cursor line
set list

set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮,nbsp:·

"}}}

" Text Formatting {{{
set nowrap                      " do not wrap lines
set textwidth=80
set formatoptions=qrn1
set scrolloff=3
set ttyfast
set softtabstop=2               " yep, two
set shiftwidth=2
set expandtab                   " use spaces, not tabs
set backspace=indent,eol,start  " backspace though everthing in insert mode
set splitbelow
" set colorcolumn=+1             " this will highlight column 80

" Font Settings
set t_Co=256
set guifont=Menlo\ Regular\ for\ Powerline:h16
" set guifont=Inconsolata-dz\ for\ Powerline:h12
" }}}

" Searching Settings {{{
set hlsearch                    " highlight matches
set incsearch                   " do incremental searching
set showmatch
set ignorecase                  " ignore case when searching...
set smartcase                   " only if they contain at least one capital letter
set gdefault

" Basically this makes terminal Vim work sanely
set notimeout
set ttimeout
set ttimeoutlen=50
"}}}

" Wildmenu Completion {{{
set wildmenu                        " enable ctrl-n and ctrl-p to scroll thur matches
set wildmode=list:longest

set wildignore+=.git                " Version control
set wildignore+=*.aux,*.out,*.toc   " LaTeX intermediate files
set wildignore+=*.DS_Store          " OSX bullshit

set wildignore+=*.pyc               " Python bytecode

set wildignore+=*.class             " Java bytecode

" Clojure/Leiningen
" set wildignore+=classes
" set wildignore+=lib
"}}}

" Line Return {{{

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit and Steve Losh for this tip
augroup line_return
  au!

  au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \     execute 'normal! g`"zvzz' |
      \ endif
augroup END
" }}}

" Filetype-specific ---------------------------------------------------------------- {{{

" Ruby {{{
augroup ft_ruby
  au!

  au Filetype ruby setlocal ts=2 sts=2 sw=2 expandtab
augroup END
" }}}

" Python {{{
augroup ft_python
  au!

  au Filetype python setlocal ts=4 sts=4 sw=4 expandtab
  au FileType python setlocal define=^\s*\\(def\\\\|class\\)
  au FileType python compiler nose
  au FileType man nnoremap <buffer> <cr> :q<cr>
augroup END
"}}}

" Django {{{
augroup ft_django
  au!

  au BufNewFile,BufRead urls.py   setlocal nowrap
  au BufNewFile,BufRead urls.py   normal! zR
augroup END
"}}}

" Javascript {{{
augroup ft_javascript
  au!

  au Filetype javascript setlocal foldmethod=marker
  au Filetype javascript setlocal foldmarker={,}
  au Filetype javascript setlocal ts=4 sts=4 sw=4 expandtab

  au FileType javascript inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END
" }}}

" CSS, SCSS and Less {{{
augroup ft_css
  au!

  au BufNewFile,BufRead *.less setlocal filetype=less
  au BufNewFile,BufRead *.scss setlocal filetype=scss

  au FileType css,scss,less setlocal foldmethod=marker
  au FileType css,scss,less setlocal foldmarker={,}
  au Filetype css,scss,less set omnifunc=csscomplete#CompleteCSS
  " search wtf this line do
  au FileType css,scss,less setlocal iskeyword+=-

  " Use <localleader>v to sort properties. Turns this:

  "     p {
  "         width: 200px;
  "         height: 100px;
  "         background: red;

  "         ...
  "     }
  "
  "into this:
  "
  "     p {
  "         background: red;
  "         height: 100px;
  "         width: 200px;
  "
  "
  "         ...
  "     }
  au FileType *.css,*.scss,*.less noremap <buffer> <localleader>v ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

  " Make {<cr> insert a pair of brackets in such a way that the cursor is
  " correctly positioned inside of them AND the following code doesn't get
  " unfolded.
  au FileType *.css,*.scss,*.less inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>

augroup END

" }}}

" Java {{{
augroup ft_java
  " au Filetype java setlocal ts=4 sts=4 sw=4 expandtab omnifunc=javacomplete#Complete
  au Filetype java setlocal ts=4 sts=4 sw=4 expandtab
  au Filetype java setlocal foldmethod=marker
  au Filetype java setlocal foldmarker={,}
  au Filetype java setlocal foldlevel=0
augroup END
" }}}

" [TODO] AU CMD {{{
if has("autocmd")
  filetype on                       " file type detection
  filetype plugin indent on
  " set ofu=syntaxcomplete#Complete

  " styles depending on file type
  au filetype html set omnifunc=htmlcomplete#CompleteTags

  autocmd BufWritePre *.java,*.yml,*.rb,*.html,*.css,*.scss,*.erb :call <sid>StripTrailingWhitespaces()
endif
"}}}

"}}}

" Folding {{{
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

" Java Folding {{{
" Javadoc comments (/** and */ pairs) and code sections (marked by {} pairs)
" mark the start and end of folds.
" All other lines simply take the fold level that is going so far.
function! MyFoldLevel( lineNumber )
  let thisLine = getline( a:lineNumber )
  " Don't create fold if entire Javadoc comment or {} pair is on one line.
  if ( thisLine =~ '\%(\%(/\*\*\).*\%(\*/\)\)\|\%({.*}\)' )
    return '='
  elseif ( thisLine =~ '\%(^\s*/\*\*\s*$\)\|{' )
    return "a1"
  elseif ( thisLine =~ '\%(^\s*\*/\s*$\)\|}' )
    return "s1"
  endif
  return '='
endfunction
" }}}

" }}}

" My Functions {{{

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

" my second vimscript function
function! <sid>FontSizeToggle()
  if &guifont == "Inconsolata-dz for Powerline:h12"
    set guifont=Inconsolata-dz\ for\ Powerline:h16
  else
    set guifont=Inconsolata-dz\ for\ Powerline:h12
  endif
endfunction

"--TODO--
function! <sid>ShowDate()
  return system('date')
endfunction
" }}}

" Remapping {{{

" Use comma as <leader> key instead of backslash
let mapleader=","
let maplocalleader="\\"

" Easier navigation betwen split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"Keep search matches in the middle of the window and pulse the line when moving
"to them.
nnoremap n nzzzv
nnoremap N Nzzzv

" Quick Editing {{{
noremap <leader>ev <C-w>v<C-w>j:e ~/.vim/vimrc<cr>
noremap <leader>ep <C-w>v<C-w>j:e ~/.pentadactylrc<cr>
noremap <leader>et <C-w>v<C-w>j:e ~/.tmux.conf<cr>
noremap <leader>eb <C-w>v<C-w>j:e ~/.bashrc<cr>
" }}}

" }}}

" double percentage sign in command mode is expanded
" to directory of current file - http://vimcasts.org/e/14
cnoremap %% <c-r>=expand('%:h').'/'<cr>

" Plugins settings ---------------------------------------------------------------- {{{

" CommandT {{{
" map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
" map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>
" map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>gg :topleft 25 :split Gemfile<cr>

" let g:CommandTMaxHeight=12
" let g:CommandTMatchWindowAtTop=1
"}}}

"MiniBufExplorer
" let g:miniBufExplForceSyntaxEnable = 1

" Makegreen {{{
" nnoremap \| :call MakeGreen('')<cr>
" }}}

" Ctrl-P {{{

let g:ctrlp_dont_split = 'NERD_tree_2'
let g:ctrlp_jump_to_buffer = 0
" let g:ctrlp_map = '<leader>,'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_reversed = 1
let g:ctrlp_split_window = 0
let g:ctrlp_max_height = 20
let g:ctrlp_extensions = ['tag']

let g:ctrlp_prompt_mappings = {
      \ 'PrtSelectMove("j")':   ['<c-j>', '<down>', '<s-tab>'],
      \ 'PrtSelectMove("k")':   ['<c-k>', '<up>', '<tab>'],
      \ 'PrtHistory("-1")':     ['<c-n>'],
      \ 'PrtHistory("1")':      ['<c-p>'],
      \ 'ToggleFocus()':        ['<c-tab>'],
      \ }

let ctrlp_filter_greps = "" .
      \ "egrep -iv '\\.(" .
      \ "jar|class|swp|swo|log|so|o|pyc|jpe?g|png|gif|mo|po" .
      \ ")$' | " .
      \ "egrep -v '^(\\./)?(" .
      \ "deploy/|lib/|classes/|libs/|deploy/vendor/|.git/|.hg/|.svn/|.*migrations/" .
      \ ")'"

let my_ctrlp_user_command = "" .
      \ "find %s '(' -type f ')' -maxdepth 15 -not -path '*/\\.*/*' | " .
      \ ctrlp_filter_greps

let my_ctrlp_git_command = "" .
      \ "cd %s && git ls-files | " .
      \ ctrlp_filter_greps

let g:ctrlp_user_command = ['.git/', my_ctrlp_git_command, my_ctrlp_user_command]

nnoremap <leader>. :CtrlPTag<cr>
" Alterar path do ctags com homebrew
nnoremap <leader><cr> :silent !/usr/local/Cellar/ctags/5.8/bin/ctags -R . tags<cr>:redraw!<cr>
" }}}

" SuperTab {{{
let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabLongestHighlight = 1
let g:SuperTabCrMapping = 1
" }}}

" }}}

" Function ShowRoutes {{{
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
" }}}

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
noremap <c-a> ^
noremap <c-e> g_

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
" nnoremap <leader>B :call <sid>BackgroundToggle()<cr>
nnoremap <leader>B :call <sid>FontSizeToggle()<cr>

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
let g:yankring_manual_clipboard_check = 0
nnoremap <c-y> :YRShow<CR>

" Surround
" let g:surround_insert_tail = "<++>"

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
" Guard {{{
augroup ft_guard
  au!
  au BufRead,BufNewFile Guardfile set ft=ruby
augroup END
" }}}
" Vagrant {{{
augroup ft_vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set ft=ruby
augroup END
" }}}
" Vim {{{
augroup ft_vim
  au!

  au FileType vim setlocal foldmethod=marker
  au FileType help setlocal textwidth=78
  au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END

" }}}
" CursorLine {{{
" Only show cursorline in the current window and in normal mode
augroup cline
  au!
  au WinLeave * set nocursorline
  au WinEnter * set cursorline
  au InsertEnter * set nocursorline
  au InsertLeave * set cursorline
augroup END
" }}}

" GUI Options {{{
set background=dark
colorscheme badwolf
" let g:solarized_visibility='low'

" set background=light

" Powerline fancy symbols
let g:Powerline_symbols = 'fancy'
let g:Powerline_cache_enabled = 1

if has("gui_macvim")
  " Remove all the UI cruft
  " go is same of guioptions
  set go-=T
  set go-=l
  set go-=L
  set go-=r
  set go-=R

  set lines=57
  set columns=237

  " GUI
  " set fuoptions=maxvert,maxhorz
  " set fullscreen
endif
" }}}

" Resize split when the window is resized
au VimResized * exe "normal! \<c-w>="

" Window rezising
nnoremap <Left> 4<c-w>>
nnoremap <Right> 4<c-w><

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
let g:syntastic_disabled_filetypes = ['html', 'rst']
let g:syntastic_stl_format = '[%E{%e Errors}%B{, }%W{%w Warnings}]'
let g:syntastic_sjl_conf = '$HOME/.vim/jsl.conf'
"}}}

" Substitute
noremap <leader>s :%s//<left>

" Get off my lawn
" nnoremap <Left> :echoe "Use h"<CR>
" nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Keep the cursor in place while joining lines
nnoremap J mzJ`z

" Python-Mode {{{

let g:pymode_doc = 1
let g:pymode_doc_key = '<localleader>ds'
let g:pydoc = 'pydoc'
let g:pymode_syntax = 1
" let g:pymode_syntax_all = 0
" let g:pymode_syntax_builtin_objs = 1
" let
" }}}

" Error Toggles {{{

command! ErrorsToggle call ErrorsToggle()
function! ErrorsToggle() " {{{
  if exists("w:is_error_window")
    unlet w:is_error_window
    exec "q"
  else
    exec "Errors"
    lopen
    let w:is_error_window = 1
  endif
endfunction " }}}

nmap <silent> <f3> :ErrorsToggle<cr>

" }}}
