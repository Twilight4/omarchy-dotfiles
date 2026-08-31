-- Workspace rules. The special workspaces get populated the first time they
-- are opened (imported from the Garuda workspaces.conf).

hl.workspace_rule({ workspace = "special:comma",      on_created_empty = "emacsclient -c" })
hl.workspace_rule({ workspace = "special:scratchpad", on_created_empty = "~/.config/hypr/ws-scripts/ws-monitoring" })
hl.workspace_rule({ workspace = "special:floating",   on_created_empty = "nautilus" })

-- NOT imported (pending user decision): the Garuda "smart gaps" workspace
-- rules — w[tv1]s[false] / f[1]s[false] with gaps_out = 0, gaps_in = 0 —
-- which collapse the gaps when a workspace holds a single window. The
-- border_size 0 / rounding 0 window-rule variant of the same matchers IS
-- imported (see windowrules.lua).
