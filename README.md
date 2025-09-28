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
In your Neovim configuration (usually `~/.config/nvim/lua/plugins.lua`), add:

```lua
{
  'nisidabay/code-notes.nvim'
}
```

> 💡 This plugin **does not set any keymaps** — you define your own (see below).

## Usage

Add these mappings to your keymap config (e.g., `keymaps.lua`):

```lua
-- Code Notes
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

### Optional: WhichKey Integration

If you use [`which-key.nvim`](https://github.com/folke/which-key.nvim), add this to your config to ensure all note mappings appear under `<leader>n`:

```lua
-- Register code_notes mappings with WhichKey
local wk = require("which-key")
wk.register({
    n = {
        name = "+notes",
        ["1"] = { "<cmd>lua require('code_notes').jump_to_note(1)<CR>", "Jump to note 1" },
        ["2"] = { "<cmd>lua require('code_notes').jump_to_note(2)<CR>", "Jump to note 2" },
        ["3"] = { "<cmd>lua require('code_notes').jump_to_note(3)<CR>", "Jump to note 3" },
        ["4"] = { "<cmd>lua require('code_notes').jump_to_note(4)<CR>", "Jump to note 4" },
        ["5"] = { "<cmd>lua require('code_notes').jump_to_note(5)<CR>", "Jump to note 5" },
        ["6"] = { "<cmd>lua require('code_notes').jump_to_note(6)<CR>", "Jump to note 6" },
        ["7"] = { "<cmd>lua require('code_notes').jump_to_note(7)<CR>", "Jump to note 7" },
        ["8"] = { "<cmd>lua require('code_notes').jump_to_note(8)<CR>", "Jump to note 8" },
        ["9"] = { "<cmd>lua require('code_notes').jump_to_note(9)<CR>", "Jump to note 9" },
        a = { "<cmd>lua require('code_notes').add_note()<CR>", "Add note" },
        l = { "<cmd>lua require('code_notes').list_notes()<CR>", "List all notes" },
        d = { "<cmd>lua require('code_notes').remove_note(vim.v.count)<CR>", "Delete note" },
    },
}, { prefix = "<leader>" })
```

> 💡 This ensures WhichKey always shows your note mappings — even after restarts.

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
