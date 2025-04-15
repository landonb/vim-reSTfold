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
"   and then switch to normal mode and type <LocalLeader>#,
"   e.g., \#, and your text transforms to:
"
"     #########################
"     My Awesome Section Header
"     #########################

" -------------------------------------------------------------------

" PRIVY: CXREF:
" ~/.kit/docs/source/the_knowledge/Markup__reST.rst

" -------------------------------------------------------------------

" DEVEL:

" Set nonzero to enable `echom` trace.
let s:trace = 0
" For all messages, set 1:
"  let s:trace = 1
" For only the `map` command echo, set 2:
"  let s:trace = 2

" DEVEL: After editing this file:
" - :source the plugin/ to reload all the maps,
"   possibly on your host at:
"     ~/.vim/pack/landonb/start/vim-reSTfold/plugin/vim-reSTfold.vim
"   or call the main function below:
"     call g:embrace#reSecTions#CreateMaps()

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
" <LocalLeader>{char} maps:
"
" - Map <LocalLeader>{char} to underline using the indicated header character.
"
" - Map <LocalLeader>{CHAR} to underline and overline using said character.
"
" - E.g., <LocalLeader>3 underlines with pound symbols,
"     and <LocalLeader># under- and overlines with 'em.
"
" For all the characters, and not just those you access with a
" Shift-number keypress, you can use double-leader instead.
"
" - Note this *does not add* new lines but overwrites what's
"   above and/or below.
"
" - E.g., use double-leader-char to underline:
"
"     <LocalLeader><LocalLeader>{char}
"
"   and use leader-shift-leader-char to add both:
"
"     <LocalLeader><Shift-LocalLeader>{char}
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
"     and press <LocalLeader><LocalLeader>#, you'll get this:
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

" -------------------------------------------------------------------

function! s:map_shift_only_punctuation_addline_normal_under(keych, delim, ftypes) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim)

  let l:seq = s:leader . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:delim .. s:up_n, a:ftypes, 'Draw rst under-border: ' .. a:delim)
endfunction

function! s:map_shift_only_punctuation_addline_normal_hilow(keych, delim, ftypes, extra) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:delim .. s:yank_up_putbefore_down_n, a:ftypes, 'Draw rst double-border: ' .. a:delim)
endfunction

" ***

function! s:map_shift_only_punctuation_addline_insert_under(keych, delim, ftypes) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim)

  let l:seq = s:leader . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i', a:ftypes)
  " MAYBE/2019-02-09: Use function, and restore cursor position. For now, goes to first character of line.
  call s:MapAndEchom('i', l:seq, '<ESC>' .. s:yank_put_replace_n .. a:delim .. s:up_n .. 'i', a:ftypes, 'Draw rst under-border: ' .. a:delim)
endfunction

function! s:map_shift_only_punctuation_addline_insert_hilow(keych, delim, ftypes, extra) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i', a:ftypes)
  call s:MapAndEchom('i', l:seq, '<ESC>' .. s:yank_put_replace_n .. a:delim .. s:yank_up_putbefore_down_n .. 'i', a:ftypes, 'Draw rst double-border: ' .. a:delim)
endfunction

" ***

function! s:map_shift_only_punctuation_replace_normal_under(keych, delim, ftypes, extra = s:leader) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:delete_line_under_n .. s:yank_put_replace_n .. a:delim .. s:up_n, a:ftypes, 'Replace rst under-border: ' .. a:delim)
endfunction

" :help function-argument

function! s:map_shift_only_punctuation_replace_normal_hilow(keych, delim, ftypes, extra = s:leader) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:delete_line_above_n .. s:delete_line_under_n .. s:yank_put_replace_n .. a:delim .. s:yank_up_putbefore_down_n, a:ftypes, 'Replace rst double-border: ' .. a:delim)
endfunction

" ***

function! s:map_shift_only_punctuation_replace_insert_under(keych, delim, ftypes, extra = s:leader) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i', a:ftypes)
  " ALTLY: Same outcome, but without leaving insert mode, e.g.:
  "   inoremap <LocalLeader><LocalLeader>= <DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  call s:MapAndEchom('i', l:seq, '<ESC>' .. s:delete_line_under_n .. s:yank_put_replace_n .. a:delim .. s:up_n .. 'i', a:ftypes, 'Replace rst under-border: ' .. a:delim)
endfunction

function! s:map_shift_only_punctuation_replace_insert_hilow(keych, delim, ftypes, extra = s:leader) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:keych . ':' . a:delim . ':' . a:extra)

  let l:seq = s:leader . a:extra . a:keych
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'i', a:ftypes)
  " ALTLY: Same outcome, but without leaving insert mode, e.g.:
  "   inoremap <LocalLeader><LocalLeader>+ <UP><C-O>dd<DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  call s:MapAndEchom('i', l:seq, '<ESC>' .. s:delete_line_above_n .. s:delete_line_under_n .. s:yank_put_replace_n .. a:delim .. s:yank_up_putbefore_down_n .. 'i', a:ftypes, 'Replace rst double-border: ' .. a:delim)
endfunction

" ***

function! s:map_shift_only_punctuation_addtext_maps(knum, punc, n_fts, i_fts) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:knum . ':' . a:punc)

  if a:n_fts != ''
    call s:map_shift_only_punctuation_addline_normal_under(a:knum, a:punc, a:n_fts)
    call s:map_shift_only_punctuation_addline_normal_hilow(a:punc, a:punc, a:n_fts, '')
    call s:map_shift_only_punctuation_replace_normal_under(a:knum, a:punc, a:n_fts)
    call s:map_shift_only_punctuation_replace_normal_hilow(a:punc, a:punc, a:n_fts)
    " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
    call s:map_shift_only_punctuation_addline_normal_hilow(a:knum, a:punc, a:n_fts, s:leader_two)
    call s:map_shift_only_punctuation_addline_normal_hilow(a:punc, a:punc, a:n_fts, s:leader_two)
  endif
  
  if a:i_fts != ''
    call s:map_shift_only_punctuation_addline_insert_under(a:knum, a:punc, a:i_fts)
    call s:map_shift_only_punctuation_addline_insert_hilow(a:punc, a:punc, a:i_fts, '')
    call s:map_shift_only_punctuation_replace_insert_under(a:knum, a:punc, a:i_fts)
    call s:map_shift_only_punctuation_replace_insert_hilow(a:punc, a:punc, a:i_fts)
    " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
    call s:map_shift_only_punctuation_addline_insert_hilow(a:knum, a:punc, a:i_fts, s:leader_two)
    call s:map_shift_only_punctuation_addline_insert_hilow(a:punc, a:punc, a:i_fts, s:leader_two)
  endif

  if s:trace | echom ' ' | endif
endfunction

" ***

" Only called for '-' (see l:reverse_punc = [['-', '_']])
function! s:map_lower_only_punctuation_addtext_maps(lower, upper, n_fts, i_fts) abort
  call g:embrace#reSecTions#EchomCallerMsg('keych:delim: ' . a:lower . ':' . a:upper)

  if a:n_fts != ''
    call s:map_shift_only_punctuation_addline_normal_under(a:lower, a:lower, a:n_fts)
    call s:map_shift_only_punctuation_addline_normal_hilow(a:upper, a:lower, a:n_fts, '')
    call s:map_shift_only_punctuation_replace_normal_under(a:lower, a:lower, a:n_fts)
    call s:map_shift_only_punctuation_replace_normal_hilow(a:upper, a:lower, a:n_fts)
    " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
    call s:map_shift_only_punctuation_addline_normal_hilow(a:lower, a:lower, a:n_fts, s:leader_two)
    call s:map_shift_only_punctuation_addline_normal_hilow(a:upper, a:lower, a:n_fts, s:leader_two)
  endif

  if a:i_fts != ''
    call s:map_shift_only_punctuation_addline_insert_under(a:lower, a:lower, a:i_fts)
    call s:map_shift_only_punctuation_addline_insert_hilow(a:upper, a:lower, a:i_fts, '')
    call s:map_shift_only_punctuation_replace_insert_under(a:lower, a:lower, a:i_fts)
    call s:map_shift_only_punctuation_replace_insert_hilow(a:upper, a:lower, a:i_fts)
    " The leader-pipe maps are redundant but included for parity with, e.g., ``\|;``.
    call s:map_shift_only_punctuation_addline_insert_hilow(a:lower, a:lower, a:i_fts, s:leader_two)
    call s:map_shift_only_punctuation_addline_insert_hilow(a:upper, a:lower, a:i_fts, s:leader_two)
  endif

  if s:trace | echom ' ' | endif
endfunction

" ***

function! s:map_lower_or_upper_punctuation(punc, ftypes) abort
  call g:embrace#reSecTions#EchomCallerMsg('punc: ' . a:punc)

  if a:ftypes == ''

    return
  endif

  let l:seq = s:leader . a:punc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:punc .. s:up_n, a:ftypes, 'Draw rst under-border: ' .. a:punc)

  let l:seq = s:leader . s:leader_two . a:punc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:punc .. s:yank_up_putbefore_down_n, a:ftypes, 'Draw rst double-border: ' .. a:punc)
endfunction

" (((((((((((((((((((((((((((((((((((
" Inside Inside Inside The Delimiters
" )))))))))))))))))))))))))))))))))))
function! s:map_insider_punctuation(lpunc, rpunc, ftypes) abort
  call g:embrace#reSecTions#EchomCallerMsg('lpunc:rpunc: ' . a:lpunc . ':' . a:rpunc)

  if a:ftypes == ''

    return
  endif

  let l:seq = s:leader . a:lpunc . a:rpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, 'yyP<C-Q>$r' .. a:lpunc .. '<DOWN>yyp<C-Q>$r' .. a:rpunc .. '<UP>', a:ftypes, 'Draw rst double-border: ' .. a:lpunc .. a:rpunc)
endfunction

function! s:map_doubled_punctuation(dpunc, ftypes) abort
  call g:embrace#reSecTions#EchomCallerMsg('dpunc: ' . a:dpunc)

  if a:ftypes == ''

    return
  endif

  let l:seq = s:leader . a:dpunc . a:dpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:dpunc .. '<UP>', a:ftypes, 'Draw rst under-border: ' .. a:dpunc)

  let l:seq = s:leader . s:leader_two . a:dpunc . a:dpunc
  call g:embrace#reSecTions#AlertIfMapped(l:seq, 'n', a:ftypes)
  call s:MapAndEchom('n', l:seq, s:yank_put_replace_n .. a:dpunc .. 'yykP' .. '<DOWN>', a:ftypes, 'Draw rst double-border: ' .. a:dpunc)
endfunction

" -------------------------------------------------------------------

function! s:map_special_key_ten_ways_to_equal(punc = '=', altk = '+', n_fts = '*', i_fts = '*') abort
  call g:embrace#reSecTions#EchomCallerMsg('keyseqs: \= \+ \|+ \\= \\+')

  " We don't use '+' as a section delimiter because the
  "   reST syntax parser sees that as a table delimiter.
  " Instead, map <LocalLeader>= to under-section with equal signs
  "   and then map <LocalLeader>+ to over-under-section with equals.
  "
  "   =======
  "   SECTION
  "   =======
  "
  " Creates essentially these three maps:
  "   nnoremap <LocalLeader>= yyp<C-Q>$r=<UP>
  "   nnoremap <LocalLeader>+ yyp<C-Q>$r=yykP<DOWN>
  "   nnoremap <LocalLeader>\|+ yyp<C-Q>$r=yykP<DOWN>
  if a:n_fts != ''
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. a:punc, 'n', a:n_fts)
    call s:map_shift_only_punctuation_addline_normal_under(a:punc, a:punc, a:n_fts)
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. a:altk, 'n', a:n_fts)
    call s:map_shift_only_punctuation_addline_normal_hilow(a:altk, a:punc, a:n_fts, '')
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader_two .. a:altk, 'n', a:n_fts)
    call s:map_shift_only_punctuation_replace_normal_hilow(a:altk, a:punc, a:n_fts, s:leader_two)
  endif

  " Creates essentially these three maps:
  "   inoremap <LocalLeader>= <C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  "   inoremap <LocalLeader>+ <C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  "   inoremap <LocalLeader>\|+ <C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  if a:i_fts != ''
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. a:punc, 'i', a:i_fts)
    call s:map_shift_only_punctuation_addline_insert_under(a:punc, a:punc, a:i_fts)
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. a:altk, 'i', a:i_fts)
    call s:map_shift_only_punctuation_addline_insert_hilow(a:altk, a:punc, a:i_fts, '')
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader_two .. a:altk, 'i', a:i_fts)
    call s:map_shift_only_punctuation_replace_insert_hilow(a:altk, a:punc, a:i_fts, s:leader_two)
  endif

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
  "
  " Creates essentially these three maps:
  "   nnoremap <LocalLeader><LocalLeader>= <DOWN>dd<UP>yyp<C-Q>$r=<UP>
  "   nnoremap <LocalLeader><LocalLeader>+ <UP>dd<DOWN>dd<UP>yyp<C-Q>$r=yykP<DOWN>
  if a:n_fts != ''
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader .. a:punc, 'n', a:n_fts)
    call s:map_shift_only_punctuation_replace_normal_under(a:punc, a:punc, a:n_fts, s:leader)
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader .. a:altk, 'n', a:n_fts)
    call s:map_shift_only_punctuation_replace_normal_hilow(a:altk, a:punc, a:n_fts, s:leader)
  endif

  " Creates essentially these three maps:
  "   inoremap <LocalLeader><LocalLeader>= <DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<UP>
  "   inoremap <LocalLeader><LocalLeader>+ <UP><C-O>dd<DOWN><C-O>dd<UP><C-O>yy<C-O>p<C-O><C-Q>$r=<C-O>yy<C-O>k<C-O>P<DOWN>
  if a:i_fts != ''
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader .. a:punc, 'i', a:i_fts)
    call s:map_shift_only_punctuation_replace_insert_under(a:punc, a:punc, a:i_fts, s:leader)
    call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader .. a:altk, 'i', a:i_fts)
    call s:map_shift_only_punctuation_replace_insert_hilow(a:altk, a:punc, a:i_fts, s:leader)
  endif
endfunction

" ***

function! s:map_special_key_pipe_and_double_pipe(keyc = '\|', punc = '\|', n_fts = '*') abort
  call g:embrace#reSecTions#EchomCallerMsg('keyseqs: \| \||')

  " The pipe character is not sent to map_lower_or_upper_punctuation
  " because it needs to be escaped.
  " Creates essentially these three maps:
  "   nnoremap <LocalLeader>\| yyp<C-Q>$r\|<UP>
  "   nnoremap <LocalLeader>\|\| yyp<C-Q>$r\|yykP<DOWN>
  call g:embrace#reSecTions#AlertIfMapped(s:leader .. a:keyc, 'n', a:n_fts)
  call s:map_shift_only_punctuation_addline_normal_under(a:keyc, a:punc, a:n_fts)
  call g:embrace#reSecTions#AlertIfMapped(s:leader .. s:leader_two .. a:keyc, 'n', a:n_fts)
  call s:map_shift_only_punctuation_addline_normal_hilow(a:keyc, a:punc, a:n_fts, s:leader_two)
endfunction

" -------------------------------------------------------------------

function! g:embrace#reSecTions#AlertIfMapped(what, mode, ftypes) abort
  if get(g:, 'vim_restfold_alert_disable', 0)

    return
  endif

  if a:ftypes != '*'
    " MAYBE: Use redir to check if `au FileType {ftypes}` have map.
    " - Unless there's an easier way?
    "
    " E.g.:
    "   let l:curr_map = ''
    "   redir => l:curr_map
    "   execute a:mode .. 'map ' .. a:what
    "   redir END
    "   let l:curr_map = substitute(l:curr_map, "^\n", '', '')

    return
  endif

  " Note that we delimit pipes \| for the map calls, but not for maparg.
  " - E.g., this returns empty string:
  "     maparg('<LocalLeader>\|1', 'n')
  "   But this returns the \|1 map.
  "     maparg('<LocalLeader>|1', 'n')
  let l:what = substitute(a:what, '\\|', '|', 'g')


  let l:curr_map = maparg(l:what, a:mode)

  if l:curr_map == ''

    return
  endif

  echom 'ALERT: vim-reSTfold replaced existing ' .. a:mode .. '_' .. l:what .. ' map'
    \ .. ': ' .. l:curr_map
endfunction

" :h ...
function! g:embrace#reSecTions#EchomCallerMsg(msg, level = 1) abort
  if !s:trace || s:trace > a:level

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

" If Neovim, use vim.keymap.set (so we can set desc), or fallback ex command in Vim.
function! s:MapAndEchom(mode, lhs, rhs, ftypes, desc = 'reSecTions') abort
  let l:command = ''
  if has('nvim')
    let l:buffer_map = a:ftypes == '*' ? 'false' : 'true'
    let l:command = 'lua vim.keymap.set('
      \ .. '"' .. a:mode .. '", "'
      \ .. s:escapeInput(a:lhs) .. '", "'
      \ .. s:escapeInput(a:rhs) .. '", '
      \ .. '{ noremap = true, buffer = ' .. l:buffer_map
      \ .. ', desc = "' .. s:escapeInput(a:desc) .. '"})'
  else
    let l:buffer_map = a:ftypes == '*' ? '' : '<buffer> '
    let l:command = a:mode .. 'noremap ' .. l:buffer_map .. a:lhs .. ' ' .. a:rhs
  endif

  if a:ftypes != '*'
    let l:command = 'autocmd Filetype ' .. a:ftypes .. ' ' .. l:command
  endif

  if s:trace >= 2 | echom l:command | endif

  exe l:command
endfunction

function! s:escapeInput(input) abort
  let l:escaped = a:input
  let l:escaped = substitute(l:escaped, "\\", "\\\\\\", "g")
  let l:escaped = substitute(l:escaped, "\"", "\\\\\"", "g")
  return l:escaped
endfunction

" -------------------------------------------------------------------

" USAGE: Pass your own lists if you don't want the defaults.
" - BWARE: This fcn. doesn't make any attempt to validate any
"   list passed as an argument (it just fails).
" - If you want to opt-out of maps for a paricular list, pass
"   an empty array. If you pass something other than an array,
"   then this fcn. uses its default.

function! g:embrace#reSecTions#CreateMaps(
  \ leader_key = '<LocalLeader>',
  \ leader_two = '\|',
  \ number_punc = 0,
  \ reverse_punc = 0,
  \ simple_punc = 0,
  \ insider_punc = 0,
  \ double_punc = 0,
  \ equal_punc = 0,
  \ pipe_punc = 0,
\) abort
  let s:leader = a:leader_key
  let s:leader_two = a:leader_two

  " ***

  if type(a:number_punc) == v:t_list
    let l:number_punc = a:number_punc
  else
    let l:number_punc = [
      \ ['1', '!', '*', 'rst'],
      \ ['2', '@', '*', 'rst'],
      \ ['3', '#', '*', 'rst'],
      \ ['4', '$', 'rst', 'rst'],
      \ ['5', '%', 'rst', 'rst'],
      \ ['6', '^', '*', 'rst'],
      \ ['7', '&', 'rst', 'rst'],
      \ ['8', '*', '*', 'rst'],
      \ ]
  endif
  "       ┃    ┃    ┃     ┗━━ Insert mode FileType
  "       ┃    ┃    ┃           Set '*' for all filetypes (normal nmap/imap)
  "       ┃    ┃    ┃           Set '{ft},{ft}' for specific filetypes
  "       ┃    ┃    ┃           Set '' to disable the map
  "       ┃    ┃    ┗━━━━━━━━ Normal mode FileType
  "       ┃    ┗━━━━━━━━━━━━━ Section delimiter to paint
  "       ┃                     Mapped at <LocalLeader>{punct} etc.
  "       ┗━━━━━━━━━━━━━━━━━━ Lowercase key sequence user can use
  "                             Mapped at <LocalLeader>{number} etc.

  " 2017-12-18: Skip underscore. It is not vertically symmetric, so looks
  " odd, and I'd prefer to be able to <LocalLeader>Shift-`-` to get an
  " upper and lower dash boundary.
  if type(a:reverse_punc) == v:t_list
    let l:reverse_punc = a:reverse_punc
  else
    " Reverse because this inserts '-' when (lowercase) '-' pressed
    " (unlike, e.g., inserting '#' when (lowercase) '3' is pressed).
    let l:reverse_punc = [
      \ ['-', '_', '*', 'rst'],
      \ ]
  endif

  if type(a:simple_punc) == v:t_list
    let l:simple_punc = a:simple_punc
  else
    let l:simple_punc = [
      \ ['`', 'rst'],
      \ ['~', 'rst'],
      \ ['\', ''],
      \ [';', 'rst'],
      \ [':', 'rst'],
      \ [',', 'rst'],
      \ ['.', 'rst'],
      \ ['?', ''],
      \ ["'", 'rst'],
      \ ['"', 'rst'],
      \ ]
  endif

  " Omit ] to not take <LocalLeader>] which might be a popular leader-leader2
  " choice for other plugins, e.g., a user might create vim-easymotion maps
  " under \]. (Not that we should talk, we take a *lot* of localleader combos —
  " and though both <LocalLeader> and <Leader2> are configurable (via
  " a:leader_key and a:leader_two), assume the user has not changed them, and
  " avoid obvious <LocalLeader><Leader2> sequences.)
  if type(a:insider_punc) == v:t_list
    let l:insider_punc = a:insider_punc
  else
    " USAGE: Set ftype non-empty to enable those maps.
    " - E.g., in list below, <LocalLeader>[] enabled, but not <LocalLeader>][
    let l:insider_punc = [
      \ ['(', ')', 'rst'],
      \ [')', '(', 'rst'],
      \ ['[', ']', 'rst'],
      \ [']', '[', ''],
      \ ['{', '}', 'rst'],
      \ ['}', '{', 'rst'],
      \ ['<', '>', 'rst'],
      \ ['>', '<', 'rst'],
      \ ['\', '/', ''],
      \ ['/', '\', 'rst'],
      \ ]
  endif

  if type(a:double_punc) == v:t_list
    let l:double_punc = a:double_punc
  else
    let l:double_punc = [
      \ ['(', 'rst'],
      \ [')', 'rst'],
      \ ['[', 'rst'],
      \ [']', ''],
      \ ['{', 'rst'],
      \ ['}', 'rst'],
      \ ['<', 'rst'],
      \ ['>', 'rst'],
      \ ['\', ''],
      \ ['/', 'rst'],
      \ ]
  endif

  if type(a:equal_punc) == v:t_list
    let l:equal_punc = a:equal_punc
  else
    let l:equal_punc = [
      \ ['=', '+', '*', 'rst'],
      \ ]
  endif

  if type(a:pipe_punc) == v:t_list
    let l:pipe_punc = a:pipe_punc
  else
    let l:pipe_punc = [
      \ ['\|', '\|', 'rst'],
      \ ]
  endif

  " ***

  augroup vim-reSTfold
    au!

    for [l:knum, l:punc, l:n_fts, l:i_fts] in l:number_punc
      call s:map_shift_only_punctuation_addtext_maps(l:knum, l:punc, l:n_fts, l:i_fts)
    endfor

    for [l:lower, l:upper, l:n_fts, l:i_fts] in l:reverse_punc
      call s:map_lower_only_punctuation_addtext_maps(l:lower, l:upper, l:n_fts, l:i_fts)
    endfor

    for [l:punc, l:n_fts] in l:simple_punc
      call s:map_lower_or_upper_punctuation(l:punc, l:n_fts)
    endfor

    for [l:lpunc, l:rpunc, l:n_fts] in l:insider_punc
      call s:map_insider_punctuation(l:lpunc, l:rpunc, l:n_fts)
    endfor

    for [l:dpunc, l:n_fts] in l:double_punc
      call s:map_doubled_punctuation(l:dpunc, l:n_fts)
    endfor

    for [l:punc, l:altk, l:n_fts, l:i_fts] in l:equal_punc
      call s:map_special_key_ten_ways_to_equal(l:punc, l:altk, l:n_fts, l:i_fts)
    endfor

    for [l:keyc, l:punc, l:n_fts] in l:pipe_punc
      call s:map_special_key_pipe_and_double_pipe(l:keyc, l:punc, l:n_fts)
    endfor
  augroup END
endfunction

