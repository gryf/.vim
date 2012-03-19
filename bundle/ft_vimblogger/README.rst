:Author: Roman Dobosz, gryf73 at gmail com

=============
vimblogger_ft
=============

vimblogger_ft is a simple reStructuredText_ to Blogger interface through VIm_.

As the name suggest it is a filetype plugin, which helps to create blog
articles in rsST format and send them to blog site. It also provides commands
for preview in browser and delete articles.

Requirements
------------

Module for communication was written in Python. So, VIm has to be
compiled with ``+python``.

Other requirements:

- Python (tested with version 2.6, should work also in others)

  - gdata_
  - docutils_
  - Pygments_ (optional)

- Blogger account

Install
-------

Download_, edit the vba with VIm and type::

    :so %

Or, clone this repository and put files in your ``~/.vim`` directory.

Usage
-----

This plugin is targeting for people, who has blogger account, want to
use VIm for creating blog articles and don't really likes to manually do
this in html.

Before starting writing a post, at least ``g:blogger_name`` and
``g:blogger_login`` has to be set up in ``.vimrc``. Next, an article has to
be written using standard reST markup, ``:Title:`` added (not required,
but it's nice to have some title for a blog entry). Now,
``:PreviewBlogArticle`` can be used for saving generated HTML page into
the file of the same name as reST file. Please note, that it'll silently
overwrite existing file, because it is treated as a temporary file.

When article is done, ``:SendBlogArticle`` will send it to the server.

Output provided by ``:PreviewBlogArticle`` without any
css stylesheet will look pretty raw, so it is generally good idea to
grab stylesheets from blog itself, and tweak it a little, and add to
list in ``g:blogger_stylesheets``. They will be automatically linked to
generated preview file.

Unfortunately, this script has several limitations, like it is
impossible to use multiple blogs or edit existing articles without reST
source files. It has to be somehow converted to reStructuredText, id of
an article added to ``:Id:`` docinfo item and then updated. Id of an
article is available through blogger account - every action for each
post listed on Posting->Edit Posts has URL with query string item
postID, for example::

    http://www.blogger.com/post-edit.g?blogID=9876&postID=12345

See plugin documentation for configuration.

Commands
--------

#. ``:PreviewBlogArticle`` - Generate article in HTML format, save it to the
   file with te same name as a reST source with .html extension in the same
   directory, and optionally opens it in browser. No connection to the blogger
   is performed.
#. ``:SendBlogArticle`` -
   Generate partial HTML document, which holds article, from current
   reST buffer and send it to the blog.

   See reST document structure below for further description.
#. ``:DeleteBlogArticle`` -
   Display list of articles, and lets user choose one (or none) of them
   to perform deletions.

reST document structure
-----------------------

It is assumed, that following template will be used::

    :Id:
    :Title: Title for the blog article
    :Date:
    :Modified:
    :Tags: some, tags

    Penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nulla
    facilisis massa ut massa. Sed nisi purus, malesuada eu, porta vulputate,
    suscipit auctor, nunc. Vestibulum convallis, augue eu luctus malesuada,
    mi ante mattis odio, ac venenatis neque sem vitae nisi.

    .. more

    heading
    -------

    **Congue** mi, quis posuere augue nulla a augue. Pellentesque sed est.
    Mauris cursus urna id lectus. Integer dignissim feugiat eros. Sed tempor
    volutpat dolor. Vestibulum vel lectus nec mauris semper adipiscing.

    Aliquam tincidunt enim sit amet tellus. Sed mauris nulla, semper
    tincidunt, luctus a, sodales eget, leo. Sed ligula augue, cursus et.

reST document (optionally) starts with *docinfo* section (first several
lines, that are starting from ":" character) separaded from other
content with one empty line.

Docinfo items holds article attributes, and are updated automatically
every each of upload to blogger, which is triggered by
":SendBlogArticle" command.

- **:Id:** - Holds article id on blogger side. If not defined, new article
  will be created (even if there is already existing one with the very same
  content). If wrong Id is entered (or an Id of deleted article),
  exception will be raised, and no action on blogger side will be
  performed.
- **:Title:** - Holds article title. Can be changed when ``:Id:`` is obtained.
- **:Date:** - This is published date in RFC 3339
    http://www.ietf.org/rfc/rfc3339.txt format. If empty on first
    upload, it will be set to current date. Can be set/changed to
    desired date.
- **:Modified:** - This is read-only item, which store modification date
  which happens on blogger side.
- **:Tags:** - Comma separated list of tags (Labels). Can be empty.

All other items are ignored.

After docinfo block, article body should be placed using markup for
reStructuredText.

Note, that ``.. more`` will became HTML comment ``<!-- more -->`` which will
prevent from displaying entire post on the bloggers front page, but will
not have any visible effect during preview in browser.

Pygments code highlighting
--------------------------

Additionally, if Pygments is installed, there is ``sourcecode`` directive,
simple syntax highlighter using Pygments module. Very simple usage for Python
code could be as follows::

    .. sourcecode:: python

        import vim
        print vim.current.buffer.name

Note, that ``sourcecode`` directive requires argument with the name of the
lexer to use. If wrong/non existent lexer is provided, it will fall back to
*text* lexer. For more information about available lexers, please refer to
Pygments documentation.

Directive ``sourcecode`` supports two options: ``:linenos:`` and
``:cssclass:``.

``:linenos:`` takes zero or one argument - if no arguments is provided, line
numbers will be visible starting form 1. Provided integer will be the number
of the first line.

``:cssclass:`` can be use for changing default class name for block of code.
Default class can be changed by appropriate option for plugin (see
documentation), and defaults to "highlight".

It is possible to use VIm colorschemes like desert (which is distributed with
VIm), Zenburn_, Lucius_, Wombat_, inkpot_ or any other with Pygments.
Assuming, that colorscheme *desert* should be used, there are two steps to
achive it.

First, python module containing Pygments *Style* class has to be generated.
There is apropriate convertion tool in Pygments distribution -
``scripts/vim2pygments.py``. Uage is simple as::

    python Pygments/scripts/vim2pygments.py [path/to/vim/colors]/desert.vim > desert.py

Which will create new python module ``desert.py`` containing class
``DessertStyle``.

To generate CSS stylesheet, it's enough to::

    python rst2blogger/scripts/style2css.py desert.py -c VimDesert > desert.css

VimDesert is the name of the class, which passed as an argument to
``:cssclass:`` option of directive ``sourceocode``. It will be used as a main
CSS class for code top ``<div>`` element. So, above example will looks like
this::

    .. sourcecode:: python
        :cssclass: VimDesert

        import vim
        print vim.current.buffer.name

Note: All headings for generated HTML by ``:SendBlogArticle`` will be
shifted by 3, so the first heading will become <h3>, second <h4> and so
on, to fit into blogger template (well, most of them). Remember, that
HTML allow up to 6 level of headings, while reST doesn't have this
limitation.

.. _VIm: http://www.vim.org
.. _gdata: http://code.google.com/p/gdata-python-client
.. _docutils: http://docutils.sourceforge.net
.. _Pygments: http://pygments.org
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _Download: http://www.vim.org/scripts/script.php?script_id=3367
.. _Zenburn: http://www.vim.org/scripts/script.php?script_id=415
.. _inkpot: http://www.vim.org/scripts/script.php?script_id=1143
.. _Lucius: http://www.vim.org/scripts/script.php?script_id=2536
.. _Wombat: http://www.vim.org/scripts/script.php?script_id=1778
