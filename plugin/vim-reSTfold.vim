" vim:tw=0:ts=2:sw=2:et:norl
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3 | Copyright © 2018-2022, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_reSTfold
endif

if exists('g:loaded_reSTfold') || &cp

  finish
endif

let g:loaded_reSTfold = 1

" -------------------------------------------------------------------

if get(g:, 'loaded_reSTfold_disable', 0)

  finish
endif

" -------------------------------------------------------------------

" CXREF:
" ~/.vim/pack/embrace-vim/start/vim-reSTfold/autoload/embrace/reSecTions.vim
call g:embrace#reSecTions#CreateMaps()

