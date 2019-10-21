set nocompatible                " be iMproved

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plug plugin management

call plug#begin()

" tuning
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'

" editing
Plug 'ervandew/supertab'
Plug 'dense-analysis/ale'
Plug 'majutsushi/tagbar'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
Plug 'brooth/far.vim'
Plug 'haya14busa/incsearch.vim'

" theme
Plug 'srcery-colors/srcery-vim'
Plug 'junegunn/vim-emoji'

" language support
Plug 'sudar/vim-arduino-syntax'
Plug 'kylef/apiblueprint.vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'plasticboy/vim-markdown'
Plug 'vim-scripts/openscad.vim'
Plug 'cespare/vim-toml'
" Plug 'hdima/python-syntax'
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
" Plug 'davidhalter/jedi-vim'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" General

set history=100                 " How many lines of history to remember
set clipboard+=unnamed          " sharing with system clipboard
set viminfo+=!                  " make sure it can save viminfo
set noswapfile                  " do not write annoying intermediate swap files
set wildignore=*.swp,*.pyc      " ignore theese files
set autoread                    " autoread changed files

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Vim UI

set guioptions=ac               " disable GUI and keep only useful stuff
set lsp=0                       " space it out a little more (easier to read)
set wildmenu                    " turn on wild menu
set ruler                       " always show current positions along the bottom
set number                      " turn on line numbers
set showcmd                     " show partial commands in the last line of the screen
set guicursor+=a:blinkon0       " turn off cursor blinking
set laststatus=2                " always show the status line
set noshowmode                  " don't show edit mode in statusline

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Theme

syntax on                       " syntax highlighting on
set background=dark             " we are using a dark background
set colorcolumn=80              " colored column
" font is set in ginit.vim
" set guifont=Source\ Code\ Pro\ for\ Powerline\ Light:h16    " font
set termguicolors
let g:srcery_bold = 0
colorscheme srcery

function HighlightsOverride()
    " disable bold for imported
    hi semshiImported cterm=NONE gui=NONE
    " color srcery xgray4
    hi LineNr ctermfg=238 guifg='#444444'
endfunction
autocmd ColorScheme * call HighlightsOverride()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Visual Cues

set so=5                        " keep lines (top/bottom) for scope
set showmatch                   " show matching brackets
set matchpairs+=<:>             " ^ match also < > brackets
" set hlsearch                    " do not highlight searched for phrases
" set incsearch                   " BUT do highlight as you type you search phrase
set ignorecase                  " use case insensitive search
set smartcase                   " ^ except when using capital letters
set listchars=tab:\|\ ,trail:.,eol:$ " what to show when I hit :set list

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Text Formatting

set autoindent                  " autoindent on new line
set expandtab                   " spaces instead of TAB
set tabstop=4                   " tab spacing (settings below are just to unify it)
set softtabstop=4               " unify
set shiftwidth=4                " unify
set nowrap                      " do not wrap lines
set backspace=indent,eol,start  " allow backspacing over autoindent, line breaks and start of insert action
set isk+=$,@,%,#,_              " none of these should be word dividers, so make them not be

autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2  " Two spaces for HTML files
autocmd FileType htmldjango setlocal tabstop=2 softtabstop=2 shiftwidth=2  " Two spaces for HTML files
autocmd FileType javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2  " Two spaces for JavaScript files
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2  " Two spaces for HTML files

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Shortcuts

" plugin CtrlP
noremap <leader>e :CtrlP<CR>
noremap <leader>f :CtrlPClearAllCaches<CR>
let g:ctrlp_working_path_mode = ''

" plugin Tagbar
noremap <leader>i :TagbarToggle<CR>

" new tab
noremap <leader>t :tabnew<CR>

" ack word under cursor
noremap <leader>a :Ack!<CR>

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" plugin Semshi
nmap <silent> <leader>rr :Semshi rename<CR>
nmap <silent> <leader>n :Semshi goto name next<CR>
nmap <silent> <leader>N :Semshi goto name prev<CR>
nmap <silent> <leader>c :Semshi goto class next<CR>
nmap <silent> <leader>C :Semshi goto class prev<CR>
nmap <silent> <leader>f :Semshi goto function next<CR>
nmap <silent> <leader>F :Semshi goto function prev<CR>

" plugin incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

set hlsearch
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugins

" Airline
let g:airline_theme = 'minimalist'
let g:airline_powerline_fonts = 1
let g:airline_section_x = ''
let g:airline_section_y = '%{airline#extensions#tagbar#currenttag()}'

" Ale
let g:ale_linters = { 'javascript': ['eslint'], 'python': ['pylint'] }
let g:ale_python_pylint_options = '--disable=import-error'
let g:ale_lint_on_text_changed = 'never'
let g:ale_fixers = { 'javascript': ['prettier'], 'python': ['black'] }
let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_javascript_eslint_use_global = 1
let g:ale_sign_error = emoji#for('small_red_triangle')
let g:ale_sign_warning = emoji#for('small_orange_diamond')

" Ack
let g:ackprg="ag --hidden --vimgrep"

" Markdown
let g:vim_markdown_folding_disabled=1

" CtrlP
let g:ctrlp_custom_ignore = { 'dir': '\.git$\|node_modules$\|docker/.*/src$' }

" JSX
let g:jsx_ext_required = 0

" Semshi
let g:semshi#mark_selected_nodes = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Automatization

" remove trailing whitespaces before save
fun! StripTrailingWhitespace()
    " Don't strip on these filetypes
    if &ft =~ 'markdown'
        return
    endif
    %s/\s\+$//e
endfun

autocmd BufWritePre * call StripTrailingWhitespace()

" set python syntax for *.wsgi files
autocmd BufReadPost *.wsgi set syntax=python
" set python syntax for *.spy files
autocmd BufReadPost *.spy set syntax=python

" cd on start
cd ~/dev
