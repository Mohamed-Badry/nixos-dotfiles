local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.bidi_enabled = true
config.bidi_direction = 'AutoLeftToRight'
config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'JetBrainsMono Nerd Font', 'Kawkab Mono' }
config.font_size = 12.0
config.window_background_opacity = 0.93
config.window_decorations = 'NONE'
config.enable_tab_bar = false
config.initial_cols = 120
config.initial_rows = 35
config.window_close_confirmation = 'NeverPrompt'
config.color_scheme = 'Noctalia'
config.default_prog = { 'fish' }
return config
