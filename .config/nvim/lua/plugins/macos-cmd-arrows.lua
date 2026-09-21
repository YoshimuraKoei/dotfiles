local cmd_left = "\27[1;9D"
local cmd_right = "\27[1;9C"
local cmd_up = "\27[1;9A"
local cmd_down = "\27[1;9B"

local left_keys = { cmd_left, "<M-Left>", "<A-Left>", "<D-Left>" }
local right_keys = { cmd_right, "<M-Right>", "<A-Right>", "<D-Right>" }
local up_keys = { cmd_up, "<M-Up>", "<A-Up>", "<D-Up>" }
local down_keys = { cmd_down, "<M-Down>", "<A-Down>", "<D-Down>" }

local function add_line_navigation_maps(maps)
  for _, key in ipairs(left_keys) do
    maps.n[key] = { "0", desc = "Go to start of line" }
    maps.i[key] = { "<C-o>0", desc = "Go to start of line" }
    maps.v[key] = { "0", desc = "Go to start of line" }
    maps.c[key] = { "<Home>", desc = "Go to start of command line" }
  end

  for _, key in ipairs(right_keys) do
    maps.n[key] = { "$", desc = "Go to end of line" }
    maps.i[key] = { "<C-o>$", desc = "Go to end of line" }
    maps.v[key] = { "$", desc = "Go to end of line" }
    maps.c[key] = { "<End>", desc = "Go to end of command line" }
  end

  for _, key in ipairs(up_keys) do
    maps.n[key] = { "gg", desc = "Go to start of file" }
    maps.i[key] = { "<C-o>gg", desc = "Go to start of file" }
    maps.v[key] = { "gg", desc = "Go to start of file" }
    maps.c[key] = { "<Home>", desc = "Go to start of command line" }
  end

  for _, key in ipairs(down_keys) do
    maps.n[key] = { "G", desc = "Go to end of file" }
    maps.i[key] = { "<C-o>G", desc = "Go to end of file" }
    maps.v[key] = { "G", desc = "Go to end of file" }
    maps.c[key] = { "<End>", desc = "Go to end of command line" }
  end

  return maps
end

return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.i = opts.mappings.i or {}
      opts.mappings.v = opts.mappings.v or {}
      opts.mappings.c = opts.mappings.c or {}

      add_line_navigation_maps(opts.mappings)
    end,
  },
}
