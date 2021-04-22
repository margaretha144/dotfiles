#!/usr/bin/env bash
# source $HOME/global-var

type -p {"mpd","mpc","ffmpeg"} &> /dev/null || exit 1

w3m() {
    [[ "$1" = "clear" ]] && printf "\ec" && exit 0 || :
    shopt -s nullglob
    w3m_paths=({/usr/{local/,},~/.nix-profile/}{lib,libexec,lib64,libexec64}/w3m/w3mi*)
    shopt -u nullglob
    
    [[ -x "${w3m_paths[0]}" ]] && w3m_img_path="${w3m_paths[0]}" || :
    if type -p {"xprop","xwininfo","bc"} &> /dev/null; then
        win_id="$(xprop -root _NET_ACTIVE_WINDOW | awk -F'# ' '{print $2}')"
        while true; do
            #get_height="$(xwininfo -id $win_id | awk -F ':' '/Height/{print $2}')"
            get_width="$(xwininfo -id $win_id | awk -F ':' '/Width/{print $2}')"
            #h_size="$(bc <<< $get_height/1.29)"
            w_size="$(bc <<< $get_width/1.166)"
            
            read -rt ".5" <> <(:) || :
            
            # Keep aspect ratio by depend on width for both
            printf '%b\n%s;\n%s\n' "0;1;0;0;$w_size;$w_size;;;;;${COVER}" 3 4 | "${w3m_img_path:-false}" &> /dev/null
        done
    else
        read -rt ".5" <> <(:) || :
        printf "\ec\e[1;31merror: \e[0;32mxorg-xprop\e[0m, \e[0;32mxorg-xwininfo\e[0m, and \e[0;32mbc\e[0m not installed!" >&2
    fi
}

pixbuf() {
    [[ "$1" = "clear" ]] && printf "\e]20;;100x100+1000+1000\a" && exit 0 || :
    printf "\e]20;${COVER};86x86+04+04:op=keep-aspect\a"
}

MUSIC_DIR="$HOME/Media/Music/"
COVER="/tmp/cover.jpg"

{
    album="$(mpc --format %album% current -p 6600)"
    file="$(mpc --format %file% current -p 6600)"
    album_dir="${file%/*}"
    [[ -z "$album_dir" ]] && exit 1 || :
    album_dir="$MUSIC_DIR/$album_dir"

    covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \; )"
    src="$(echo -n "$covers" | head -n1)"
    rm -f "$COVER" &> /dev/null
    
    # Album Art
    if [[ -n "$src" ]]; then
        # Resize the image's width to 500px (ffmpeg/imagemagick)
        ffmpeg -i "$src" -vf scale=500:500 "$COVER" &> /dev/null
        #convert "$src" -resize 500x "$COVER" &> /dev/null
        if [[ -f "$COVER" ]]; then
            "w3m"
        else
            "w3m" clear
        fi
    else
        "w3m" clear
    fi        
} &

