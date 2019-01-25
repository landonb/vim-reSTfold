" File: dubs_rest_fold/after/ftplugin/rst.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project Page: https://github.com/landonb/dubs_rest_fold
" Summary: Performant reST section folding
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:
" -------------------------------------------------------------------
" Copyright © 2018 Landon Bouma.
"
" This file is part of Dubs Vim.
"
" Dubs Vim is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubs Vim is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubs Vim. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

" #########################################################################

" [lb]: Disable continuous folding, because measuring folds is slow!

" Use <F5> instead to manually trigger a re-fold.

" E.g., on a 7K-line reST file I have (normal for me!), typing is slow.
"
" - For instance, deleting a block of text takes a few seconds, at which
"   time Vim is seemingly unresponsive (you can Ctrl-C to kill parsing).
"
" - Note that syntax highlighting can also affect performance while editing,
"   which you'll want to account for when profiling. See :help syntime.

" For reference, here's what Vim does by default in its ftplugin/rst.vim
" (which is from https://github.com/marshallward/vim-restructuredtext):
"
"   setlocal foldmethod=expr
"   setlocal foldexpr=RstFold#GetRstFold()
"   setlocal foldtext=RstFold#GetRstFoldText()

setlocal foldmethod=manual
setlocal foldexpr="0"

" #########################################################################

" Set DEBUG_TRACE to 1 for :message blather.
"  let s:DEBUG_TRACE = 1
" MAYBE: [lb]: Remove this leftover development cruft.
" Or leave it, in case you need to fix any bugs later.
" (ALSO/2018-12-07: You might enjoy logging to a file to trace the runtime
"  rather than echoing to the :messages buffer. Search Dubs Vim for s:log.)
let s:DEBUG_TRACE = 0

" #########################################################################

" Folding based on specific sectioning.
" [lb]: I tried defining a local function, e.g., s:Func, and using foldexpr=<SID>Func,
" but it didn't stick. So using global function (and therefore name is capitalized).
function! ReSTfoldFoldLevel(lnum)
  let fold_level = IdentifyFoldLevelAtLine(a:lnum)
  if s:DEBUG_TRACE && a:lnum < 30
    echom "a:lnum: " . a:lnum . " / l:fold_level: " . l:fold_level
  endif
  return l:fold_level
endfunction

let s:PREV_FOLD_EXPR_LNUM = -1
if s:DEBUG_TRACE
  echom "s:PREV_FOLD_EXPR_LNUM: " . s:PREV_FOLD_EXPR_LNUM
endif

function! IdentifyFoldLevelAtLine(lnum)
  " Is foldexpr called deterministically? (Is it first called with lnum=1,
  " then lnum++ each call?) I know you can call :echo &foldlevel and trigger
  " this function out of order, but on zx is it called in order?
  if s:PREV_FOLD_EXPR_LNUM != -1
    if a:lnum != (s:PREV_FOLD_EXPR_LNUM + 1)
      if s:DEBUG_TRACE
        echom "Folding: a:lnum: " . a:lnum .  " / prev: " . s:PREV_FOLD_EXPR_LNUM
      endif
      let s:PREV_FOLD_EXPR_LNUM = a:lnum
      return -1
    endif
  endif
  let s:PREV_FOLD_EXPR_LNUM = a:lnum
  if s:PREV_FOLD_EXPR_LNUM == line('$')
    let s:PREV_FOLD_EXPR_LNUM = -1
  endif

  if a:lnum == 1
    let b:cur_level_fold = 0
    let b:cur_level_lnum = 0
  endif

  " Skip 2 lines following a new level.
  if (b:cur_level_fold == 0) || (a:lnum > (b:cur_level_lnum + 2))
    let l:new_level = GetFoldLevelIfNewReSTSection(a:lnum)
    if l:new_level > 0
      let b:cur_level_lnum = a:lnum
      let b:cur_level_fold = l:new_level
      let l:start_level = '>' . str2nr(l:new_level)
      if s:DEBUG_TRACE && a:lnum < 60
        echom "Folding: a:lnum: " . a:lnum . " / l:start_level: " . l:start_level
      endif
      return l:start_level
    endif
  endif

  if s:DEBUG_TRACE && a:lnum < 30
    echom "Folding: a:lnum: " . a:lnum . " / b:cur_level_fold: " . b:cur_level_fold
  endif
  return b:cur_level_fold
endfunction

function! GetFoldLevelIfNewReSTSection(lnum)
  " 2018-09-16: (lb): Before I added ReSTSectionTitleFoldText to deliberately
  " set the folded section title, I instead started the fold on the title text,
  " rather than on the leading section delimiter. So here I had to look behind
  " for the leading delimiter, and look ahead for the trailing delimiter, e.g.,
  "     let l:lnum_uppr = a:lnum - 1
  "     let l:lnum_lowr = a:lnum + 1
  " but then folds would be off my one, e.g., consider a section title like this:
  "      #############
  "      Section Title    <==== Where the fold used to start.
  "      #############
  " But now that ReSTSectionTitleFoldText looks a line ahead for the folded title,
  " we can set the fold on the leading delimiter, in which case here we check the
  " current line, and the line two lines ahead:
  let l:lnum_uppr = a:lnum
  let l:lnum_lowr = a:lnum + 2
  " We could just look for 1 or more repeating symbols:
  "   if getline(l:lnum_uppr) =~ '^@\+$' && getline(l:lnum_lowr) =~ '^@\+$'
  " but default /usr/share/vim/vim80/syntax/rst.vim checks 2+. Search file for:
  "   syn match rstSections
  let l:new_level = 0
  if getline(l:lnum_uppr) =~ '^@\{2,\}$' && getline(l:lnum_lowr) =~ '^@\{2,\}$'
    let l:new_level = 1
  elseif getline(l:lnum_uppr) =~ '^#\{2,\}$' && getline(l:lnum_lowr) =~ '^#\{2,\}$'
    let l:new_level = 2
  elseif getline(l:lnum_uppr) =~ '^=\{2,\}$' && getline(l:lnum_lowr) =~ '^=\{2,\}$'
    let l:new_level = 3
  elseif getline(l:lnum_uppr) =~ '^-\{2,\}$' && getline(l:lnum_lowr) =~ '^-\{2,\}$'
    let l:new_level = 4
  endif
  return l:new_level
endfunction

" #########################################################################

function! ReSTBufferUpdateFolds(reset_folding)
  " For some reason if I use mkview ... silent loadview here, folding doesn't work at all.
  if &foldenable
    if a:reset_folding == 0
      " When user is just saving file, remember view, so we can restore it
      " later, because `zx` will "Undo manually opened and closed folds".
      mkview 8
    endif
    let s:PREV_FOLD_EXPR_LNUM = -1
    setlocal foldexpr=ReSTfoldFoldLevel(v:lnum)
    setlocal foldmethod=expr
    normal! zx
    setlocal foldmethod=manual
    setlocal foldexpr="0"
    setlocal foldtext=ReSTSectionTitleFoldText()
    if a:reset_folding == 1
      " Close all folds (set foldlevel to 0).
      normal! zM
      " Reduce folding (set foldlevel to 1, opening top-level folds).
      normal! zr
      " Move to the top of the file, and then move downwards to the
      " start of the next (first) fold.
      normal! gg
      normal! zj
      "echom "Updated folds!"
    elseif a:reset_folding == 0
      silent loadview 8
    endif
  elseif a:reset_folding == 1
    echom "Run 'zi' to foldenable!"
  end
endfunction

" Wire <F5> to recalculating folds.
autocmd BufEnter,BufRead *.rst noremap <silent><buffer> <F5> :call ReSTBufferUpdateFolds(1)<CR>
autocmd BufEnter,BufRead *.rst inoremap <silent><buffer> <F5> <C-O>:call ReSTBufferUpdateFolds(1)<CR>

" #########################################################################

" Transpose folds (reposition/move folds "up" and "down")
"
" Related documentation:
"
"   http://vim.wikia.com/wiki/Transposing
"
"   http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines
"
"   http://vimcasts.org/episodes/swapping-two-regions-of-text-with-exchange-vim/
"
" Related projects:
"
"   https://github.com/tpope/vim-unimpaired
"
"   https://github.com/tommcdo/vim-exchange

" Move the entity under the cursor up a line.
function! s:MoveUp()
  let lineno = line('.')
  if lineno == 1
    return
  endif
  let fc = foldclosed('.')
  if fc == -1
    " (lb): Note that we use bang! to tell Vim to skip our mappings
    " and use the original meaning of Ctrl-y; and we use execute to
    " be able to specify the key to execute as a literal.
    execute "normal! \<C-y>"
    return
  end
  let a_reg = @a
  " "a   Use register `a` for the next delete, yank or put.
  " dd   Delete [count=1] lines [into register `a`] *linewise*.
  " k    Move up
  " "a   Use register `a` for the next delete, yank or put.
  " P    Put the text [from register `a`] before the cursor.
  " Note that, *linewise*, dd will delete all lines in a fold. Sweet!
  if lineno == line('$')
    normal! "add"aP
  else
    normal! "addk"aP
  endif
  let @a = a_reg
  if fc != -1
    call ReSTBufferUpdateFolds(2)
    normal! zc
  endif
endfunction

" Move the entity under the cursor down a line.
function! s:MoveDown()
  let fc = foldclosed('.')
  if fc == -1
    execute "normal! \<C-e>"
    return
  end
  let a_reg = @a
  normal! "add"ap
  let @a = a_reg
  if (fc != -1) && (foldclosed('.') == -1)
    call ReSTBufferUpdateFolds(2)
    normal! zc
  endif
endfunction

autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Up>   \|:silent call <SID>MoveUp()<CR>
autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Down> \|:silent call <SID>MoveDown()<CR>

" #########################################################################

" http://dhruvasagar.com/2013/03/28/vim-better-foldtext
function! ReSTSectionTitleFoldText()
  let l:lineno = v:foldstart
  if l:lineno != line('$')
    " Not the last line.
    let l:lineno += 1
  end

  let foldchar = matchstr(&fillchars, 'fold:\zs.')

  let textprefix = '+' . repeat(foldchar, v:foldlevel) . ' ' . getline(l:lineno)
  " (lb): Code from which I copied reserved 1/3 of the window for the meta, e.g.,
  "   let textstartend = (winwidth(0) * 2) / 3
  " but that wastes precious space we could use on the title.
  " MAGIC_NUMBERS:
  " 14: Per the %10s below, we assume folds will be less than 10K lines, so the
  "     longest meta text will be, e.g., "| 9999 lines |", or 14 characters.
  "  3: Trailing '---'
  "  2: ' ' padding around interior '-*'
  "  5: Prefix '+-* '
  let textstartend = winwidth(0) - 14 - 3 - 2 - 5
  " NOTE: Use strcharpart, not strpart, to could display width, not bytes,
  " i.e., a Unicode character should count as 1 display character, not 3 bytes.
  let foldtextstart = strcharpart(textprefix, 0, textstartend)

  let lines_count = v:foldend - v:foldstart + 1
  " MAGIC_NUMBER: %10s pads text to 10 characters, including ' lines',
  "   which leaves 4 characters for the count, i.e., 1000s.
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  " MAGIC_NUMBER: (lb): I think the 8 just really just be a 3, because the
  " var_length_hr is what ensures the width of the title line, and from usage,
  " there are only 3 dashes (foldchar) after count, e.g.,
  "   +---- FOLDTITLE -------------------------------------- | XX lines |---
  "                                                there are only 3 here ^^^
  let foldtextend = lines_count_text . repeat(foldchar, 8)

  " Substitute any character '.' for 'x' so that Unicode is counted as 1 each, e.g., not 3 each.
  "let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  " (lb): Or just use strwidth:
  let foldtextlength = strwidth(foldtextstart) + strwidth(foldtextend) + &foldcolumn

  " MAGIC_NUMBER: Subtract 2 for the 2 spaces added to pad the ------- sides.
  let var_length_hr = repeat(foldchar, winwidth(0) - foldtextlength - 2)
  let foldtitle = foldtextstart . ' ' . var_length_hr . ' ' . foldtextend
  return foldtitle
endfunction

