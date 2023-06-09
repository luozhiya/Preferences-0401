Roadmap
-------
support clangd/ccls
godbolt
cppdocs
sematic highlight
cpp debug
cpp test
cpp run
cpp cmake
cpp project
alignment

TODO
----
reload buffer

BUG
----
confusion root?
  LSP(lsp-file, no lsp-file)
  nvim-tree(change root, even in same dir)
  project

C++ accesstor indent
  public/private/protected
  nvim-cmp, tree-sitter(indent), neovim(builtin-cindoption)

symbol-outline padding too many space
https://github.com/simrat39/symbols-outline.nvim/issues/165

scrolloff for bufferline?

cmp will flash statusbar?

cmake-tools doesn't find correct path? find the .git root insteadof CMakeLists.txt root?

wilder lua rrequire ?? bug?

hydra.nvim as a tips window? no key only text show?

nvim-hlslens-uof <TAB> quit preview will unfold folded lines

Bug: cmdheight = 0 will flash statusbar when <TAB>

[Solved] Bug: incline will make cursor move <0> left-right-around. F

Bug: external modify file will cause syntax highlight error?
  LSP?
  TS?

[Solved] Bug: Telescope oldfiles + satellite

Minimal Test
------------
nvim -u minimal.lua
neovide -- -u minimal.lua

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

Folding
-------
zM  close-all
zR  open-all
zc  fold
zo  open
[z  jump-start
]z  jump-end

Matchup
-------
%

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
https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim
https://vi.stackexchange.com/questions/2702/how-can-i-make-vim-autoread-a-file-while-it-doesnt-have-focus
https://www.jmaguire.tech/posts/treesitter_folding/
https://unix.stackexchange.com/questions/141097/how-to-enable-and-use-code-folding-in-vim
https://vi.stackexchange.com/questions/12864/oneliner-map-to-fold-all-unfold-all
https://www.linux.com/training-tutorials/vim-tips-folding-fun/
https://github.com/nvim-telescope/telescope.nvim/issues/1277
https://github.com/tmhedberg/SimpylFold/issues/130#issuecomment-1074049490
https://vi.stackexchange.com/questions/3814/is-there-a-best-practice-to-fold-a-vimrc-file
https://vi.stackexchange.com/questions/39174/no-digits-in-foldcolumn
https://github.com/neovim/neovim/pull/17446
https://github.com/luukvbaal/statuscol.nvim
https://github.com/neovim/neovim/pull/22035
https://github.com/neovim/neovim/pull/19155
https://github.com/luukvbaal/statuscol.nvim/commit/b3d6490176bf0caaaa301d31163e41dfcd144c72
https://github.com/neovim/neovim/pull/15999
https://github.com/luukvbaal/statuscol.nvim/issues/33
https://vi.stackexchange.com/questions/18930/setting-xdg-config-home
https://vi.stackexchange.com/questions/12579/neovim-setup-on-ms-windows
https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfinalpathnamebyhandlea
http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_realpath
https://github.com/neovim/neovim/blob/10baf89712724b4b95f7c641f2012f051737003c/src/nvim/os/fs.c#L1265
https://github.com/nvim-telescope/telescope.nvim/issues/791
https://github.com/LunarVim/LunarVim/issues/2597
https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text
https://github.com/neovim/neovim/issues/9877
https://vi.stackexchange.com/questions/39285/is-it-possible-to-set-a-vim-api-nvim-create-autocmd-for-a-filetype-not-just-a-p
https://stackoverflow.com/questions/68598026/running-async-lua-function-in-neovim
https://github.com/neovim/neovim/issues/13314
https://vi.stackexchange.com/questions/31748/how-to-set-the-diagnostic-level-for-neovim-lsp
https://github.com/folke/trouble.nvim/issues/52
https://github.com/hrsh7th/nvim-cmp/issues/1035
https://vi.stackexchange.com/questions/27796/how-to-change-editor-mode-from-lua-or-viml
https://github.com/rcarriga/nvim-notify/issues/11
https://github.com/folke/which-key.nvim/issues/67
https://github.com/nvim-telescope/telescope.nvim/issues/2196
https://github.com/neovim/neovim/pull/21393
https://github.com/neovim/neovim/issues/12101
https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
https://github.com/akinsho/bufferline.nvim/issues/631
https://github.com/AstroNvim/AstroNvim/blob/cf624ae5870ea5fcf98ff1e2f6354f6a57df3f53/lua/astronvim/autocmds.lua#L148
https://vi.stackexchange.com/questions/38508/paste-command-to-command-mode-instead-of-insert-mode
https://github.com/kristijanhusak/vim-dadbod-ui/issues/133
https://superuser.com/questions/212257/how-do-i-open-a-blank-new-file-in-a-split-in-vim
https://www.bearer.com/blog/tips-for-using-tree-sitter-queries
https://zignar.net/2022/09/02/a-tree-sitting-in-your-editor/
https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries
https://en.wikipedia.org/wiki/S-expression

Lua
---
https://github.com/neovim/neovim/blob/master/runtime/lua/vim/shared.lua#L324
https://shanekrolikowski.com/blog/love2d-merge-tables/
https://stackoverflow.com/questions/42228712/lua-function-to-convert-windows-paths-to-unix-paths
https://replit.com/languages/lua

Loop
----
https://neovim.io/doc/user/lua.html#lua-loop

DAP
---
https://microsoft.github.io/debug-adapter-protocol/overview

Resource
--------
https://fontawesome.com/icons
https://fontawesome.com.cn/v4/cheatsheet
https://github.com/microsoft/vscode-codicons
https://microsoft.github.io/vscode-codicons/dist/codicon.html

PATH
----
%LOCALAPPDATA%\nvim-data
