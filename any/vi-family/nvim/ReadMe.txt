Modes
-----
  normal_mode = "n",
  insert_mode = "i",
  visual_mode = "v",
  visual_block_mode = "x",
  term_mode = "t",
  command_mode = "c",

Key
---
  <M-> = Alt
  <A-> = Alt
  <C-> = Ctrl
  <S-> = Shift

event
-----
VeryLazy
CmdlineEnter
InsertEnter
BufReadPost
BufRead

stdpath()
---------
https://github.com/neovim/neovim/blob/master/src/nvim/os/stdpaths.c
  config  User configuration directory. |init.vim| is stored here. /home/luozhiya/.config/nvim/
  cache   Cache directory: arbitrary temporary storage for plugins, etc. maybe log. /home/luozhiya/.cache/nvim/
  data    User data directory. /home/luozhiya/.local/share/nvim/
  log     Logs directory (for use by plugins too). /home/luozhiya/.local/state/nvim/

completeopt
-----------
https://neovim.io/doc/user/options.html#'completeopt'
                       A       B          C         D        E
Completion Progress: input > trigger > pop menu > select > insert
  menu	    C  Item > 1  Only shown when there is more than one match
  menuone   C  Item >= 1
  longest   E  Insert longest common text
  preview   C  Show extra information.
  noinsert  E  Do not insert 
  noselect  D  Do not select

wildmode
--------
https://neovim.io/doc/user/cmdline.html#cmdline-completion
https://neovim.io/doc/user/options.html#'wildmode'
four parts: A:B,C:D (':' = &, ',' = first,second <Tab>)
full          Complete first full match, next match, etc.  (the default)
longest,full  Complete longest common string, then each full match
list:full     List all matches and complete each full match
list,full     List all matches without completing, then each full match
longest,list  Complete longest common string, then list alternatives.

shortmess
---------
https://neovim.io/doc/user/options.html#'shortmess'
      f	use "(3 of 5)" instead of "(file 3 of 5)"		shm-f
      i	use "[noeol]" instead of "[Incomplete last line]"	shm-i
      l	use "999L, 888B" instead of "999 lines, 888 bytes"	shm-l
      m	use "[+]" instead of "[Modified]"			shm-m
      n	use "[New]" instead of "[New File]"			shm-n
      r	use "[RO]" instead of "[readonly]"			shm-r
      w	use "[w]" instead of "written" for file write message	shm-w
        and "[a]" instead of "appended" for ':w >> file' command
      x	use "[dos]" instead of "[dos format]", "[unix]"		shm-x
        instead of "[unix format]" and "[mac]" instead of "[mac
        format]"
      a	all of the above abbreviations				shm-a
      o	overwrite message for writing a file with subsequent	shm-o
        message for reading a file (useful for ":wn" or when
        'autowrite' on)
      O	message for reading a file overwrites any previous	shm-O
        message;  also for quickfix message (e.g., ":cn")
      s	don't give "search hit BOTTOM, continuing at TOP" or	shm-s
        "search hit TOP, continuing at BOTTOM" messages; when using
        the search count do not show "W" after the count message (see
        S below)
      t	truncate file message at the start if it is too long	shm-t
        to fit on the command-line, "<" will appear in the left most
        column; ignored in Ex mode
      T	truncate other messages in the middle if they are too	shm-T
        long to fit on the command line; "..." will appear in the
        middle; ignored in Ex mode
      W	don't give "written" or "[w]" when writing a file	shm-W
      A	don't give the "ATTENTION" message when an existing	shm-A
        swap file is found
      I	don't give the intro message when starting Vim,		shm-I
        see :intro
      c	don't give ins-completion-menu messages; for		shm-c
        example, "-- XXX completion (YYY)", "match 1 of 2", "The only
        match", "Pattern not found", "Back at original", etc.
      C	don't give messages while scanning for ins-completion	shm-C
        items, for instance "scanning tags"
      q	use "recording" instead of "recording @a"		shm-q
      F	don't give the file info when editing a file, like	shm-F
        :silent was used for the command
      S	do not show search count message when searching, e.g.	shm-S
        "[1/5]"

laststatus
----------
0     never
1     only if there are at least two windows
2     always
3     always and ONLY the last window

Config
------
https://github.com/LunarVim/Neovim-from-scratch
https://github.com/wbthomason/dotfiles/tree/linux/neovim/.config/nvim
https://github.com/akinsho/dotfiles/tree/main/.config/nvim
https://git.sr.ht/~yazdan/nvim-config/tree
https://github.com/j-hui/fidget.nvim
https://github.com/justinmk/config
https://github.com/ray-x/lsp_signature.nvim/blob/master/tests/init_paq.lua
https://github.com/Kethku/vim-config
https://github.com/LazyVim/LazyVim
https://neovim.io/doc/user/options.html
https://github.com/nvim-telescope/telescope.nvim/issues/new?assignees=&labels=bug&template=bug_report.yml
nvim\site\pack\packer\opt\nvim-cmp\lua\cmp\utils\misc.lua
site\pack\packer\opt\nvim-lspconfig\lua\lspconfig\util.lua
-- cf. lazy.nvim util
-- cf. lua/nvim-tree/actions/fs/copy-paste.lua
-- cf. plenary.nvim/lua/plenary/path.lua

Vim
---
gq in Vim
https://asciinema.org/a/188316
https://vi.stackexchange.com/questions/36890/how-to-set-keywordprg-to-call-a-lua-function-in-neovim
https://github.com/lewis6991/hover.nvim/issues/1
https://github.com/neovim/neovim/issues/18997
map colon semicolon in neovim lua
https://vim.fandom.com/wiki/Map_semicolon_to_colon
https://stackoverflow.com/questions/73738932/remapped-colon-key-not-show-command-line-mode-immediately
https://stackoverflow.com/questions/9001337/vim-split-bar-styling
https://vi.stackexchange.com/questions/11025/passing-visual-range-to-a-command-as-its-argument
https://neovim.io/doc/user/indent.html#cinoptions-values
https://vim-jp.org/vimdoc-en/indent.html
https://vimhelp.org/indent.txt.html#indent.txt

Lua
---
https://github.com/neovim/neovim/blob/master/runtime/lua/vim/shared.lua#L324
https://shanekrolikowski.com/blog/love2d-merge-tables/
https://stackoverflow.com/questions/42228712/lua-function-to-convert-windows-paths-to-unix-paths
https://replit.com/languages/lua

Loop
----
https://neovim.io/doc/user/lua.html#lua-loop
