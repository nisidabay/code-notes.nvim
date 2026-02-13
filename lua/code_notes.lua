local M = {}

-- Import Telescope modules
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values

-- Configuration
local config = {
	data_path = vim.fn.expand("~/share_data/note_marks.lua"),
	max_preview_lines = 50,
}

-- Notes storage: table with auto-incrementing IDs
local notes = {}
local next_id = 1

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------

-- Ensure data directory and file exist
local function ensure_data_path()
	local dir = vim.fn.fnamemodify(config.data_path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	if not vim.loop.fs_stat(config.data_path) then
		local file = io.open(config.data_path, "w")
		if file then
			file:write("return { notes = {}, next_id = 1 }")
			file:close()
		end
	end
end

-- Load notes from disk
local function load_data()
	ensure_data_path()
	local success, loaded = pcall(dofile, config.data_path)

	if success and type(loaded) == "table" then
		notes = loaded.notes or {}
		next_id = loaded.next_id or 1
	else
		notes = {}
		next_id = 1
	end
end

-- Save notes to disk using vim.inspect (safe serialization)
local function save_data()
	ensure_data_path()
	local file = io.open(config.data_path, "w")
	if not file then
		vim.notify("Failed to open data file for writing", vim.log.levels.ERROR)
		return false
	end

	local data = {
		notes = notes,
		next_id = next_id,
	}
	local serialized = "return " .. vim.inspect(data)
	file:write(serialized)
	file:close()
	return true
end

-- Get current file information
local function get_current_file_info()
	local bufnr = 0
	local file = vim.api.nvim_buf_get_name(bufnr)

	if file == "" then
		return nil, "Buffer has no associated file."
	end

	if not vim.loop.fs_stat(file) then
		return nil, "File not saved to disk. Please save first."
	end

	return {
		full_path = file,
		name = vim.fn.fnamemodify(file, ":t"),
		relative_path = vim.fn.fnamemodify(file, ":."),
		line = vim.api.nvim_win_get_cursor(0)[1],
		col = vim.api.nvim_win_get_cursor(0)[2],
	},
		nil
end

-- Format timestamp
local function get_timestamp()
	return os.date("%Y-%m-%d %H:%M:%S")
end

-------------------------------------------------------------------------------
-- Core Functions
-------------------------------------------------------------------------------

-- Add a new note
function M.add_note()
	local file_info, err = get_current_file_info()
	if not file_info then
		vim.notify(err, vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "Concise note: " }, function(concise)
		if not concise or concise == "" then
			return
		end

		vim.ui.input({ prompt = "Extended explanation (optional): " }, function(extended)
			local note = {
				id = next_id,
				file = file_info.full_path,
				file_name = file_info.name,
				relative_path = file_info.relative_path,
				line = file_info.line,
				col = file_info.col,
				concise_content = concise,
				extended_explanation = extended or "",
				created_at = get_timestamp(),
			}

			notes[next_id] = note
			next_id = next_id + 1

			if save_data() then
				vim.notify(string.format("📌 Note #%d saved", note.id), vim.log.levels.INFO)
			end
		end)
	end)
end

-- Jump to a note by ID
function M.jump_to_note(id)
	local note = notes[id]
	if not note then
		vim.notify(string.format("Note #%d not found", id), vim.log.levels.WARN)
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
		vim.notify("Failed to jump to note: " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- Remove a note by ID
function M.remove_note(id)
	if not notes[id] then
		vim.notify(string.format("Note #%d not found", id), vim.log.levels.WARN)
		return
	end

	notes[id] = nil
	if save_data() then
		vim.notify(string.format("🗑️ Note #%d removed", id), vim.log.levels.INFO)
	end
end

-- Get all notes as a sorted array
local function get_notes_array()
	local result = {}
	for _, note in pairs(notes) do
		table.insert(result, note)
	end

	-- Sort by ID (most recent first)
	table.sort(result, function(a, b)
		return a.id > b.id
	end)

	return result
end

-------------------------------------------------------------------------------
-- Telescope Pickers
-------------------------------------------------------------------------------

-- Custom previewer for notes
local function create_note_previewer()
	return previewers.new_buffer_previewer({
		define_preview = function(self, entry)
			local note = entry.value
			local lines = {
				string.format("📌 Code Note #%d", note.id),
				"",
				"File: " .. note.file_name,
				"Path: " .. note.relative_path,
				string.format("Location: Line %d, Column %d", note.line, note.col),
				"Created: " .. note.created_at,
				"",
				"─────────────────────────────────────",
				"",
				"💡 " .. note.concise_content,
			}

			if note.extended_explanation and note.extended_explanation ~= "" then
				table.insert(lines, "")
				table.insert(lines, "📝 Extended Explanation:")
				table.insert(lines, "")
				-- Split extended explanation by newlines
				for line in note.extended_explanation:gmatch("[^\r\n]+") do
					table.insert(lines, line)
				end
			end

			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
			vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
		end,
	})
end

-- List all notes in Telescope
function M.list_notes()
	local notes_array = get_notes_array()

	if #notes_array == 0 then
		vim.notify("No notes saved yet!", vim.log.levels.INFO)
		return
	end

	pickers
		.new({}, {
			prompt_title = string.format("Code Notes (%d total)", #notes_array),
			finder = finders.new_table({
				results = notes_array,
				entry_maker = function(note)
					local display_text =
						string.format("#%-4d %s:%-4d  %s", note.id, note.file_name, note.line, note.concise_content)

					return {
						value = note,
						ordinal = string.format("%d %s %s", note.id, note.file_name, note.concise_content),
						display = display_text,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = create_note_previewer(),
			attach_mappings = function(prompt_bufnr, map)
				-- Enter: Jump to note
				actions.select_default:replace(function()
					local selection = actions_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value then
						M.jump_to_note(selection.value.id)
					end
				end)

				-- Ctrl-d: Delete note
				map("i", "<C-d>", function()
					local selection = actions_state.get_selected_entry()
					if selection and selection.value then
						M.remove_note(selection.value.id)
						-- Refresh the picker
						local current_picker = actions_state.get_current_picker(prompt_bufnr)
						current_picker:refresh(
							finders.new_table({
								results = get_notes_array(),
								entry_maker = function(note)
									return {
										value = note,
										ordinal = string.format(
											"%d %s %s",
											note.id,
											note.file_name,
											note.concise_content
										),
										display = string.format(
											"#%-4d %s:%-4d  %s",
											note.id,
											note.file_name,
											note.line,
											note.concise_content
										),
									}
								end,
							}),
							{ reset_prompt = false }
						)
					end
				end)

				map("n", "<C-d>", function()
					local selection = actions_state.get_selected_entry()
					if selection and selection.value then
						M.remove_note(selection.value.id)
						local current_picker = actions_state.get_current_picker(prompt_bufnr)
						current_picker:refresh(
							finders.new_table({
								results = get_notes_array(),
								entry_maker = function(note)
									return {
										value = note,
										ordinal = string.format(
											"%d %s %s",
											note.id,
											note.file_name,
											note.concise_content
										),
										display = string.format(
											"#%-4d %s:%-4d  %s",
											note.id,
											note.file_name,
											note.line,
											note.concise_content
										),
									}
								end,
							}),
							{ reset_prompt = false }
						)
					end
				end)

				return true
			end,
		})
		:find()
end

-- Delete notes via Telescope picker
function M.delete_notes()
	local notes_array = get_notes_array()

	if #notes_array == 0 then
		vim.notify("No notes to delete!", vim.log.levels.INFO)
		return
	end

	pickers
		.new({}, {
			prompt_title = "Delete Code Notes (Enter to delete, Esc to cancel)",
			finder = finders.new_table({
				results = notes_array,
				entry_maker = function(note)
					return {
						value = note,
						ordinal = string.format("%d %s %s", note.id, note.file_name, note.concise_content),
						display = string.format(
							"#%-4d %s:%-4d  %s",
							note.id,
							note.file_name,
							note.line,
							note.concise_content
						),
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = create_note_previewer(),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = actions_state.get_selected_entry()
					if selection and selection.value then
						M.remove_note(selection.value.id)
						-- Refresh picker to show updated list
						local current_picker = actions_state.get_current_picker(prompt_bufnr)
						local remaining_notes = get_notes_array()

						if #remaining_notes == 0 then
							actions.close(prompt_bufnr)
							vim.notify("All notes deleted!", vim.log.levels.INFO)
							return
						end

						current_picker:refresh(
							finders.new_table({
								results = remaining_notes,
								entry_maker = function(note)
									return {
										value = note,
										ordinal = string.format(
											"%d %s %s",
											note.id,
											note.file_name,
											note.concise_content
										),
										display = string.format(
											"#%-4d %s:%-4d  %s",
											note.id,
											note.file_name,
											note.line,
											note.concise_content
										),
									}
								end,
							}),
							{ reset_prompt = false }
						)
					end
				end)
				return true
			end,
		})
		:find()
end

-- Clear all notes (with confirmation)
function M.clear_all_notes()
	local notes_array = get_notes_array()
	local count = #notes_array

	if count == 0 then
		vim.notify("No notes to clear!", vim.log.levels.INFO)
		return
	end

	vim.ui.input({
		prompt = string.format("Delete all %d notes? (yes/no): ", count),
	}, function(input)
		if input and input:lower() == "yes" then
			notes = {}
			next_id = 1
			if save_data() then
				vim.notify(string.format("🗑️ All %d notes cleared", count), vim.log.levels.INFO)
			end
		else
			vim.notify("Cancelled", vim.log.levels.INFO)
		end
	end)
end

-------------------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------------------

-- Load data on module load
load_data()

return M
