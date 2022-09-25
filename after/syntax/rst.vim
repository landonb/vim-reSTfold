" Powerful (Cleverful!) reST section folder
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3
"  vim:tw=0:ts=2:sw=2:et:norl:

" +----------------------------------------------------------------------+

" REFER: See complementary reST highlights plugins from this author
"        (pairs well with this plugin to help you take notes in Vim):
"
"   https://github.com/landonb/vim-reSTfold#🙏
"   https://github.com/landonb/vim-reST-highdefs#🎨
"   https://github.com/landonb/vim-reST-highfive#🖐
"   https://github.com/landonb/vim-reST-highline#➖

" REFER: See the reST syntax file included with Vim.
" - E.g.:
"     /usr/share/vim/vim81/syntax/rst.vim
"   Or maybe:
"     ${HOME}/.local/share/vim/vim81/syntax/rst.vim
" See also the most current upstream source of the same:
"   https://github.com/marshallward/vim-restructuredtext

" +======================================================================+
" +======================================================================+

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

" +======================================================================+
" +======================================================================+

" *** SYNTAX GROUP: reST section highlighting.

function! s:reSTfold_Clear_Highlights()
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

function! s:reSTfold_Apply_Highlights_Missing_Punctuation()
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
  "
  " 2021-10-14: On second thought, disable spell checking.
  " - For one, some rules will be superceded:
  "   - AcronymNoSpell, e.g., 'ABCs' is under-squiggled as misspelled.
  "   - Code blocks, e.g., ``fooBar``.
  " - The under-squiggle makes the title more difficult to read.
  " - So don't use @Spell, e.g., not: syn match rstSections ... contains=@Spell
  "
  syn match rstSections "\v^%(([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\2{2,}$" contains=@NoSpell
endfunction

" +======================================================================+
" +======================================================================+

" *** (p)reST(o) reST extension: reSTrule: Pseudo-Horizontal Rule Highlights

function! s:reSTfold_Apply_Highlights_Repeated_Chars()
  " 2018-01-30: SO 🆒!
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
  " - Note that, even though this rule is first, it'll override the
  "   following rules, sorta. E.g., if we used this rule with a period
  "   to match any character:
  "     syn match rstFakeHRAll '^\n\s*\(.\)\1\{8,}\s*\n$'
  "   then typing 8 repeating asterisks as one line would match the
  "   rstFakeHRStars rule, but typing 9 or more repeating asterisk
  "   would match rstFakeHRAll instead. Not sure why. To avoid this,
  "   exclude the special characters from the 'all' match.
  syn match rstFakeHRAll   '^\n\s*\([^|*$()%]\)\1\{8,}\s*\n$'
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

" +======================================================================+
" +======================================================================+

function! s:reSTfold_Wire_Highlights()
  call s:reSTfold_Clear_Highlights()

  call s:reSTfold_Apply_Highlights_Repeated_Chars()

  " Do real reST Section highlighting so it overrides, e.g., rstFakeHRAll.
  call s:reSTfold_Apply_Highlights_Missing_Punctuation()
endfunction

" +----------------------------------------------------------------------+

call s:reSTfold_Wire_Highlights()

