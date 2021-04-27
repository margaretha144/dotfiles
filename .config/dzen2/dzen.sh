#!/usr/bin/env sh

sleep 1;

orange="#fa946e"
red="#FA5AA4"
blue="#63C5EA"
green="#2BE491"
magenta="#CF8EF4"
font="M+ 1mn:style=Bold:size=10"
icon_dir="$HOME/.local/share/icons/bitmap/"

get_time() {
	icon_time="${icon_dir}tile.xbm"
	current_time="$(date +"  %R %p  ")"
	echo "^bg($orange)$current_time"
}

get_music() {
	music_play="^i(${icon_dir}play.xbm)"
	music_pause="^i(${icon_dir}pause.xbm)"
	music_status=$(mpc | sed -n '2p' | awk '{print $1}')
	#[[ -z $(mpc current) ]] && echo "" || echo "$music_icon Playing: $(mpc current)"
	if [[ -z $(mpc current) ]]; then
		echo ""
	elif [ "$music_status" = "[paused]" ]; then
		echo "$music_pause Paused: $(mpc current)"
	else
		echo "$music_play Playing: $(mpc current)"
	fi
}

get_network_speed() {
	interface="wlp0s26u1u1"
	netUp_icon="^fg($red)^i(${icon_dir}net_up_03.xbm)^fg()"
	netDown_icon="^fg($blue)^i(${icon_dir}net_down_03.xbm)^fg()"
	receive1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
	transfer1=$(cat /sys/class/net/$interface/statistics/tx_bytes)
	sleep 1

	receive2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
	transfer2=$(cat /sys/class/net/$interface/statistics/tx_bytes)

	receiveByte=$(expr $receive2 - $receive1)
	transByte=$(expr $transfer2 - $transfer1)

	receiveKB=$(expr $receiveByte / 1024)
	transKB=$(expr $transByte / 1024)

	echo "$netUp_icon Up: $transKB kB/s    $netDown_icon Down: $receiveKB kB/s"
}

get_weather() {
	api_key="0755c771fe75b0120ec32ae2e76d84e7"
	city_id="7688114"

	icon_sunny="^i(${icon_dir}sunny.xbm)"
	icon_cloudy="^i(${icon_dir}cloudy.xbm)"
	icon_rainy="^i(${icon_dir}rain.xbm)"
	icon_thunder="^i(${icon_dir}thunder.xbm)"
	icon_snow="^i(${icon_dir}show.xbm)"
	icon_misc="${icon_dir}empty.xbm"

	
	weather_url="http://api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}&units=metric"
	weather_info=$(wget -qO- $weather_url)
	weather_main=$(echo $weather_info | grep -o -e '\"main\":\"[a-Z]*\"' | awk -F ':' '{print $2}' | tr -d '"')
	weather_temp=$(echo $weather_info | grep -o -e '\"temp\":\-\?[0-9]*' | awk -F ':' '{print $2}' | tr -d '"')

	if [[ $weather_main = *Snow* ]]; then
		echo "$icon_snow Snow ${weather_temp}˚C"
	elif [[ $weather_main = *Rain* ]] || [[ $weather_main = *Drizzle* ]]; then
		echo "$icon_rainy Rainy ${weather_temp}˚C"
	elif [[ $weather_main = *Cloud* ]]; then
		echo "$icon_cloudy Cloudy ${weather_temp}˚C"
	elif [[ $weather_main = *Clear* ]]; then
		echo "$icon_sunny Sunny ${weather_temp}˚C"
	elif [[ $weather_main = *Fog* ]] || [[ $weather_main = *Mist* ]]; then
		echo "$icon_cloudy Fog ${weather_temp}˚C"
	else
		echo "$icon_misc Unknown"
	fi
}

get_memory() {
	icon_memory="${icon_dir}mem.xbm"
	current_memory=$(printf "%.f" $(free | grep Mem | awk '{print $3/$2 * 100.0}'))
	echo "^fg($magenta)^i($icon_memory)^fg() Memory: $current_memory% "
}

get_cpu() {
	cpu_icon="${icon_dir}cpu.xbm"
	read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	cpu_active_prev=$((user+system+nice+softirq+steal))
	cpu_total_prev=$((user+system+nice+softirq+steal+idle+iowait))

	usleep 50000

	read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	cpu_active_cur=$((user+system+nice+softirq+steal))
	cpu_total_cur=$((user+system+nice+softirq+steal+idle+iowait))
	cpu_util=$((100 * (cpu_active_cur - cpu_active_prev) / (cpu_total_cur - cpu_total_prev)))
	echo "^fg($green)^i($cpu_icon)^fg() $(printf "CPU: %s%%" $cpu_util)"
}

while true; do
	echo "^fn($font)$(get_music)    $(get_network_speed)    $(get_cpu)    $(get_memory)   $(get_weather)    $(get_time)";
	sleep 1;
done | dzen2 -x 410 -y 10 -h 24 -w 940 -p -ta r -e ''
