# code-notes.nvim

> **Enhanced Neovim plugin for contextual code bookmarks with precise navigation and rich note-taking.**

Save unlimited contextual bookmarks across your projects. Each note remembers:
- File path (absolute and relative)
- Exact line & column position
- Concise summary
- Extended explanation
- Creation timestamp

Perfect for deep code exploration, code reviews, refactoring sessions, or leaving breadcrumbs in large codebases.

## What's New in v2.0

✨ **Major Improvements:**
- **Unlimited notes** - No more 9-slot limitation
- **Auto-incrementing IDs** - Notes are tracked by unique IDs, not fixed slots
- **Telescope-based deletion** - Delete notes interactively with live preview
- **Quick delete in list view** - Press `<C-d>` to delete while browsing notes
- **Timestamps** - Every note records when it was created
- **Better organization** - Notes sorted by recency (newest first)
- **Improved previews** - Clearer formatting with markdown syntax highlighting

## Why This Exists

Existing navigation plugins remember *files* — this remembers **exactly where and why** you were there.

When working on complex refactoring or exploring unfamiliar code, you need more than file bookmarks. You need to remember:
- "Why did I mark this function?"
- "What was the issue I found here?"
- "How does this relate to the other code I'm reviewing?"

This plugin solves that problem.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'nisidabay/code-notes.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'nisidabay/code-notes.nvim',
  requires = {
    'nvim-telescope/telescope.nvim',
  },
}
```

> 💡 This plugin **does not set any keymaps** — you define your own workflow.

## Usage

### Recommended Keymaps

Add these mappings to your keymap config:

```lua
local notes = require("code_notes")

-- Core operations
vim.keymap.set('n', '<leader>na', notes.add_note, { desc = "Add code note" })
vim.keymap.set('n', '<leader>nl', notes.list_notes, { desc = "List code notes" })
vim.keymap.set('n', '<leader>nd', notes.delete_notes, { desc = "Delete notes (interactive)" })

-- Optional: Clear all notes (use with caution - requires confirmation)
vim.keymap.set('n', '<leader>nC', notes.clear_all_notes, { desc = "Clear ALL notes" })
```

### Optional: WhichKey Integration

```lua
local wk = require("which-key")
wk.register({
    n = {
        name = "+notes",
        a = { "<cmd>lua require('code_notes').add_note()<CR>", "Add note" },
        l = { "<cmd>lua require('code_notes').list_notes()<CR>", "List notes" },
        d = { "<cmd>lua require('code_notes').delete_notes()<CR>", "Delete notes" },
        C = { "<cmd>lua require('code_notes').clear_all_notes()<CR>", "Clear ALL notes" },
    },
}, { prefix = "<leader>" })
```

## Features

### 1. Add Notes (`add_note()`)

Saves a bookmark at your current cursor position:
1. Captures exact file, line, and column
2. Prompts for a concise summary
3. Optionally adds extended explanation
4. Saves with timestamp

### 2. List Notes (`list_notes()`)

Opens Telescope picker showing all notes:
- **Enter**: Jump to note location
- **Ctrl-d**: Delete the selected note (stays in picker)
- **Esc**: Close picker
- Preview pane shows full note details

### 3. Delete Notes (`delete_notes()`)

Dedicated deletion interface:
- Select notes to delete one by one
- Preview shows what you're about to delete
- **Enter**: Delete selected note
- Picker updates automatically after each deletion
- Closes when all notes are deleted

### 4. Clear All Notes (`clear_all_notes()`)

Removes all notes at once with confirmation:
- Prompts for "yes" confirmation before deleting
- Shows count of notes being deleted
- Safe way to start fresh or clean up after a project
- Useful when switching contexts or archiving work

## Keyboard Shortcuts

### In List View (`list_notes()`)
| Key | Action |
|-----|--------|
| `Enter` | Jump to note location |
| `Ctrl-d` | Delete note (stays in list) |
| `Esc` | Close picker |
| `/` | Search/filter notes |

### In Delete View (`delete_notes()`)
| Key | Action |
|-----|--------|
| `Enter` | Delete selected note |
| `Esc` | Cancel and close |
| `/` | Search/filter notes to delete |

## Data Storage

Notes are saved to:
```
~/share_data/note_marks.lua
```

This is a plain Lua file — easy to:
- Back up with your dotfiles
- Sync across machines
- Edit manually if needed
- Version control

### Data Format

```lua
return {
  notes = {
    [1] = {
      id = 1,
      file = "/home/user/project/src/main.c",
      file_name = "main.c",
      relative_path = "src/main.c",
      line = 42,
      col = 8,
      concise_content = "Memory leak in initialization",
      extended_explanation = "Need to free buffer before return",
      created_at = "2024-02-13 14:30:00",
    },
    -- more notes...
  },
  next_id = 2,
}
```

> 💡 **Tip**: Add `~/share_data` to your dotfiles repo and manage it with GNU Stow.

## Commands

For convenience, the plugin creates these commands:

```vim
:CodeNotesList     " List all notes
:CodeNotesDelete   " Open deletion interface
:CodeNotesClear    " Clear all notes
```

## Best Practices

### When to Use Code Notes

✅ **Good use cases:**
- Tracking multiple related changes during refactoring
- Marking issues found during code review
- Remembering key points while learning a new codebase
- Leaving breadcrumbs during deep debugging sessions
- Documenting complex logic you'll revisit later

❌ **Not ideal for:**
- Permanent documentation (use code comments)
- TODO items (use a task management system)
- Git-related bookmarks (use Git tools)

### Organizing Your Notes

**Concise content** should be:
- Short (one line)

- Action-oriented when possible

Examples:
- ✅ "Memory leak in cleanup routine"
- ✅ "TODO: Refactor error handling"
- ✅ "Complex recursion - understand before modifying"
- ❌ "Important"
- ❌ "Note"

**Extended explanation** is optional but useful for:
- Why this code is problematic
- What you plan to do about it
- How it relates to other notes
- Links to relevant documentation/issues

## Comparison with Other Tools

| Feature | code-notes.nvim | Harpoon | vim-bookmarks |
|---------|----------------|---------|---------------|
| Exact position (line+col) | ✅ | ❌ | ✅ |
| Contextual notes | ✅ | ❌ | ⚠️ Limited |
| Unlimited bookmarks | ✅ | ❌ (5 slots) | ✅ |
| Rich previews | ✅ | ❌ | ❌ |
| Interactive deletion | ✅ | ❌ | ⚠️ Basic |
| Timestamps | ✅ | ❌ | ❌ |
| Sync across machines | ✅ | ✅ | ⚠️ Depends |

## Philosophy

This plugin follows these principles:

1. **Single responsibility** - Does one thing (contextual bookmarks) extremely well
2. **No magic** - Transparent data format, explicit operations
3. **Your workflow** - No forced keybindings or UI decisions
4. **Minimal dependencies** - Only requires Telescope (which you probably already have)
5. **Data ownership** - Your notes in a simple, portable format you control

## Troubleshooting

### Notes aren't saving

Check that the directory exists and is writable:
```bash
mkdir -p ~/share_data
chmod 755 ~/share_data
```

### Can't jump to old notes

This usually means the file was moved or deleted. The plugin will warn you if a file doesn't exist anymore.

### Telescope not working

Ensure you have Telescope installed:
```lua
:checkhealth telescope
```

## Contributing

Issues and pull requests welcome! Some ideas for future enhancements:

- [ ] Export notes to markdown
- [ ] Tag system for categorizing notes
- [ ] Note editing (update content without recreating)
- [ ] Fuzzy search within note content
- [ ] Quick note templates
- [ ] Project-specific note collections

## License

MIT

## Credits

Inspired by:
- [harpoon](https://github.com/ThePrimeagen/harpoon) - Fast file navigation
- [vim-bookmarks](https://github.com/MattesGroeger/vim-bookmarks) - Classic bookmark plugin
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - The best fuzzy finder
