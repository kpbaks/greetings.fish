function fish_greeting
    set -l reset (set_color normal)
    set -l green (set_color green)
    set -l red (set_color red)
    set -l blue (set_color blue)
    set -l yellow (set_color yellow)
    set -l url_markup (set_color cyan --italics)

    set -l prefix "$blue><>$reset"
    # set -l bggreen (set_color '#000000' --background green)
    # set -l bgred (set_color '#000000' --background red)
    # set -l bgblue (set_color '#000000' --background blue)
    # set -l bgyellow (set_color '#000000' --background yellow)
    set -l cache_dir $__fish_user_data_dir/greetings.fish
    test -d $cache_dir; or command mkdir $cache_dir
    set -l cache_stale_after 86400 # 24 hours

    printf "%s><>%s Greetings Terrestial! %s<><%s\n" $blue $reset $blue $reset
    # Print version of running fish interpreter, and check if a newer version is available
    begin
        set -l cache $cache_dir/latest_fish_version
        if not test -f $cache; or test (path mtime --relative $cache) -gt $cache_stale_after
            # Download cache if it does not exist or have become stale
            set -l url https://api.github.com/repos/fish-shell/fish-shell/releases/latest
            # Print a line indicating a network request is happening, as can take some time with poor connection
            printf '%s fetching version of latest release from %s%s%s ...\n' $prefix $url_markup $url $reset
            # https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#cursor-controls
            command curl -s $url | string match --regex --groups-only '"tag_name": "(.+)"' >$cache
            # Delete the indicator afterwards
            printf '\x1b[1A' # Move the cursor one line up
            printf "\x1b[0G" # Move cursor to the start of the line (0'th column).
            printf "\x1b[2K" # Clear the current line, to erase the leftover (partial) prompt.
        end

        read latest_fish_version <$cache

        if test $version != $latest_fish_version
            echo $version | read -d . -l major minor patch
            echo $latest_fish_version | read -d . -l latest_major latest_minor latest_patch

            set -l major_color $reset
            set -l major_color_newest_version $reset
            if test $major -lt $latest_major
                set major_color $red
                set major_color_newest_version $green
            end

            set -l minor_color $reset
            set -l minor_color_newest_version $reset
            if test $minor -lt $latest_minor
                set minor_color $red
                set minor_color_newest_version $green
            end

            set -l patch_color $reset
            set -l patch_color_newest_version $reset
            if test $patch -lt $latest_patch
                set patch_color $red
                set patch_color_newest_version $green
            end

            printf '%s A newer fish is available! current version  %s%d%s.%s%d%s.%s%d%s, the latest version is %s%s%s.%s%s%s.%s%s%s\n' \
                $prefix \
                $major_color $major $reset \
                $minor_color $minor $reset \
                $patch_color $patch $reset \
                $major_color_newest_version $latest_major $reset \
                $minor_color_newest_version $latest_minor $reset \
                $patch_color_newest_version $latest_patch $reset
            printf '%s><>%s See %shttps://github.com/fish-shell/fish-shell/releases/%s\n' (set_color cyan --underline) $reset
        end
    end

    # Notify how many other fish processes are running
    begin
        # NOTE: this does not filter out processes whose binary might start with the prefix "fish"
        # Like if `fish_key_reader` or `fish_indent` is running.
        # This could be filtered out, but would involve more computation, that I have deemed undesirable
        # A snappier greeting is more important.
        set -l other_fish_processes_running (command pgrep fish | count)
        switch $other_fish_processes_running
            case 0
                printf '%s This is the only fish swimming in the %sprocess sea%s right now!\n' $prefix $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
            case 1
                printf '%s There is %s%d%s other fish swimming in the %sprocess sea%s right now!\n' $prefix $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
            case '*'
                printf '%s There are %s%d%s other fishes swimming in the %sprocess sea%s right now!\n' $prefix $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
        end
    end

    begin
        # TODO: refactor caching

        set -l cache_num_issues $cache_dir/fish_shell_num_github_issues
        if not test -f $cache_num_issues; or test (path mtime --relative $cache_num_issues) -gt $cache_stale_after
            command gh issue list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
        end
        read num_issues <$cache_num_issues

        set -l cache_num_issues_yesterday $cache_dir/fish_shell_num_github_issues_yesterday
        if not test -f $cache_num_issues_yesterday
            echo $num_issues >$cache_num_issues_yesterday
        end
        read num_issues_yesterday <$cache_num_issues_yesterday
        set -l diff (math "$num_issues - $num_issues_yesterday")
        if test $diff -gt 0
            # New issues have been added
            # NOTE: not guaranteed, as one issue could have been closed and another have been opened
            # To be more robust, would have to download the identifier of the latest issue, and compare it
        else if test $diff -lt 0
            # 1 or more issues have been closed
        else
            # No update
            # Again, one issue could have been closed and another have been opened
        end




        set -l cache_new_issues $cache_dir/fish_shell_new_issues
        if not test -f $f
            # gh pr list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
            gh issue list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
        end
        read num_issues_previous <$f

        set -l mtime (path mtime --relative $f)
        if test $mtime -gt 86400
            gh issue list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
        end
        read num_issues <$f

        printf '%s><>%s %sissues%s: %s%d%s' $blue $reset $red $reset $red $num_issues $reset

        set -l diff (math "$num_issues - $num_issues_previous")
        if test $diff -gt 0
            printf ' up %s%d%s from yesterday :(' $red $diff $reset
            if not test -f $new_issues
            end
            # TODO: query the title and other details of the issue
            # gh issue list --repo fish-shell/fish-shell --state=open --json=title,author,url,title,comments --limit=2 | jaq -r '.[] | "\(.title)\n\(.url)\n\(.author.login)\n\(.comments | length)"'
            # print red arrow pointing up
        else if test $diff -lt 0
            printf ' down %s%d%s from yesterday :)' $green $diff $reset
            # print green arrow pointing down
            # TODO: list which one got fixed
        else
            printf ' (same as yesterday)'
            # print nothing
        end
        echo
    end

    begin
        # TODO: refactor caching
        set -l f $__fish_user_data_dir/github_fish_shell_prs
        if not test -f $f
            gh pr list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
        end
        read num_prs_previous <$f

        set -l mtime (path mtime --relative $f)
        if test $mtime -gt 86400
            gh pr list --repo fish-shell/fish-shell --state=open --json=id --jq=length --limit=9999 >$f
        end

        read num_prs <$f

        printf '%s><>%s %sprs%s: %s%d%s' $blue $reset $green $reset $green $num_prs $reset
        set -l diff (math "$num_prs - $num_prs_previous")
        if test $diff -gt 0
            # TODO: query the title and other details of the pr
            printf ' up %s%d%s from yesterday :)' $green $diff $reset
            # print red arrow pointing up
        else if test $diff -lt 0
            printf ' down %s%d%s from yesterday :|' $yellow $diff $reset
            # print green arrow pointing down
        else
            printf ' (same as yesterday)'
            # print nothing
        end
        echo
    end

    # TODO: move logic here to check if newest version

    printf '%s><>%s This %sfish%s is version %s%s%s\n' $blue $reset $blue $reset $yellow $version $reset

    set -l urls https://github.com/fish-shell/fish-shell/{pull,issues}/ https://fishshell.com/docs/current/

    for url in $urls
        printf '%s><>%s %s%s%s\n' $blue $reset (set_color cyan) $url $reset
    end

    # TODO: make pr to create `status is-private`
    if set -q fish_private_mode; and test $fish_private_mode -eq 1
        printf "%s><>%s Started in %sprivate mode%s, history is not persisted 😏\n" $blue $reset $red $reset
    end

    printf '%s><>%s Ready to dive in, and become a %sfish%s?\n\n' $blue $reset $blue $reset
    # printf '%s%sversion%s: %s\n' $blue $reset $version
    # printf '%skernel%s:  %s\n' $blue $reset (command uname --kernel-release)
    # read uptime_seconds uptime_nanoseconds </proc/uptime
    # printf "%suptime%s:  %s\n" $blue $reset (peopletime (math "$uptime_seconds * 1000"))

    begin
        printf '%sterminal%s: ' $blue $reset
        if set -q KITTY_PID
            printf 'kitty %s\n' (kitty --version | string split ' ' -f 2)
            # TODO: check if newest version
        else if set -q ALACRITTY_WINDOW_ID
            printf 'alacritty %s\n' (alacritty --version | string split ' ' -f 2)
        else if set -q KONSOLE_VERSION
            set -l major (string sub --start=1 --end=2 $KONSOLE_VERSION)
            set -l minor (string sub --start=3 --end=4 $KONSOLE_VERSION)
            set -l patch (string sub --start=5 --end=6 $KONSOLE_VERSION)
            printf 'konsole %s.%s.%s\n' $major $minor $patch
        else
            printf '%sunknown%s\n' $red $reset
        end
    end

    command date +%H:%M:%S | read --delimiter : hour minute second
    set -l time_color $green
    test $hour -ge 22; and set time_color $red

    set -l seconds_passed (math "$hour * 3600 + $minute * 60 + $second")
    set -l ratio_of_day_passed (math "$seconds_passed / 86400")

    set -l cells_available (math $COLUMNS - 23) # 5 + 5 + 5 + 8
    set -l progressbar_length (math "round($ratio_of_day_passed * $cells_available)")
    # ▏ # 1/8
    # ▎ # 1/4
    # ▍ # 3/8
    # ▌ # 1/2
    # ▋ # 5/8
    # ▊ # 3/4
    # ▉ # 7/8
    # █ # 1/1

    set -l progressbar (string repeat --count $progressbar_length "█")
    set -l progressbar_end todo
    printf "%stime%s:     %s%s:%s:%s%s     %s%s%s\n" $blue $reset $time_color $hour $minute $second $reset $time_color $progressbar $reset

    # if command -q fastfetch
    #     fastfetch --logo none --structure Memory
    #     fastfetch --logo none --structure Battery
    #     fastfetch --logo none --structure CPUUsage
    #     # fastfetch --logo none --structure CPUCache
    #     fastfetch --logo none --structure Wifi
    #     fastfetch --logo none --structure Terminal
    #     fastfetch --logo none --structure PublicIp
    #     fastfetch --logo none --structure LocalIp
    #     # fastfetch --logo none --structure Media
    #     # fastfetch --logo none --structure Kernel
    # end

    # RAM
    # begin
    #     read --line total free available </proc/meminfo
    # end


    # echo
    # cal

    set -l n 5
    # command -q hostnamectl; and test (random 1 $n) -eq $n; and command hostnamectl
    # NOTE: custom script defined with `home-manager`
    command -q xkcd; and test (random 1 $n) -eq $n; and xkcd

    set_color --dim
    string repeat --count $COLUMNS -
    set_color normal
end
