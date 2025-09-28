-- plugin/code_notes.lua
-- Auto-loads the module. No setup needed.

-- Optional: add a command for convenience
vim.api.nvim_create_user_command('CodeNotesList', function()
    require('code_notes').list_notes()
end, { desc = 'List all code notes' })
