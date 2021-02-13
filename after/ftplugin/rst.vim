" Innovative reST section folding
" Author: Landon Bouma <https://tallybark.com/>
" Online: https://github.com/landonb/dubs_rest_fold
" License: https://creativecommons.org/publicdomain/zero/1.0/
"  vim:tw=0:ts=2:sw=2:et:norl:ft=vim
" Copyright © 2018-21 Landon Bouma.

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

" FIXME/2020-02-27 16:01: This (and perhaps other ftplugin/ files)
" are missing:
"
"   if exists('b:did_ftplugin') | finish | endif
"
" though given my experience with ftplugin files one could probably
" scream, "it just does't matter" (I've never seen an ftplugin sourced
" twice in a row, where the b: value actually exists() already).

" ################################################################# "

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

" ################################################################# "

" MAYBE: [lb]: Remove this leftover development cruft.
" Or leave it, in case you need to fix any bugs later.
" (ALSO/2018-12-07: You might enjoy logging to a file to trace the runtime
"  rather than echoing to the :messages buffer. Search Dubs Vim for s:log.)
let s:DEBUG_TRACE = 0
" Set DEBUG_TRACE to 1 for :message blather.
"  let s:DEBUG_TRACE = 1

" ################################################################# "

" Double-ruled reST header folding engine.
function! ReSTfoldFoldLevel(lnum)
  if b:RESTFOLD_SCANNER_LOOKUP == v:none
    call s:HydrateFoldLevelLookup()
  endif

  let l:fold_level = s:LookupFoldLevelAtLine(a:lnum)

  if s:DEBUG_TRACE && a:lnum < 30
    echom "a:lnum: " . a:lnum . " / l:fold_level: " . l:fold_level
  endif

  return l:fold_level
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

let b:RESTFOLD_SCANNER_LOOKUP = v:none

function! s:HydrateFoldLevelLookup()
  let l:file_length = line('$')

  let b:RESTFOLD_SCANNER_LOOKUP = s:ArrayFill(l:file_length + 1, -1)

  for lnum in range(l:file_length)
    let l:lnum += 1
    let b:RESTFOLD_SCANNER_LOOKUP[l:lnum] = s:IdentifyFoldLevelAtLine(l:lnum)
  endfor
endfunction

" ***

" Ref:
"   https://vi.stackexchange.com/questions/8045/
"     whats-the-best-way-to-initialize-a-list-of-a-predefined-length

" See also:
"   return repeat([a:value], a:length)
" - (lb): I have no idea whether map-range or repeat is more performant.
function! s:ArrayFill(length, value)
  return map(range(a:length), a:value)
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

function! s:LookupFoldLevelAtLine(lnum)
  if a:lnum < 1 || a:lnum >= len(b:RESTFOLD_SCANNER_LOOKUP)
    return -1
  endif

  return b:RESTFOLD_SCANNER_LOOKUP[a:lnum]
endfunction

function! s:LookupFoldLevelNumber(lnum)
  let l:fold_level = s:LookupFoldLevelAtLine(a:lnum)

  " Remove '>' starts-at-this-line delimiter.
  if type(l:fold_level) == type('') && stridx(l:fold_level, '>') != -1
    let l:fold_level = strcharpart(l:fold_level, 1)
  endif

  return str2nr(l:fold_level)
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

let b:RESTFOLD_SCANNER_LINENO = 0

function! s:IdentifyFoldLevelAtLine(lnum)
  if a:lnum != b:RESTFOLD_SCANNER_LINENO + 1
    echom "ERROR: reSTfold: Unexpected line number: " . a:lnum
      \ . " / Expected: " . b:RESTFOLD_SCANNER_LINENO + 1
  endif

  let b:RESTFOLD_SCANNER_LINENO = a:lnum

  if a:lnum == 1
    let b:cur_level_fold = 0
    let b:cur_level_lnum = 0
  endif

  " Skip 2 lines following a new level (or beginning of file).
  if (b:cur_level_fold == 0) || (a:lnum > (b:cur_level_lnum + 2))
    let l:new_level = GetFoldLevelIfNewReSTSection(a:lnum)

    if l:new_level > 0
      let b:cur_level_lnum = a:lnum
      let b:cur_level_fold = l:new_level
      " Indicate that a new fold '>' starts at this line.
      " MAYBE/2021-02-13: Any reason to also specify '<' ends at this line?
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

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

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

" ################################################################# "

function! ReSTBufferUpdateFolds(reset_folding)
  " For some reason if I use mkview ... silent loadview here, folding doesn't work at all.
  if &foldenable
    if a:reset_folding == 0
      " When user is just saving file, remember view, so we can restore it
      " later, because `zx` will "Undo manually opened and closed folds".
      mkview 8
    endif

    let b:RESTFOLD_SCANNER_LINENO = 0
    let b:RESTFOLD_SCANNER_LOOKUP = v:none

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

" ################################################################# "

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
  let l:lineno = line('.')
  if l:lineno == 1
    return
  endif

  let l:fc = foldclosed('.')
  if l:fc == -1
    " (lb): Note that we use bang! to tell Vim to skip our mappings
    " and use the original meaning of Ctrl-y; and we use execute to
    " be able to specify the key to execute as a literal.
    execute "normal! \<C-y>"
    return
  end

  let l:a_reg = @a
  " "a   Use register `a` for the next delete, yank or put.
  " dd   Delete [count=1] lines [into register `a`] *linewise*.
  " k    Move up
  " "a   Use register `a` for the next delete, yank or put.
  " P    Put the text [from register `a`] before the cursor.
  " Note that, *linewise*, dd will delete all lines in a fold. Sweet!
  if l:lineno == line('$')
    normal! "add"aP
  else
    normal! "addk"aP
  endif

  let @a = l:a_reg
  if l:fc != -1
    call ReSTBufferUpdateFolds(2)
    normal! zc
  endif
endfunction

" Move the entity under the cursor down a line.
function! s:MoveDown()
  let l:fc = foldclosed('.')
  if l:fc == -1
    execute "normal! \<C-e>"

    return
  end

  let l:a_reg = @a
  normal! "add"ap
  let @a = l:a_reg
  if (l:fc != -1) && (foldclosed('.') == -1)
    call ReSTBufferUpdateFolds(2)
    normal! zc
  endif
endfunction

autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Up>   \|:silent call <SID>MoveUp()<CR>
autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Down> \|:silent call <SID>MoveDown()<CR>

" ################################################################# "

" With a little help from:
"   http://dhruvasagar.com/2013/03/28/vim-better-foldtext

" 2021-02-13: This plugin formerly extracted the single fold character for fillchars,
" e.g., given fillchars="vert:|,fold:-", this matchstr extracts the '-' dash:
"   let l:foldchar = matchstr(&fillchars, 'fold:\zs.')
" But that doesn't allow for custom └─piping─┘.

function! ReSTSectionTitleFoldText()
  " The reSTfold format specifies horizontal rules above and below the title (a
  " section title sandwich). So the fold starts on the first horizontal rule (at
  " v:foldstart), and the title is the first line after v:foldstart. Unless EOF.
  let l:lineno_title = v:foldstart
  if l:lineno_title != line('$')
    " Not the last line.
    let l:lineno_title += 1
  end

  let l:fold_closed_line = foldclosed(v:foldstart)
  let l:fold_closed_endl = foldclosedend(v:foldstart)

  let l:fold_start_prev = foldclosed(v:foldstart - 1)
  "let l:fold_level_prev = s:LookupFoldLevelNumber(v:foldstart - 1)
  let l:fold_level_prev = s:LookupFoldLevelNumber(l:fold_start_prev)
  "
  let l:fold_start_next = foldclosed(foldclosedend(v:foldstart) + 1)
  "let l:fold_level_next = s:LookupFoldLevelNumber(v:foldend + 1)
  let l:fold_level_next = s:LookupFoldLevelNumber(l:fold_start_next)
  "
  let l:prefix_pipe = ''
  if v:foldlevel == l:fold_level_next
    if v:foldlevel == l:fold_level_prev
      let l:prefix_pipe = '├'
    else
      let l:prefix_pipe = '┌'
    endif
  elseif v:foldlevel == l:fold_level_prev
    " But v:foldlevel != l:fold_level_next
    let l:prefix_pipe = '└'
  else
    let l:prefix_pipe = '─'
  endif
  if s:DEBUG_TRACE
    echom "=== v:foldlvl: " . v:foldlevel
          \ . " / v:fldstrt: " . v:foldstart
          \ . " / v:foldend: " . v:foldend
          \ . " / prev: " . l:fold_level_prev
          \ . " / next: " . l:fold_level_next
          \ . " / cllin: " . l:fold_closed_line
          \ . " / clend: " . l:fold_closed_endl
  endif

  let l:foldchar = '─'

  let l:lvl_prefix = ''
  if v:foldlevel == 1
    let l:lvl_prefix = l:prefix_pipe . '─'
  elseif v:foldlevel == 2
    let l:lvl_prefix = ' ' . l:prefix_pipe . '──'
  else
    let l:lvl_prefix = '   ' . l:prefix_pipe . repeat(l:foldchar . l:foldchar, v:foldlevel - 1)
  endif
  let l:textprefix = l:lvl_prefix . ' ' . getline(l:lineno_title)

  " (lb): Code from which I copied reserved 1/3 of the window for the meta, e.g.,
  "   let textstartend = (winwidth(0) * 2) / 3
  " but that wastes precious space we could use on the title.
  " MAGIC_NUMBERS:
  "  4: Per the %10s below, we assume folds will be less than 10K lines, so the
  "     longest meta text will be, e.g., "| 9999 lines |", or 14 characters.
  "  0: Trailing '---'
  "  0: ' ' padding around interior '-*'
  "  5: Prefix '+-* '
  let l:textstartend = winwidth(0) - 4 - 0 - 0 - 5
  " NOTE: Use strcharpart, not strpart, to calculate display width, not bytes,
  " i.e., Unicode characters should count as 1 display character, not 3 bytes.
  let l:foldtextstart = strcharpart(l:textprefix, 0, l:textstartend)

  let l:lines_count = v:foldend - v:foldstart + 1
  " MAGIC_NUMBER: %10s pads text to 10 characters, including ' lines',
  "   which leaves 4 characters for the count, i.e., 1000s.
  let l:lines_count_text = '| ' . printf("%4", l:lines_count) . ' |'
  " MAGIC_NUMBER: (lb): I think the 8 just really just be a 3, because the
  " var_length_hr is what ensures the width of the title line, and from usage,
  " there are only 3 dashes (l:foldchar) after count, e.g.,
  "   +---- FOLDTITLE -------------------------------------- | XX lines |---
  "                                                there are only 3 here ^^^
  let l:foldtextend = ''

  " Substitute any character '.' for 'x' so that Unicode is counted as 1 each, e.g., not 3 each.
  "let foldtextlength = strlen(substitute(l:foldtextstart . l:foldtextend, '.', 'x', 'g')) + &foldcolumn
  " (lb): Or just use strwidth:
  let l:foldtextlength = strwidth(l:foldtextstart) + strwidth(l:foldtextend) + &foldcolumn

  " MAGIC_NUMBER: Subtract 2 for the 2 spaces added to pad the ------- sides.
  let l:var_length_hr = ''
  let l:foldtitle = l:foldtextstart . ' ' . l:var_length_hr . ' ' . l:foldtextend

  return l:foldtitle
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

