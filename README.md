# code-notes.nvim

> **Harpoon-style navigation — but jumps to the exact line and column, with
> optional notes.**

Save up to 9 contextual bookmarks across your projects. Each note remembers:
- File path
- Line & column
- Concise summary
- Extended explanation

Perfect for deep code exploration, code reviews, or leaving breadcrumbs in
large files.

## Why this exists

I kept losing my place in big files. Harpoon remembers *files* — this remembers
**where and why**.

Notes are saved to `~/share_data/note_marks.lua` so they’re included when I
sync my dotfiles with GNU Stow.

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)
In your Neovim configuration (usually ~/.config/nvim/lua/plugins.lua or
similar), add this entry to your plugin list: 

💡 The keys table only enables lazy-loading — you still need to define the actual keymaps (see Usage below). 

```lua
{
  'nisidabay/code-notes.nvim',
  -- Optional: lazy-load on keymaps
  keys = {
    { '<leader>na',  mode = 'n', desc = 'Add note' },
    { '<leader>n1',  mode = 'n', desc = 'Jump to note 1' },
    { '<leader>n2',  mode = 'n', desc = 'Jump to note 2' },
    { '<leader>n3',  mode = 'n', desc = 'Jump to note 3' },
    { '<leader>n4',  mode = 'n', desc = 'Jump to note 4' },
    { '<leader>n5',  mode = 'n', desc = 'Jump to note 5' },
    { '<leader>n6',  mode = 'n', desc = 'Jump to note 6' },
    { '<leader>n7',  mode = 'n', desc = 'Jump to note 7' },
    { '<leader>n8',  mode = 'n', desc = 'Jump to note 8' },
    { '<leader>n9',  mode = 'n', desc = 'Jump to note 9' },
    { '<leader>nd1', mode = 'n', desc = 'Delete note 1' },
    { '<leader>nd2', mode = 'n', desc = 'Delete note 2' },
    { '<leader>nd3', mode = 'n', desc = 'Delete note 3' },
    { '<leader>nd4', mode = 'n', desc = 'Delete note 4' },
    { '<leader>nd5', mode = 'n', desc = 'Delete note 5' },
    { '<leader>nd6', mode = 'n', desc = 'Delete note 6' },
    { '<leader>nd7', mode = 'n', desc = 'Delete note 7' },
    { '<leader>nd8', mode = 'n', desc = 'Delete note 8' },
    { '<leader>nd9', mode = 'n', desc = 'Delete note 9' },
    { '<leader>nl',  mode = 'n', desc = 'List all notes' },
  }
}
```

## Usage

This plugin does not create mappings — you choose your own. Example:

```lua
-- In your keymaps config
vim.keymap.set('n', '<leader>na',  '<cmd>lua require("code_notes").add_note()<CR>')
vim.keymap.set('n', '<leader>n1',  '<cmd>lua require("code_notes").jump_to_note(1)<CR>')
vim.keymap.set('n', '<leader>n2',  '<cmd>lua require("code_notes").jump_to_note(2)<CR>')
vim.keymap.set('n', '<leader>n3',  '<cmd>lua require("code_notes").jump_to_note(3)<CR>')
vim.keymap.set('n', '<leader>n4',  '<cmd>lua require("code_notes").jump_to_note(4)<CR>')
vim.keymap.set('n', '<leader>n5',  '<cmd>lua require("code_notes").jump_to_note(5)<CR>')
vim.keymap.set('n', '<leader>n6',  '<cmd>lua require("code_notes").jump_to_note(6)<CR>')
vim.keymap.set('n', '<leader>n7',  '<cmd>lua require("code_notes").jump_to_note(7)<CR>')
vim.keymap.set('n', '<leader>n8',  '<cmd>lua require("code_notes").jump_to_note(8)<CR>')
vim.keymap.set('n', '<leader>n9',  '<cmd>lua require("code_notes").jump_to_note(9)<CR>')
vim.keymap.set('n', '<leader>nd1', '<cmd>lua require("code_notes").remove_note(1)<CR>')
vim.keymap.set('n', '<leader>nd2', '<cmd>lua require("code_notes").remove_note(2)<CR>')
vim.keymap.set('n', '<leader>nd3', '<cmd>lua require("code_notes").remove_note(3)<CR>')
vim.keymap.set('n', '<leader>nd4', '<cmd>lua require("code_notes").remove_note(4)<CR>')
vim.keymap.set('n', '<leader>nd5', '<cmd>lua require("code_notes").remove_note(5)<CR>')
vim.keymap.set('n', '<leader>nd6', '<cmd>lua require("code_notes").remove_note(6)<CR>')
vim.keymap.set('n', '<leader>nd7', '<cmd>lua require("code_notes").remove_note(7)<CR>')
vim.keymap.set('n', '<leader>nd8', '<cmd>lua require("code_notes").remove_note(8)<CR>')
vim.keymap.set('n', '<leader>nd9', '<cmd>lua require("code_notes").remove_note(9)<CR>')
vim.keymap.set('n', '<leader>nl',  '<cmd>lua require("code_notes").list_notes()<CR>')
```

## Commands

- `:CodeNotesList` — same as `<leader>nl`

## Data Storage

Notes are saved to:
```
~/share_data/note_marks.lua
```
This is a plain Lua file — easy to back up, sync, or edit manually.

> 💡 Tip: Add `~/share_data` to your dotfiles repo and manage it with `stow`.

## Philosophy

- Solves one problem well.
- No configuration needed.
- Respects your keymap style.
- Transparent data format.
