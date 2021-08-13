########################################
Dubs Vim |em_dash| reST Document Folding
########################################

.. |em_dash| unicode:: 0x2014 .. em dash

About This Plugin
=================

This plugin adds advanced reST document section folding,
so you can use reStructuredText to manage notes files in
Vim using reST markup.

Usage: Signify Fold Levels using Specific Punctuation
=====================================================

The reST language is flexible when it comes to delimiting sections,
allowing you to choose generally any ASCII non-alphanum as a delimiter,
and then inferring the level of each section by the order in which the
section delimiters are introduced in the document. You can also choose
to use just an underscored delimiter, or you can add an overscore, too.

For instance, both of the following documents will render the same:

Document 1::

  Level 1 Heading
  ###############

  ===============
  Level 2 Heading
  ===============

and Document 2::

  ===============
  Level 1 Heading
  ===============

  Level 2 Heading
  ---------------

Obviously, this flexibility makes any parser more complex to write,
and it might noticeably impact real-time application responsiveness.

Accordingly, the ``dubs_rest_fold`` plugin imposes strict rules for
section headers used for folding:

- Only double-bordered reST sections will be folded.

  E.g., this header with both an overscore and an underscore will be folded::

    ###########################
    This Section Will Be Folded
    ###########################

  but this header, with simply an underscore, will be ignored by the folding engine::

    This Section Will Not Be Folded
    ###############################

- Fold levels are assigned in a specific, static order.

  That is, as you use the command ``zr`` to collapse one level of folds,
  or use ``zm`` to open a level of folds, or ``za`` to toggle the current
  fold, the sections levels are determined based on the delimiter used:

  - Level 1: ``@``

  - Level 2: ``#``

  - Level 3: ``=``

  - Level 4: ``-``

  For instance, this document has two Level 2 sections::

    @@@@@@@@@@@@@@@@@@@@@@@
    Document Section Header
    @@@@@@@@@@@@@@@@@@@@@@@

    #####################
    One Top-Level Section
    #####################

    ===============
    Level 3 Section
    ===============

    #########################
    Another Top-Level Section
    #########################

    =======================
    Another Level 3 Section
    =======================

    A Level 3 reST section, but ignored by folder
    =============================================

    ------------------------
    Foldable Level 4 Section
    ------------------------

Usage: Press ``<F5>`` to Manually Recalculate Folds
===================================================

By default, Vim enables reST folding.

But this can cause performance issues, e.g., every time you insert or
remove a character from a buffer, Vim has to recalculate folds.

To prevent performance issues, the user must explicitly generate folds.

**Press <F5> to generate (and collapse all) folds.**

Usage: Use ``<C-Up>`` and ``<C-Down>`` to Transpose Folds
=========================================================

In normal mode, with the cursor over a folded reST section,
press ``<C-Up>`` to swap the fold under the cursor with the
fold under the line above the cursor; press ``<C-Down>`` to
swap with the fold on the line following the current fold.

**Swap reST Sections (Transpose Folds) using ``<C-Up>`` and ``<C-Down>``.**

Tips: Make Titles Pretty When Collapsed
=======================================

The reST section title that's sandwiched between the section delimiter
lines is used for the folded view title.

Because of this, you can design section titles that look good folded, too.

For instance, consider the following, unfolded document::

  ###########################################################
  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ###########################################################

  ###########################################################
  ┣━━ // * TABLE_OF_CONTENTS * // ━━━━━━━━━━━━━━━━━━━━━━━━━━┨
  ###########################################################

  ###########################################################
  ┃   ┏━━━━━━━━━━━━━┓                                       ┃
  ###########################################################

  ###########################################################
  ┃   ┃ ☼ FOO BAR ☼ ┃                                       ┃
  ###########################################################

  ###########################################################
  ┃ ┏━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃
  ###########################################################

  ###########################################################
  ┃ ┃ SECTION X: Blah blah blah                           ┃ ┃
  ###########################################################

  ###########################################################
  ┃ ┃ SECTION Y: Blasé blasé blasé                        ┃ ┃
  ###########################################################

  ###########################################################
  ┃ ┃ SECTION Z: Patati Patata                            ┃ ┃
  ###########################################################

  ###########################################################
  ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
  ###########################################################

  ###########################################################
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  ###########################################################

Once folded (e.g., using ``<F5>``), it'll look like this::

  1  +-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ---- |  4 lines |--
  5  +-- ┣━━ // * TABLE_OF_CONTENTS * // ━━━━━━━━━━━━━━━━━━━━━━━━━━┨ ---- |  4 lines |--
  9  +-- ┃   ┏━━━━━━━━━━━━━┓                                       ┃ ---- |  4 lines |--
  13 +-- ┃   ┃ ☼ FOO BAR ☼ ┃                                       ┃ ---- |  4 lines |--
  17 +-- ┃ ┏━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃ ---- |  4 lines |--
  21 +-- ┃ ┃ SECTION X: Blah blah blah                           ┃ ┃ ---- |  4 lines |--
  25 +-- ┃ ┃ SECTION Y: Blasé blasé blasé                        ┃ ┃ ---- |  4 lines |--
  29 +-- ┃ ┃ SECTION Z: Patati Patata                            ┃ ┃ ---- |  4 lines |--
  33 +-- ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃ ---- |  4 lines |--
  37 +-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ---- |  4 lines |--

Tips: Change 'redrawtime' for Very Large Documents
==================================================

Vim's default "redrawtime" (``:echo &rdt``) is "2000", or 2 seconds.

If Vim runs longer than this during syntax matching, it cancels the operation
and logs the message, "'redrawtime' exceeded, syntax highlighting disabled".

You can set this value larger to tell Vim to run the parser longer,
e.g., ``:set redrawtime=10000``, or, better yet, you can add a modeline
(such as one read by https://github.com/landonb/dubs_style_guard)
to any reST document that needs extra parsing time. E.g., at the top
of a reST document, you could add::

  .. vim:rdt=10000

Installation
============

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/start
    cd ~/.vim/pack/landonb/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/opt
    cd ~/.vim/pack/landonb/opt

Clone the project to the desired path:

.. code-block:: bash

    git clone https://github.com/landonb/dubs_rest_fold.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

   :packadd! dubs_rest_fold

Just once, tell Vim to build the online help:

.. code-block:: vim

   :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

   :help dubs-rest-fold

