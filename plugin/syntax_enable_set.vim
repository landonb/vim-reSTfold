" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3 | Copyright © 2018-2022, 2024 Landon Bouma.
" Summary: Vim syntax highlights enablement.

if exists("g:loaded_reSTfold_syntax_enable_set") || &cp
  finish
endif
let g:loaded_reSTfold_syntax_enable_set = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Syntax enable
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Enable syntax highlighting
" ------------------------------------------------------
" Syntax is enabled by default in Windows, but not in Linux.

syntax enable

