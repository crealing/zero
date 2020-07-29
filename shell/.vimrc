set encoding=utf-8
set number
set showcmd
"set clipboard=unnmaed, unnamedpuls
set mouse=v
set cursorline
set hlsearch
"set incsearch
set history=40
set ruler
set pastetoggle=F3
set helplang=cn


set tabstop=4
set shiftwidth=4
set autoindent
filetype plugin indent on
"set cindent
"set smartindent 


syntax enable
syntax on
"set background=dark
"set background=light
"colorscheme solarized


"let g:rehash256=1
let g:molokai_original=1
highlight NonText guibg=#060606
highlight Folded guibg=#0A0A0A guifg=#9090D0
"set t_Co=256
"set background=dark
"colorscheme molokai


function HeaderPython()
	call setline(1, "#!/usr/local/bin/python")
	call append(1, "#-- coding:utf8 --")
	call append(2, "#Author: xiaowen")
	call append(3, "#Time:".strftime('%Y-%m-%d %T',localtime()))
	normal G
	normal o
endf
autocmd bufnewfile *.py call HeaderPython()


filetype plugin on
let g:pydiction_location='~/.vim/bundle/pydiction/complete-dict'
let g:pydiction_menu_height=3

function HeaderShell()
	call setline(1, "#!/bin/bash")
	call append(1,"#Author: xiaowen")
	call append(2, "#Time:".strftime("%Y-%m-%d %T",localtime()))
	normal G
	normal o
endf
autocmd bufnewfile *.sh call HeaderShell()
