-- Restore layouts written by the project toggle script after a reload.
local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

require_all.files(
  paths.state_home .. "/omarchy/workspace-layouts",
  nil,
  { reload = true }
)
