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

  " Note that rstSections is defined by the built-in runtime/syntax/rst.vim,
  " but that we want to redefine it to our liking, so we clobber the existing
  " rule first before redeclaring it. Note also that the core file also links
  " rstSections to the Title highlight group, which we don't change herein.

  syn clear rstSections
endfunction

" +----------------------------------------------------------------------+

function! s:reSTfold_Apply_Highlights()
  " Add the missing punctuation characters to reST header syntax matching:
  "
  "   !@$%&()[]{}<>/\|,;?

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

  " 2021-10-14: On second thought, disable spell checking.
  " - For one, some rules will be superceded:
  "   - AcronymNoSpell, e.g., 'ABCs' is under-squiggled as misspelled.
  "   - Code blocks, e.g., ``fooBar``.
  " - The under-squiggle makes the title more difficult to read.
  " - So don't use @Spell, e.g., not: syn match rstSections ... contains=@Spell

  syn match rstSections "\v^%(([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\2{2,}$" contains=@NoSpell
endfunction

" +----------------------------------------------------------------------+

function! s:reSTfold_Wire_Highlights()
  call s:reSTfold_Clear_Highlights()
  call s:reSTfold_Apply_Highlights()
endfunction

" +----------------------------------------------------------------------+

call s:reSTfold_Wire_Highlights()

