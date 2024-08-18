function fish_greeting
    set -l reset (set_color normal)
    set -l green (set_color green)
    set -l red (set_color red)
    set -l blue (set_color blue)
    set -l yellow (set_color yellow)
    # set -l bggreen (set_color '#000000' --background green)
    # set -l bgred (set_color '#000000' --background red)
    # set -l bgblue (set_color '#000000' --background blue)
    # set -l bgyellow (set_color '#000000' --background yellow)

    printf "%s><>%s Greetings Terrestial! %s<><%s\n" $blue $reset $blue $reset
    begin
        set -l other_fish_processes_running (command pgrep fish | count)
        switch $other_fish_processes_running
            case 0
                printf '%s><>%s This is the only fish swimming in the %sprocess sea%s right now!\n' $blue $reset $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
            case 1
                printf '%s><>%s There is %s%d%s other fish swimming in the %sprocess sea%s right now!\n' $blue $reset $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
            case '*'
                printf '%s><>%s There are %s%d%s other fishes swimming in the %sprocess sea%s right now!\n' $blue $reset $blue $other_fish_processes_running $reset (set_color --dim --italics) $reset
        end
    end

    begin
        set -l f $__fish_user_data_dir/github_fish_shell_issues
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
            # print red arrow pointing up
        else if test $diff -lt 0
            printf ' down %s%d%s from yesterday :)' $green $diff $reset
            # print green arrow pointing down
        else
            printf ' (same as yesterday)'
            # print nothing
        end
        echo
    end

    begin
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
            printf ' up %s%d%s from yesterday :(' $red $diff $reset
            # print red arrow pointing up
        else if test $diff -lt 0
            printf ' down %s%d%s from yesterday :)' $green $diff $reset
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
    printf "%stime%s:     %s%s:%s:%s%s\n" $blue $reset $time_color $hour $minute $second $reset

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
end
