-- Restore layouts written by the project toggle script after a reload.
local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")
local layouts_dir = paths.state_home .. "/omarchy/workspace-layouts"

package.path = layouts_dir .. "/?.lua;" .. package.path

require_all.files(
  layouts_dir,
  nil,
  { reload = true }
)
