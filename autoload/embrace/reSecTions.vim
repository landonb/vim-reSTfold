" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3 | Copyright © 2018-2022, 2024 Landon Bouma.
" Summary: Quickly insert reST heading underlines and overlines

" -------------------------------------------------------------------

" ABOUT:
"
" The command maps installed below make reStructered Text-style
" section header borders.
"
"   E.g., write a header:
"
"     My Awesome Section Header
"
"   and then switch to normal mode and type <Leader>#,
"   e.g., \#, and your text transforms to:
"
"     #########################
"     My Awesome Section Header
"     #########################

" -------------------------------------------------------------------

" PRIVY: CXREF:
" ~/.kit/docs/source/the_knowledge/Markup__reST.rst

" -------------------------------------------------------------------

" HSTRY/2017-03-28: [lb] I grew tired of manually setting up reST
" header decoration, and I made this plugin.
"
" - Here's the section delimiter hierarchy I commonly uses in reST docs:
"
"    @@@@@@@@@@@@@@@@@@@  <-- Single Document title
"    ###################  <-- Top-level sections
"    ===================  <-- Sub-sections
"    -------------------  <-- Sub-sub-sections
"    ^^^^^^^^^^^^^^^^^^^  <-- Rarely used, but would be next
"    ~~~~~~~~~~~~~~~~~~~  <-- Then this perhaps
"    '''''''''''''''''''  <-- And I don't think I've ever
"    :::::::::::::::::::  <--   made it this far
"
" REFER: Author's reST § delim. hier.: `@@@ ### === --- ^^^ ~~~ ''' :::`
"
" - Here's punctuation you might consider for section outlines
"   that is centered vertically in the character line (ordered
"   roughly by most-pixels-per-character-to-least, if a fuller
"   look conveys a more prominent heading level):
"
"     @ # & $ % {} [] () \ / | = ? ! <> ~ - :
"
"   - Note that `+` is omitted because it's highlighted by the
"     rstTableLines highlight.
"
" - Here's punctuation you might consider, but it's not centered
"   vertically, so it might look weird if used over and under:
"
"     ; ^ _ " ' . ` , *
"
"   - E.g., tilde looks fine as an underline:
"
"       Section Title
"       ^^^^^^^^^^^^^
"
"     But when an overline is added, the title is not visually
"     centered, e.g.:
"
"       ^^^^^^^^^^^^^
"       Section Title
"       ^^^^^^^^^^^^^
"
" Per Sphinx docs:
"
" - "Normally, there are no heading levels assigned to certain characters
"    as the structure is determined from the succession of headings.
"    However, this convention is used in Python Developer’s Guide for
"    documenting which you may follow:"
"
"   - # with overline, for parts
"
"   - * with overline, for chapters
"
"   - = for sections
"
"   - - for subsections
"
"   - ^ for subsubsections
"
" REFER: https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html#sections
"
" Per reST ref:
"
" - "The following are all valid section title adornment characters:"
"
"     ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
"
" - "Some characters are more suitable than others. The following are recommended:"
"
"     = - ` : . ' " ~ ^ _ * + #
"
" REFER: https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#sections
"
" This plugin supports adorning sections with any punctuation character
" (unless you config it to do less).

" -------------------------------------------------------------------

" USAGE:
"
" For the ornament characters that occupy their key on the number
" row of on an American English keyboard, you can add delimiters
" to a new line below, or to new lines above and below using the
" <Leader>{char} maps:
"
" - Map <Leader>{char} to underline using the indicated header character.
"
" - Map <Leader>{CHAR} to underline and overline using said character.
"
" - E.g., <Leader>3 underlines with pound symbols,
"     and <Leader># under- and overlines with 'em.
"
" For all the characters, and not just those you access with a
" Shift-number keypress, you can use double-leader instead.
"
" - Note this *does not add* new lines but overwrites what's
"   above and/or below.
"
" - E.g., use double-leader-char to underline:
"
"     <Leader><Leader>{char}
"
"   and use leader-shift-leader-char to add both:
"
"     <Leader><Shift-Leader>{char}
"
" - The double-leader maps are useful if you want to *replace*
"   existing ornamenation.
"
"   - E.g., if a title looks like this:
"
"       =============
"       Section Title
"       =============
"
"     If you place you cursor on the title like
"     and press <Leader><Leader>#, you'll get this:
"
"       #############
"       Section Title
"       #############
"
" Details:
"
" - The commands work regardless of leading whitespace (though in
"   practice your section titles won't have leading whitespace, but
"   it might be helpful if you have something in a blockquote).
"
" - The commands all work from normal mode in all files.
"
"   - They also all work from insert mode for reST files.
"
"   - But only a few of them work from insert mode for other
"     file types.
"
"     - E.g., if you write Vim |regexp|, you might type \*
"       often enough that it'd be annoying if that dumped
"       over- and underlines on your code.

" -------------------------------------------------------------------

" Some hints about the motion, yank, and put commands used below.
"
" REFER: With a little help from:
"
"   http://vim.wikia.com/wiki/Underline_using_dashes_automatically
"
" REFER: Ctrl-Q is the CTRL-V-alternative, since Ctrl-V is paste
"        if you fly with mswin.vim.
"
"        Ctrl-Q starts a blockwise Visual selection.
"
"        $ selects to the end of the line.
"
"        r starts a replace, and the last character
"          is the replacement character.
"
"        Oh, and you know yyp, right?
"          y starts a yank, yy yanks the line, and p is put.
"
"       And then yykP: k moves up a line, and P puts above.
"
" SAVVY: To replace selected: Select text and type <C-O>rX
"        where X is the replacement character.

" ***

" (lb): I'm not sure prepending <C-O> to every command is the ideal way
" to do this, but it works! (Not knowing is what I get for only poking
" at my Vim code every once in a blue moon!)

let s:yank_put_replace_n = 'yyp<C-Q>$r'

let s:up_n = '<UP>'
let s:yank_up_putbefore_down_n = 'yykP<DOWN>'

let s:delete_line_above_n = '<UP>dd'
let s:delete_line_under_n = '<DOWN>dd<UP>'

" ***

" Set nonzero to enable `echom` trace.
let s:trace = 0

" -------------------------------------------------------------------

function! s:map_shift_only_punctuation_addline_normal_under(keych, delim) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim)

  let l:seq = '<Leader>' . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:delim . s:up_n)
endfunction

function! s:map_shift_only_punctuation_addline_normal_hilow(keych, delim, extra) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:delim . s:yank_up_putbefore_down_n)
endfunction

" ***

function! s:map_shift_only_punctuation_addline_insert_under(keych, delim) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim)

  let l:seq = '<Leader>' . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i')
  " MAYBE/2019-02-09: Use function, and restore cursor position. For now, goes to first character of line.
  call s:ExeAndEchom('inoremap ' . l:seq . ' ' . '<ESC>' . s:yank_put_replace_n . a:delim . s:up_n . 'i')
endfunction

function! s:map_shift_only_punctuation_addline_insert_hilow(keych, delim, extra) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i')
  call s:ExeAndEchom('inoremap ' . l:seq . ' ' . '<ESC>' . s:yank_put_replace_n . a:delim . s:yank_up_putbefore_down_n . 'i')
endfunction

" ***

function! s:map_shift_only_punctuation_replace_normal_under(keych, delim, extra = '<Leader>') abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:delete_line_under_n . s:yank_put_replace_n . a:delim . s:up_n)
endfunction

" :help function-argument

function! s:map_shift_only_punctuation_replace_normal_hilow(keych, delim, extra = '<Leader>') abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:delete_line_above_n . s:delete_line_under_n . s:yank_put_replace_n . a:delim . s:yank_up_putbefore_down_n)
endfunction

" ***

function! s:map_shift_only_punctuation_replace_insert_under(keych, delim, extra = '<Leader>') abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i')
  " ALTLY: Same outcome, but without leaving insert mode, e.g.:
  "   inoremap <Leader><Leader>= <DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  call s:ExeAndEchom('inoremap ' . l:seq . ' ' . '<ESC>' . s:delete_line_under_n . s:yank_put_replace_n . a:delim . s:up_n . 'i')
endfunction

function! s:map_shift_only_punctuation_replace_insert_hilow(keych, delim, extra = '<Leader>') abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = '<Leader>' . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i')
  " ALTLY: Same outcome, but without leaving insert mode, e.g.:
  "   inoremap <Leader><Leader>+ <UP><C-O>dd<DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  call s:ExeAndEchom('inoremap ' . l:seq . ' ' . '<ESC>' . s:delete_line_above_n . s:delete_line_under_n . s:yank_put_replace_n . a:delim . s:yank_up_putbefore_down_n . 'i')
endfunction

" ***

function! s:map_shift_only_punctuation_addtext_maps(knum, punc) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:knum . ':' . a:punc)

  call s:map_shift_only_punctuation_addline_normal_under(a:knum, a:punc)
  call s:map_shift_only_punctuation_addline_normal_hilow(a:punc, a:punc, '')
  call s:map_shift_only_punctuation_replace_normal_under(a:knum, a:punc)
  call s:map_shift_only_punctuation_replace_normal_hilow(a:punc, a:punc)
  " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
  call s:map_shift_only_punctuation_addline_normal_hilow(a:knum, a:punc, '\|')
  call s:map_shift_only_punctuation_addline_normal_hilow(a:punc, a:punc, '\|')
  "
  call s:map_shift_only_punctuation_addline_insert_under(a:knum, a:punc)
  call s:map_shift_only_punctuation_addline_insert_hilow(a:punc, a:punc, '')
  call s:map_shift_only_punctuation_replace_insert_under(a:knum, a:punc)
  call s:map_shift_only_punctuation_replace_insert_hilow(a:punc, a:punc)
  " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
  call s:map_shift_only_punctuation_addline_insert_hilow(a:knum, a:punc, '\|')
  call s:map_shift_only_punctuation_addline_insert_hilow(a:punc, a:punc, '\|')

  if s:trace | echom ' ' | endif
endfunction

" ***

function! s:map_lower_only_punctuation_addtext_maps(lower, upper) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:lower . ':' . a:upper)

  call s:map_shift_only_punctuation_addline_normal_under(a:lower, a:lower)
  call s:map_shift_only_punctuation_addline_normal_hilow(a:upper, a:lower, '')
  call s:map_shift_only_punctuation_replace_normal_under(a:lower, a:lower)
  call s:map_shift_only_punctuation_replace_normal_hilow(a:upper, a:lower)
  " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
  call s:map_shift_only_punctuation_addline_normal_hilow(a:lower, a:lower, '\|')
  call s:map_shift_only_punctuation_addline_normal_hilow(a:upper, a:lower, '\|')
  "
  call s:map_shift_only_punctuation_addline_insert_under(a:lower, a:lower)
  call s:map_shift_only_punctuation_addline_insert_hilow(a:upper, a:lower, '')
  call s:map_shift_only_punctuation_replace_insert_under(a:lower, a:lower)
  call s:map_shift_only_punctuation_replace_insert_hilow(a:upper, a:lower)
  " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
  call s:map_shift_only_punctuation_addline_insert_hilow(a:lower, a:lower, '\|')
  call s:map_shift_only_punctuation_addline_insert_hilow(a:upper, a:lower, '\|')

  if s:trace | echom ' ' | endif
endfunction

" ***

function! s:map_lower_or_upper_punctuation(punc) abort
  call g:embrace#reSecTions#EchomCallerMsg('punc: ' . a:punc)

  let l:seq = '<Leader>' . a:punc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:punc . s:up_n)

  let l:seq = '<Leader>\|' . a:punc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:punc . s:yank_up_putbefore_down_n)
endfunction

" (((((((((((((((((((((((((((((((((((
" Inside Inside Inside The Delimiters
" )))))))))))))))))))))))))))))))))))
function! s:map_insider_punctuation(lpunc, rpunc) abort
  call g:embrace#reSecTions#EchomCallerMsg('lpunc:rpunc: ' . a:lpunc . ':' . a:rpunc)

  let l:seq = '<Leader>' . a:lpunc . a:rpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' yyP<C-Q>$r' . a:lpunc . '<DOWN>yyp<C-Q>$r' . a:rpunc . '<UP>')
endfunction

function! s:map_doubled_punctuation(dpunc) abort
  call g:embrace#reSecTions#EchomCallerMsg('dpunc: ' . a:dpunc)

  let l:seq = '<Leader>' . a:dpunc . a:dpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:dpunc . '<UP>')

  let l:seq = '<Leader>\|' . a:dpunc . a:dpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n')
  call s:ExeAndEchom('nnoremap ' . l:seq . ' ' . s:yank_put_replace_n . a:dpunc . 'yykP' . '<DOWN>')
endfunction

" -------------------------------------------------------------------

function! s:map_special_key_ten_ways_to_equal() abort
  call g:embrace#reSecTions#EchomCallerMsg('keyseqs: \= \+ \|+ \\= \\+')

  " We don't use '+' as a section delimiter because the
  "   reST syntax parser sees that as a table delimiter.
  " Instead, map <Leader>= to under-section with equal signs
  "   and then map <Leader>+ to over-under-section with equals.
  "
  "   =======
  "   SECTION
  "   =======
  call g:embrace#reSecTions#AlertIfMapped('<Leader>=', 'n')
  call s:map_shift_only_punctuation_addline_normal_under('=', '=')
  call g:embrace#reSecTions#AlertIfMapped('<Leader>+', 'n')
  call s:map_shift_only_punctuation_addline_normal_hilow('+', '=', '')
  call g:embrace#reSecTions#AlertIfMapped('<Leader>\|+', 'n')
  call s:map_shift_only_punctuation_replace_normal_hilow('+', '=', '\|')
  " nnoremap <Leader>= yyp<C-Q>$r=<UP>
  " nnoremap <Leader>+ yyp<C-Q>$r=yykP<DOWN>
  " nnoremap <Leader>\|+ yyp<C-Q>$r=yykP<DOWN>
  "
  call g:embrace#reSecTions#AlertIfMapped('<Leader>=', 'i')
  call s:map_shift_only_punctuation_addline_insert_under('=', '=')
  call g:embrace#reSecTions#AlertIfMapped('<Leader>+', 'i')
  call s:map_shift_only_punctuation_addline_insert_hilow('+', '=', '')
  call g:embrace#reSecTions#AlertIfMapped('<Leader>\|+', 'i')
  call s:map_shift_only_punctuation_replace_insert_hilow('+', '=', '\|')
  " inoremap <Leader>= <C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  " inoremap <Leader>+ <C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  " inoremap <Leader>\|+ <C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>

  " 2019-02-08: Whatever: I couldn't get -d | +d | normal k to work,
  " but that's okay, UP DOWN (LEFT RIGHT) also works! (The minus ``-``
  " key is apparently mapped to NerdTree, so typing ``-d`` does not
  " exactly work, as the minus press immediately triggers NerdTree.)
  " Oh, anyway: this mapping removes the line above and line below,
  " and replaces the section border.
  "   e.g., if::
  "
  "     ======
  "     header got longer
  "     ======
  "
  "   then the mapping could, in one swoop, produce::
  "
  "     =================
  "     header got longer
  "     =================
  call g:embrace#reSecTions#AlertIfMapped('<Leader><Leader>=', 'n')
  call s:map_shift_only_punctuation_replace_normal_under('=', '=', '<Leader>')
  call g:embrace#reSecTions#AlertIfMapped('<Leader><Leader>+', 'n')
  call s:map_shift_only_punctuation_replace_normal_hilow('+', '=', '<Leader>')
  " nnoremap <Leader><Leader>= <DOWN>dd<UP>yyp<C-Q>$r=<UP>
  " nnoremap <Leader><Leader>+ <UP>dd<DOWN>dd<UP>yyp<C-Q>$r=yykP<DOWN>
  "
  call g:embrace#reSecTions#AlertIfMapped('<Leader><Leader>=', 'i')
  call s:map_shift_only_punctuation_replace_insert_under('=', '=', '<Leader>')
  call g:embrace#reSecTions#AlertIfMapped('<Leader><Leader>+', 'i')
  call s:map_shift_only_punctuation_replace_insert_hilow('+', '=', '<Leader>')
  " inoremap <Leader><Leader>= <DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  " inoremap <Leader><Leader>+ <UP><C-O>dd<DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
endfunction

" ***

function! s:map_special_key_pipe_and_double_pipe() abort
  call g:embrace#reSecTions#EchomCallerMsg('keyseqs: \| \||')

  " The pipe character is not sent to map_lower_or_upper_punctuation
  " because it needs to be escaped.
  call g:embrace#reSecTions#AlertIfMapped('<Leader>\|', 'n')
  call s:map_shift_only_punctuation_addline_normal_under('\|', '\|')
  call g:embrace#reSecTions#AlertIfMapped('<Leader>\|\|', 'n')
  call s:map_shift_only_punctuation_addline_normal_hilow('\|', '\|', '\|')
  " nnoremap <Leader>\| yyp<C-Q>$r\|<UP>
  " nnoremap <Leader>\|\| yyp<C-Q>$r\|yykP<DOWN>
endfunction

" -------------------------------------------------------------------

function! g:embrace#reSecTions#AlertIfMapped(what, mode) abort
  if get(g:, 'vim_restfold_alert_disable', 0)

    return
  endif

  " Note that we delimit pipes \| for the map calls, but not for maparg.
  " - E.g., this returns empty string:
  "     maparg('<Leader>\|1', 'n')
  "   But this returns the \|1 map.
  "     maparg('<Leader>|1', 'n')
  let l:what = substitute(a:what, '\\|', '|', 'g')

  " The long way:
  "   let l:curr_map = ''
  "   redir => l:curr_map
  "   execute a:mode .. 'map ' .. a:what
  "   redir END
  "   let l:curr_map = substitute(l:curr_map, "^\n", '', '')

  let l:curr_map = maparg(l:what, a:mode)

  if l:curr_map == ''

    return
  endif

  echom 'ALERT: vim-reSTfold replaced existing ' .. a:mode .. '_' .. l:what .. ' map'
    \ .. ': ' .. l:curr_map
endfunction

" :h ...
function! g:embrace#reSecTions#EchomCallerMsg(msg, ...) abort
  if !s:trace

    return
  endif

  " THANX to https://vi.stackexchange.com/users/1800/vanlaser
  "   https://vi.stackexchange.com/a/5503
  " https://vi.stackexchange.com/questions/5501/
  "   is-there-a-way-to-get-the-name-of-the-current-function-in-vim-script
  " - REFER: expand('<sfile>') returns, e.g.,
  "     "function embrace#reSecTions#AlertIfMapped"
  "  echo substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
  "
  " Or better yet, get caller's fcn. name so callers don't have to pass.
  " - expand('<stack>') returns, e.g.,
  "     {this-fcn-name}[{lnum}]..{callers-fcn-name}[{lnum}]{..etc.}
  let l:f_stack = expand('<stack>')
  let l:calls = split(l:f_stack, '\[\d\+\]\.\.')
  if len(l:calls) >= 2
    let l:f_name = l:calls[-2]
  else
    let l:f_name = l:calls[0]
  endif

  let l:f_name = substitute(l:f_name, '^function ', '', '')
  let l:f_name = substitute(l:f_name, '^<SNR>\d\+_', '', '')
  let l:f_name = substitute(l:f_name, '\[\d\+\]$', '', '')

  echom l:f_name .. ': ' .. a:msg

  for l:index in range(1, a:0)
    echom get(a:, l:index)
  endfor
endfunction

function! s:ExeAndEchom(command) abort
  if s:trace | echom a:command | endif

  exe a:command
endfunction

" -------------------------------------------------------------------

" USAGE: Pass your own lists if you don't want the defaults.
" - BWARE: This fcn. doesn't make any attempt to validate any
"   list passed as an argument (it just fails).
" - If you want to opt-out of maps for a paricular list, pass
"   an empty array. If you pass something other than an array,
"   then this fcn. uses its default.

function! g:embrace#reSecTions#CreateMaps(
  \ number_punc = 0,
  \ reverse_punc = 0,
  \ simple_punc = 0,
  \ insider_punc = 0,
  \ double_punc = 0,
  \ equal_punc = 0,
  \ pipe_punc = 0,
\) abort
  if type(a:number_punc) == v:t_list
    let l:number_punc = a:number_punc
  else
    let l:number_punc = [
      \ ['1', '!'],
      \ ['2', '@'],
      \ ['3', '#'],
      \ ['4', '$'],
      \ ['5', '%'],
      \ ['6', '^'],
      \ ['7', '&'],
      \ ['8', '*'],
      \ ]
  endif

  " 2017-12-18: Skip underscore. It is not vertically symmetric,
  "   so looks odd, and I'd prefer to be able to Shift-``-`` to
  "   get an upper and lower dash boundary.
  if type(a:reverse_punc) == v:t_list
    let l:reverse_punc = a:reverse_punc
  else
    let l:reverse_punc = [
      \ ['-', '_'],
      \ ]
  endif

  if type(a:simple_punc) == v:t_list
    let l:simple_punc = a:simple_punc
  else
    let l:simple_punc = [
      \ '`', '~', '\', ';', ':', ',', '.', '?', "'", '"',
      \ ]
  endif

  if type(a:insider_punc) == v:t_list
    let l:insider_punc = a:insider_punc
  else
    let l:insider_punc = [
      \ ['(', ')'], [')', '('],
      \ ['[', ']'], [']', '['],
      \ ['{', '}'], ['}', '{'],
      \ ['<', '>'], ['>', '<'],
      \ ['\', '/'], ['/', '\'],
      \ ]
  endif

  if type(a:double_punc) == v:t_list
    let l:double_punc = a:double_punc
  else
    let l:double_punc = [
      \ '(', ')', '[', ']', '{', '}', '<', '>', '\', '/',
      \ ]
  endif

  for [l:knum, l:punc, l:modes] in l:number_punc
    call s:map_shift_only_punctuation_addtext_maps(l:knum, l:punc, l:modes)
  endfor

  for [l:lower, l:upper] in l:reverse_punc
    call s:map_lower_only_punctuation_addtext_maps(l:lower, l:upper)
  endfor

  for l:punc in l:simple_punc
    call s:map_lower_or_upper_punctuation(l:punc)
  endfor

  for [l:lpunc, l:rpunc] in l:insider_punc
    call s:map_insider_punctuation(l:lpunc, l:rpunc)
  endfor

  for l:dunc in l:double_punc
    call s:map_doubled_punctuation(l:dunc)
  endfor

  " Use equal_punc = [] to disable the ten `=` maps.
  " - Note here '0' similar to other args, and means
  "   do the default thing.
  if type(a:equal_punc) == 0
    call s:map_special_key_ten_ways_to_equal()
  endif

  " Use pipe_punc = [] to disable the `\|` and `\||` maps.
  if type(a:pipe_punc) == 0
    call s:map_special_key_pipe_and_double_pipe()
  endif
endfunction

