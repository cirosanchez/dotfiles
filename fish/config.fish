source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

function fish_greeting
    fastfetch -c ~/.config/themes/current/fastfetch.jsonc
end
