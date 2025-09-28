local M = {}

-- Import Telescope modules
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

-- Constants
local MAX_SLOTS = 9
-- Data file: ~/share_data/note_marks.lua
-- Why? So notes are preserved when you stow/sync dotfiles.
-- Feel free to change this path if you prefer another location.
local data_path = vim.fn.expand("~/share_data/note_marks.lua")

-- Global notes: fixed array of 9 slots (1–9), possibly nil
local notes = {}

-- Ensure data directory and file exist
local function ensure_data_path()
    local dir = vim.fn.fnamemodify(data_path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    if not vim.loop.fs_stat(data_path) then
        local file = io.open(data_path, "w")
        if file then
            file:write("return {}")
            file:close()
        end
    end
end

-- Load notes into fixed 9-slot structure
local function load_data()
    ensure_data_path()
    local success, loaded = pcall(dofile, data_path)
    notes = {}
    for i = 1, MAX_SLOTS do
        notes[i] = nil
    end
    if success and type(loaded) == "table" then
        for i = 1, MAX_SLOTS do
            notes[i] = loaded[i]
        end
    end
end

-- Save using vim.inspect (safe and clean)
local function save_data()
    ensure_data_path()
    local file = io.open(data_path, "w")
    if not file then
        vim.notify("Failed to open data file for writing", vim.log.levels.ERROR)
        return
    end
    local serialized = "return " .. vim.inspect(notes)
    file:write(serialized)
    file:close()
end

-- Initialize on load
load_data()

-- Helper: validate and normalize file path
local function get_current_file_info()
    local bufnr = 0
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" then return nil, "Buffer has no associated file." end
    if not vim.loop.fs_stat(file) then return nil, "File not saved to disk. Please save first." end
    return {
        full_path = file,
        name = vim.fn.fnamemodify(file, ":t"),
        line = vim.api.nvim_win_get_cursor(0)[1],
        col = vim.api.nvim_win_get_cursor(0)[2],
    }, nil
end

-- Add note to first available slot (1–9)
function M.add_note()
    local file_info, err = get_current_file_info()
    if not file_info then
        vim.notify(err, vim.log.levels.WARN)
        return
    end

    -- Find first empty slot
    local slot = nil
    for i = 1, MAX_SLOTS do
        if notes[i] == nil then
            slot = i
            break
        end
    end

    if not slot then
        vim.notify("All 9 note slots are full! Remove one first.", vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = "Concise note: " }, function(concise)
        if not concise or concise == "" then return end
        vim.ui.input({ prompt = "Extended explanation: " }, function(extended)
            notes[slot] = {
                file = file_info.full_path,
                file_name = file_info.name,
                line = file_info.line,
                col = file_info.col,
                concise_content = concise,
                extended_explanation = extended or "No additional comments.",
            }
            save_data()
            vim.notify("📌 Note saved to slot " .. slot, vim.log.levels.INFO)
        end)
    end)
end

-- Jump to note by slot index (1–9)
function M.jump_to_note(index)
    if type(index) ~= "number" or index < 1 or index > MAX_SLOTS then
        vim.notify("Note index must be between 1 and " .. MAX_SLOTS, vim.log.levels.WARN)
        return
    end

    local note = notes[index]
    if not note then
        vim.notify("Slot " .. index .. " is empty!", vim.log.levels.WARN)
        return
    end

    if not vim.loop.fs_stat(note.file) then
        vim.notify("File not found: " .. note.file, vim.log.levels.ERROR)
        return
    end

    local success, err = pcall(function()
        vim.cmd("edit " .. vim.fn.fnameescape(note.file))
        vim.api.nvim_win_set_cursor(0, { note.line, note.col })
    end)

    if not success then
        vim.notify("Failed to jump to note: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    end
end

-- Remove note by slot index
function M.remove_note(index)
    if type(index) ~= "number" or index < 1 or index > MAX_SLOTS then
        vim.notify("Note index must be between 1 and " .. MAX_SLOTS, vim.log.levels.WARN)
        return
    end

    if not notes[index] then
        vim.notify("Slot " .. index .. " is already empty.", vim.log.levels.INFO)
        return
    end

    notes[index] = nil
    save_data()
    vim.notify("🗑️ Note in slot " .. index .. " removed.", vim.log.levels.INFO)
end

-- List all notes in Telescope
function M.list_notes()
    local valid_notes = {}
    for i = 1, MAX_SLOTS do
        if notes[i] ~= nil then
            table.insert(valid_notes, {
                slot = i,
                file = notes[i].file,
                file_name = notes[i].file_name,
                line = notes[i].line,
                col = notes[i].col,
                concise_content = notes[i].concise_content,
                extended_explanation = notes[i].extended_explanation,
            })
        end
    end

    if #valid_notes == 0 then
        vim.notify("No notes set!", vim.log.levels.INFO)
        return
    end

    local note_previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry)
            local note = entry.value
            local lines = {
                "📌 Code Note (Slot " .. note.slot .. ")",
                "",
                "File: " .. note.file_name,
                "Path: " .. note.file,
                "Location: Line " .. note.line .. ", Column " .. note.col,
                "",
                "Content:",
                note.concise_content or "<empty>",
                "",
                "Explanation:",
                note.extended_explanation or "<none>",
            }
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
    })

    pickers.new({
        prompt_title = "Code Notes (Slots 1–9)",
        finder = finders.new_table({
            results = valid_notes,
            entry_maker = function(entry)
                return {
                    value = entry,
                    ordinal = string.format("[%d] %s:%d %s", entry.slot, entry.file_name, entry.line,
                        entry.concise_content),
                    display = string.format("[%d] %s:%d — %s", entry.slot, entry.file_name, entry.line,
                        entry.concise_content),
                }
            end,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        previewer = note_previewer,
        attach_mappings = function(prompt_bufnr)
            -- Only override Enter to jump
            actions.select_default:replace(function()
                local selection = actions_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and selection.value then
                    M.jump_to_note(selection.value.slot)
                end
            end)
            return true
        end,
    }):find()
end

return M
