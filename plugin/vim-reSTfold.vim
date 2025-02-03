" vim:tw=0:ts=2:sw=2:et:norl
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3 | Copyright © 2018-2022, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_restfold_vim_restfold
endif

if exists('g:loaded_restfold_vim_restfold') || &cp

  finish
endif

let g:loaded_restfold_vim_restfold = 1

" -------------------------------------------------------------------

if get(g:, 'vim_restfold_disable', 0)

  finish
endif

" -------------------------------------------------------------------

" CXREF:
" ~/.kit/nvim/embrace-vim/start/vim-reSTfold/autoload/embrace/reSecTions.vim
call g:embrace#reSecTions#CreateMaps()

