" File: dubs_rest_fold/after/ftplugin/rst.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project Page: https://github.com/landonb/dubs_rest_fold
" Summary: Additional reST syntax highlighting
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:
" -------------------------------------------------------------------
" Copyright © 2017-2018 Landon Bouma.
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

" 2018-12-07: See the reST syntax file included with Vim:
"   /srv/opt/bin/share/vim/vim81/syntax/rst.vim
" And the more current upstream source of the same:
"   https://github.com/marshallward/vim-restructuredtext

" +----------------------------------------------------------------------+

" *** DEV. UTIL. FCN.: Log message to file (b/c `echom` doesn't work from syntax).

" 2018-12-07: Log to file, inspired by lervag@github: b/c cannot echom from syntax file?
"   https://github.com/lervag/dotvim/blob/master/personal/plugin/log-autocmds.vim
function! s:log(message)
  silent execute '!echo "'
    \ . strftime('%T', localtime()) . ' - ' . a:message . '"'
    \ '>> /tmp/vim_log_dubs_after_syntax_rst'
endfunction

" NOTE: [lb]: I can `call s:log('...')` and `tail -F /tmp/vim_log_dubs_after_syntax_rst`
"       successfully. But I cannot `echom '...'` anything. Not sure why.

" +----------------------------------------------------------------------+

" *** SYNTAX GROUP: reST section highlighting.

function! s:DubsClr_rstSections()
  " reST header syntax can use any of the 32 punctation keys found on a US keyboard:
  "
  "   ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
  "
  " The documentation recommends using a subset of those, because "some characters
  " are more suitable than others":
  "
  "   = - ` : . ' " ~ ^ _ * + #
  "
  " Omitted from included rst syntax runtime:
  "
  "   ! $ % & ( ) , / ; < > ? @ [ \ ] { | }
  "
  " Although I'd respond that that's really user preference, and that the syntax
  " plugin should honor what reST itself honors. (I'd concede this might not be
  " the case if certain punctuation is used in a way that's not for headerizing,
  " but that might be interpreted as such, e.g., a merge conflict uses angle
  " brackets in such a way:
  "
  "   <<<<<<<<<<<<<<
  "   some code
  "   ==============
  "   other code
  "   >>>>>>>>>>>>>>
  "
  " and we wouldn't want any of this to be interpreted as headerization.
  " (But such code would most likely be in a block quote, anyway.)
  "
  " I'm adding in the missing punctuation and we'll see how it goes.
  "
  " (What I really want is a few more 'Big' symbols that'll look good
  " as the main, top-level section. I currently use '#', which is the
  " character that uses the most ink of all available characters. But
  " I think '$', '@', and '&' could also work to convey main-sectionness.)
  syn clear rstSections
endfunction

function! s:DubsSyn_rstSections()
  " Add the missing punctuation characters to reST header syntax matching:
  "
  "   !@$%&()[]{}<>/\|,;?
  "
  " [lb]: We use "very magic" regex to make non-counting groups.
  "
  "       See:
  "
  "         :h pattern-overview
  "
  "       Enable very magic regex:
  "
  "         /\v  \v  \v   the following chars in the pattern are "very magic"
  "
  "       Use a non-counting match group, %(...):
  "
  "         \%(\)         A pattern enclosed by escaped parentheses.
  "         Just like \(\), but without counting it as a sub-expression.
  "         This allows using more groups and it's a little bit faster.
  "
  "       See also:
  "
  "         :h literal-string
  "
  "       which explains why we use double quotes and not single quotes,
  "       because we want to use the escaped character, "\v", and
  "       not the two characters, slash and v, '\v' (or "\\v").
  "
  " NOTE: `-` must come last so it is not interpreted as range.
  "
  " NOTE: `+` does not highlight when used both below and above,
  "             because it's interpreted as rstTableLines.
  syn match rstSections "\v^%(([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\2{2,}$" contains=@Spell
endfunction

" +----------------------------------------------------------------------+

" *** SYNTAX GROUP: Passwords.

" 2018-12-07: Syntax Profiling: Top performance drag: PasswordPossibly.
"
" [lb]: On a 7k-line file that takes 5.5 secs. to parse, PasswordPossibly eats 1.75 s!
" (To test: `:syntime clear`, `:syntime on`, open the reST document, read the results
" using `:TabMessage syntime report`.)
"
function! s:DubsSyn_PasswordPossibly()
  " Match "passwords" (why would you have those in a text file??).
  " Inspired by:
  "   https://dzone.com/articles/use-regex-test-password
  "   var strongRegex = new RegExp(
  "     "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})"
  "   );
  " But completely Vimified! E.g., Perl's look-ahead (?=) is Vim's \(\)\@=
  " HINT: To test, run ``syn clear``, then try the new ``syn match``.
  " NOTE: \@= is Vim look-ahead. I also tried \@<= look-behind but it didn't work for me.
  " NOTE: Do this before EmailNoSpell, so that we don't think emails are passwords.
  " NOTE: Trying {15,16} just to not match too much.
  " CUTE: If I misspell a normal FIXME/YYYY-MM-DD comment, e.g.,
  "       "FiXME/2018-03-21", then it gets highlighted as a password! So cute!!
  syn match PasswordPossibly '\([[:space:]\n]\)\@<=\([^[:space:]]*[a-z][^[:space:]]*\)\@=\([^[:space:]]*[A-Z][^[:space:]]*\)\@=\([^[:space:]]*[0-9][^[:space:]]*\)\@=\<[^[:space:]]\{16,24\}\([[:space:]\n]\)\@=' contains=@NoSpell
  " NOTE: We don't need a Password15Best to include special characters unless
  "       we wanted to color them differently; currently, such passwords will
  "       match PasswordPossibly.
  hi def PasswordPossibly term=reverse guibg=DarkRed guifg=Yellow ctermfg=1 ctermbg=6
endfunction

" *** SYNTAX GROUP: Acronyms.

function! s:DubsSyn_AcronymNoSpell()
  " Thanks!
  "   http://www.panozzaj.com/blog/2016/03/21/
  "     ignore-urls-and-acroynms-while-spell-checking-vim/

  " WEIRD: [lb]: Why did I make this filter? Oh! Because that new Vim syntax
  "   code I tried (vim-restructuredtext) was not highlighting URLs? Or was
  "   it working, but I just didn't notice? In any case, the Vim system
  "   rst.vim syntax highlighter has a rstStandaloneHyperlink group, which
  "   we don't want to override. Which means don't do this:
  "     " `Don't mark URL-like things as spelling errors`
  "     syn match UrlNoSpell '\w\+:\/\/[^[:space:]]\+' contains=@NoSpell

  " `Don't count acronyms / abbreviations as spelling errors
  "  (all upper-case letters, at least three characters)
  "  Also will not count acronym with 's' at the end a spelling error
  "  Also will not count numbers that are part of this`
  syn match AcronymNoSpell '\<\(\u\|\d\)\{3,}s\?\>' contains=@NoSpell
endfunction

" *** SYNTAX GROUP: Email Addys, Without Spelling Error Highlight.

" Syntax Profiling: EmailNoSpell takes second longest, behind DubsSyn_PasswordPossibly.
" (From a 7K line reST that takes 3.76 secs. to load, EmailNoSpell consumes 0.21 secs.)

function! s:DubsSyn_EmailNoSpell()
  " (lb) added this to ignore spelling errors on words such as `emails@somewhere.com`.
  " NOTE: Look-behind: \([[:space:]\n]\)\@<= ensures space or newline precedes match.
  " NOTE: Look-ahead:  \([[:space:]\n]\)\@=  ensures space or newline follows  match.
  syn match EmailNoSpell '\([[:space:]\n]\)\@<=\<[^[:space:]]\+@[^[:space:]]\+\.\(com\|org\|edu\|us\|io\)\([^[:alnum:]]\|\n\)\@=' contains=@NoSpell
  hi def EmailNoSpell guifg=LightGreen
endfunction

function! s:DubsSyn_AtHostNoSpell()
  " (lb) added this to ignore spelling errors on words such as `@somehost`,
  " which is a convention I've been using recently to identify what could
  " also be referred to as ``host``, but @host is cleaner.
  " NOTE: Look-behind: \([[:space:]\n]\)\@<= ensures space or newline precedes match.
  " NOTE: Look-ahead:  \([[:space:]\n]\)\@=  ensures space or newline follows  match.
  syn match AtHostNoSpell '\([[:space:]\n]\)\@<=@[^.,:\[:space:]\n]\+\([.,:[:space:]\n]\)\@=' contains=@NoSpell
  " Both LightMagenta and LightRed look good here. Not so much any other Light's.
  hi def AtHostNoSpell guifg=LightMagenta
endfunction

" HINT: You can `hi clear {group-name}` and `hi def...` in a reST file to live-test.
"       But for `syn clear ...` and `syn match ...` you need to `:e` reload the file
"       (or `do Syntax`/`doautocmd Syntax` (`syntax sync fromstart` did not work FM)).

" 2021-01-16 17:39... just had this idea.
" Ref:
"   :h /character-classes
"   :h gui-colors
function! s:DubsSyn_CincoWords_EVERY()
  " Let's not highlight all CINCO words that appear alone (surrounded by
  " whitespace), otherwise we'll highlight acronyms we don't intend to
  " emphasize (such as STOCK symbols).
  " - But let's highlight CINCO words followed by a forward slash. This
  "   assumes that that format ('CINCO/') is generally only used in the
  "   context of something you want to emphasize, e.g.,
  "     'CINCO/2021-01-19 00:08: Some note'.

  syn match CincoWordsEVERY '\([[:space:]\n\[(#]\)\@<=[[:upper:]]\{5}\([/]\)\@=' contains=@NoSpell
  "                                                  The lone slash ^

  " Not as bright a yellow, to be less noticeable than CincoWordsUPPER.
  hi def CincoWordsEVERY guifg=#caf751
endfunction

function! s:DubsSyn_CincoWords_UPPER()
  " Highlight *actionable* CINCO words specially. CINCO CTAs. (Or CsTA?)
  " - Use case: You want to visually scan a notes file quickly looking
  "             for FIXME notes and other tasks you can work on.
  "             *Calls to Action*

  " YOU: Modify this list to your liking.

  let l:cincos = []

  " *** Most used action CINCOs ((lb): that I use).
  let l:cincos = add(l:cincos, 'FIXME')  " Want to do 'now'.
  let l:cincos = add(l:cincos, 'LATER')  " Want to do ... eventually.
  let l:cincos = add(l:cincos, 'MAYBE')  " Not sure if you want to do.

  let l:cincos = add(l:cincos, 'SPIKE')  " Agile meaning
  let l:cincos = add(l:cincos, 'LEARN')  " Articles, books, technology
  let l:cincos = add(l:cincos, 'STUDY')  " Similar to LEARN
  let l:cincos = add(l:cincos, 'WATCH')  " Videos to WATCH (or maybe
                                         "  issues to keep an eye on,
                                         "  like TRACK?)

  let l:cincos = add(l:cincos, 'TRACK')  " For keeping vigilant
  let l:cincos = add(l:cincos, 'AWAIT')  " For future events

  let l:cincos = add(l:cincos, 'ORDER')  " As in shopping.

  let l:cincos = add(l:cincos, 'CHORE')  " Around the house, or code
  let l:cincos = add(l:cincos, 'AUDIT')  " You need to review something
  let l:cincos = add(l:cincos, 'CHECK')  " Similar to AUDIT
  let l:cincos = add(l:cincos, 'REPLY')  " As in email or persons

  " *** Less used action CINCOs.
  let l:cincos = add(l:cincos, 'TODAY')
  let l:cincos = add(l:cincos, 'DAILY')
  let l:cincos = add(l:cincos, 'RECUR')
  let l:cincos = add(l:cincos, 'TRYME')
  let l:cincos = add(l:cincos, 'TWEAK')

  " *** Not really actions...
  let l:cincos = add(l:cincos, 'HRMMM')
  let l:cincos = add(l:cincos, 'MEHHH')
  let l:cincos = add(l:cincos, 'BONUS')
  let l:cincos = add(l:cincos, 'OOOPS')

  " END: Said list as you wish.

  let l:cinco_re = join(l:cincos, '\|')
  let l:cinco_pat = '\([[:space:]\n\[(#]\)\@<=\(' . l:cinco_re . '\)\([.,:/[:space:]\n]\)\@='
  let l:syn_cmd = "syn match CincoWordsUPPER '" . l:cinco_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  " HRMMM/2021-01-19: Yellow without bold is almost more striking.
  "  MAYBE: CincoWordsEVERY is Yellow but not bold; maybe change its color.
  hi def CincoWordsUPPER guifg=Yellow gui=bold cterm=bold
endfunction

" MAYBE/2021-01-16 18:39: Consider available attrs:
"
"   bold, underline, undercurl, strikethrough, italic, reverse (inverse), standout
"
" The standout vs reverse (aka inverse) option is interesting.
" - The same style can be done different ways,
"   e.g., these three are similar:
"     hi def foo guifg=Black guibg=Purple
"     hi def foo guifg=Purple guibg=Black gui=reverse
"     hi def foo guifg=Purple guibg=Black gui=inverse
"     hi def foo guifg=Purple guibg=Black gui=standout
"   but I think the text in standout is more readable (a little fatter).
"
" Useful? Maybe for testing?:
"   nocombine   override attributes instead of combining them
"   NONE

" TRACK/2021-02-19: MacVim does not support strikethrough.
" - Issue opened April, 2020, but no traction since?
"   https://github.com/macvim-dev/macvim/issues/1034

function! s:DubsSyn_CincoWords_FIXED()
  syn match CincoWordsFIXED '\([[:space:]\n\[(#]\)\@<=FIXED\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  " NOTE: GTK gVim uses `gui=`,
  "       terminal Vim uses `cterm=`,
  "       I'm not sure what uses `term=`.
  hi def CincoWordsFIXED guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" SPOKE is the finished state of SPIKE. (I'll admit it, I got nothing better! At least it's something.)
function! s:DubsSyn_CincoWords_SPOKE()
  syn match CincoWordsSPOKE '\([[:space:]\n\[(#]\)\@<=SPOKE\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  hi def CincoWordsSPOKE guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

function! s:DubsSyn_CincoWords_TBLLC()
  syn match CincoWordsTBLLC '\([[:space:]\n\[(#]\)\@<=TBLLC\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  hi def CincoWordsTBLLC guifg=#198CCF
endfunction

function! s:DubsSyn_CincoWords_TAXES()
  syn match CincoWordsTAXES '\([[:space:]\n\[(#]\)\@<=TAXES\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  hi def CincoWordsTAXES guifg=#00a15b gui=bold cterm=bold
endfunction

" +----------------------------------------------------------------------+

" *** (p)reST(o) reST extension: reSTrule: Pseudo-Horizontal Rule Highlights

function! s:Presto_HRrules()
  " 2018-01-30: NUTS!
  "
  "   This is pretty cool. And it only serves one purpose:
  "     Making me color-happy when reSTing.
  "   That is, if I repeat the same character 8 or more times
  "     on its own line, it'll be highlighted!
  "   You can fiddle with the highlights for specific characters
  "     below.
  "   In this way, you can create more visually appealing reST
  "     documents, and you can more easily highlight section
  "     headers, as well as section delimiters!

  " - The HR match interferes with rstSections, whether it's defined before or
  "   after, and I'm not sure what's up, so only highlight when HR is followed
  "   by newlines, to avoid conflict.
  "   - (And note that `\n\n` sorta works, but the highlight only works if
  "      there are two trailing blank lines; whereas using just `\n` works,
  "      but then the top line of a real section header gets hijack-highlighted
  "      (the top line of the header should be rstSections like the header
  "      title and the bottom line of the header, but instead the top line
  "      gets a rstFakeHRAll match).
  "
  " - Note that the captured (.) character \1 matches case-insensitively.
  "   - E.g., `e` will match `E`, so
  "       EEeeeeEEEEEEeee
  "     will match.
  "   - There's probably a way to match case-sensitively but meh.
  "
  " Match lines with the same character repeating 8 or more times,
  " with optional preceding and trailing whitespace.
  syn match rstFakeHRAll   '^\n\s*\(.\)\1\{8,}\s*\n$'
  " Match lines of repeating `|`s.
  syn match rstFakeHRPipes '^\s*|\{8,}\s*\n$'
  " Match lines of repeating `$`s.
  syn match rstFakeHRBills '^\s*\$\{8,}\s*\n$'
  " Match lines of repeating `*`s.
  syn match rstFakeHRStars '^\s*\*\{8,}\s*\n$'
  " Match lines of repeating `(`s or `)`s.
  syn match rstFakeHRParns '^\s*[()]\{8,}\s*\n$'
  " Match lines of repeating `%`s.
  syn match rstFakeHRPercs '^\s*%\{8,}\s*\n$'

  " Orange-yellow: Statement, or Keyword
  hi! def link rstFakeHRAll   Statement
  " More orangy (darker than orange-yellow)
  hi! def link rstFakeHRStars Delimiter
  " Light pinkish-orangish-reddish
  hi! def link rstFakeHRPercs String
  " Green: Type, or Question
  hi! def link rstFakeHRPipes Question
  " White on baby blue
  hi! def link rstFakeHRParns MatchParen
  " Black on baby blue
  hi def rstHorizRuleUser01 term=reverse guibg=DarkCyan guifg=Black ctermfg=1 ctermbg=6
  hi! def link rstFakeHRBills rstHorizRuleUser01
endfunction

" +----------------------------------------------------------------------+

" HINT: If syntax highlighting appears disabled, even if the file has
" a Vim mode line saying otherwise, trying closing and reopening the
" file, or saving the file and running the `:e` command, or try this:
"
"     set rdt=9999
"     doautocmd Syntax
"     " Also works:
"     syn on

" 2021-01-16: This syntax plugin had been opt-in per file: you'd have
" to set redrawtimeout to something other than 2000 to enable these
" highlights. I think I was doing this because of performance issues
" with some of my reST files. But I'm no longer sure that's the case,
" or, if it was, it was probably on large files, and I've been in the
" habit recently of keeping files under 10,000 lines. Also, it's been
" annoying me that new rst files don't have these highlights enabled
" until I notice and remember to add a modeline.
"   So let's require users to opt-out instead!
"
" - tl;dr I'd rather this work on new files and without requiring modeline.
"
" YOU: To opt-out, set redrawtimeout (rdt) to something less than 4999
"      but not 2000 (the default).
"
"      - E.g., to disable these highlights (and their associated
"        computational overhead), add a modeline like this atop
"        each reST file you want to opt-out:
"
"          .. vim:rdt=2001
"
"      - Otherwise, to have syntax highlighting enabled, use either
"        the default value:
"
"          .. vim:rdt=2000
"
"        or set it 5000 or larger:
"
"          .. vim:rdt=5000
"          .. vim:rdt=9999
"
" MAGIC: The 4999 below is arbitrary. (2021-01-16: And I
"        haven't had a reason to opt-out any files yet.)

function! s:DubsRestWireBasic()
  call s:DubsClr_rstSections()

  let l:redrawtimeout = &rdt
  " MAGIC: Vim's rdt default is 2000 (2 secs.).
  let l:defaultRedrawTimeout = 2000
  let l:syntaxEnableIfGreater = 4999

  if (l:redrawtimeout == l:defaultRedrawTimeout)
     \ || (l:redrawtimeout > l:syntaxEnableIfGreater)
    " Passwords first, so URL and Email matches override.
    call s:DubsSyn_PasswordPossibly()
    call s:DubsSyn_AcronymNoSpell()
    " Syntax Profiling: EmailNoSpell is costly.
    call s:DubsSyn_EmailNoSpell()
    call s:DubsSyn_AtHostNoSpell()
    call s:DubsSyn_CincoWords_EVERY()
    call s:DubsSyn_CincoWords_UPPER()
    call s:DubsSyn_CincoWords_FIXED()
    call s:DubsSyn_CincoWords_SPOKE()
    call s:DubsSyn_CincoWords_TBLLC()
    call s:DubsSyn_CincoWords_TAXES()
  else
    silent! syn clear rstCitationReference
    silent! syn clear rstFootnoteReference
    silent! syn clear rstInlineInternalTargets
    silent! syn clear rstSubstitutionReference
  endif

  call s:Presto_HRrules()

  " Do real reST Section highlighting so it overrides, e.g., rstFakeHRAll.
  call s:DubsSyn_rstSections()

endfunction

call s:DubsRestWireBasic()

" 2021-01-16: Missing all these years!
" - Ensure highlighting works on first file opened!
"   (I.e., the file opened from the command line.
"    Without this `syn on`, if you start Vim with a file specified from
"    the command line, it will not be highlighted. But if you open another
"    file within that instance of Vim, that file will have highlighting on.)
autocmd VimEnter * syn enable

