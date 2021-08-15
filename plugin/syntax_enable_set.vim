" Vim syntax highlights enabler.
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project: https://github.com/landonb/dubs_rest_fold
" License: https://creativecommons.org/publicdomain/zero/1.0/
"  vim:tw=0:ts=2:sw=2:et:norl:

if exists("g:loaded_rest_fold_syntax_enable_set") || &cp
  finish
endif
let g:loaded_rest_fold_syntax_enable_set = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Syntax enable
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Enable syntax highlighting
" ------------------------------------------------------
" Syntax is enabled by default in Windows, but not in Linux.

syntax enable

