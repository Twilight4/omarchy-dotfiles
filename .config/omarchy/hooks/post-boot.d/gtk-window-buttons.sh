#!/bin/bash

# Remove in-header window buttons (close/min/max) from GNOME/GTK apps.
# GTK4/libadwaita reads org.gnome.desktop.wm.preferences:button-layout via
# GSettings, which OVERRIDES gtk-decoration-layout in gtk-{3,4}.0/settings.ini
# (those files already say ':' — necessary for GTK3, not sufficient for GTK4).
# dconf persists this across sessions; this hook re-asserts it so a dconf reset
# or fresh deploy can't regress it. ':' = no buttons on either side.
gsettings set org.gnome.desktop.wm.preferences button-layout ':'
