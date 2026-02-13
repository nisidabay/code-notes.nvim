-- plugin/code_notes.lua
-- Auto-loads the module and creates user commands

local notes = require('code_notes')

-- User commands for convenience
vim.api.nvim_create_user_command('CodeNotesList', function()
    notes.list_notes()
end, { desc = 'List all code notes' })

vim.api.nvim_create_user_command('CodeNotesDelete', function()
    notes.delete_notes()
end, { desc = 'Delete code notes interactively' })

vim.api.nvim_create_user_command('CodeNotesClear', function()
    notes.clear_all_notes()
end, { desc = 'Clear all code notes' })

vim.api.nvim_create_user_command('CodeNotesAdd', function()
    notes.add_note()
end, { desc = 'Add a new code note' })
