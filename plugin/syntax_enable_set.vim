" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3 | Copyright © 2018-2022, 2024 Landon Bouma.
" Summary: Vim syntax highlights enablement.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_restfold_syntax_enable_set
endif

if exists('g:loaded_restfold_syntax_enable_set') || &cp

  finish
endif

let g:loaded_restfold_syntax_enable_set = 1

" -------------------------------------------------------------------

if get(g:, 'vim_restfold_disable', 0)

  finish
endif

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Syntax enable
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Enable syntax highlighting
" ------------------------------------------------------
" Syntax is enabled by default on Windows, but not on Linux.

syntax enable

