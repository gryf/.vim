vim config
==========

This repository contains my Vim config just for convenience in making the copy
of it.

It uses `vim-plug`_ plugin manager, so after cloning, just open vim, and it
will automatically install all the plugins.

Other than that, there are two additional config files which can be added to
the configuration as a local configuration files just to not mess up with main 
config file. Both of them should be placed under ``$HOME/.vim`` directory.

First one is ``vimrc.local``, which might contain additional/override options 
for specific machine. 

The other ``plugins.local`` and similarly there can be additional plugins 
defined.

.. _vim-plug: https://github.com/junegunn/vim-plug
