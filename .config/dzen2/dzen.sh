#!/usr/bin/env sh

sleep 1;

# COLORS
ORANGE="#FA946E"
RED="#FA5AA4"
BLUE="#63C5EA"
GREEN="#2BE491"
MAGENTA="#CF8EF4"
CYAN="#89CCF7"
BACKGROUND="#F9F9F9"
FOREGROUND="#4C566A"


FONT="M+ 1mn:style=Bold:size=10"
ICON_DIR="$HOME/.local/share/icons/bitmap/"

get_time() {
	ICON_TIME="${ICON_DIR}tile.xbm"
	CURRENT_TIME="$(date +"  %R %p  ")"
	echo "^bg($BLUE)^fg($BACKGROUND)$CURRENT_TIME"
}

get_music() {
	MUSIC_PLAY="^i(${ICON_DIR}play.xbm)"
	MUSIC_PAUSE="^i(${ICON_DIR}pause.xbm)"
	MUSIC_STATUS=$(mpc | sed -n '2p' | awk '{print $1}')
	
	if [[ -z $(mpc current) ]]; then
		echo ""
	elif [ "$MUSIC_STATUS" = "[paused]" ]; then
		echo "^fg($ORANGE)$MUSIC_PAUSE ^fg()Paused: $(mpc current)"
	else
		echo "^fg($ORANGE)$MUSIC_PLAY ^fg()Playing: $(mpc current)"
	fi
}

get_network_speed() {
	INTERFACE="wlp0s26u1u1"
	NETUP_ICON="^fg($RED)^i(${ICON_DIR}net_up_03.xbm)^fg()"
	NETDOWN_ICON="^fg($BLUE)^i(${ICON_DIR}net_down_03.xbm)^fg()"
	RECEIVE_1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
	TRANSFER_1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
	sleep 1

	RECEIVE_2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
	TRANSFER_2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

	RECEIVE_BYTE=$(expr $RECEIVE_2 - $RECEIVE_1)
	TRANSFER_BYTE=$(expr $TRANSFER_2 - $TRANSFER_1)

	RECEIVE_KB=$(expr $RECEIVE_BYTE / 1024)
	TRANSFER_KB=$(expr $TRANSFER_BYTE / 1024)

	echo "$NETUP_ICON Up: $TRANSFER_KB kB/s    $NETDOWN_ICON Down: $RECEIVE_KB kB/s"
}

get_weather() {
	API_KEY="0755c771fe75b0120ec32ae2e76d84e7"
	CITY_ID="1625812"

	ICON_SUNNY="^i(${ICON_DIR}sunny.xbm)"
	ICON_CLOUDY="^i(${ICON_DIR}cloudy.xbm)"
	ICON_RAINY="^i(${ICON_DIR}rain.xbm)"
	ICON_THUNDER="^i(${ICON_DIR}thunder.xbm)"
	ICON_SNOW="^i(${ICON_DIR}show.xbm)"
	ICON_MISC="${ICON_DIR}empty.xbm"

	
	WEATHER_URL="http://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric"
	WEATHER_INFO=$(wget -qO- $WEATHER_URL)
	WEATHER_MAIN=$(echo $WEATHER_INFO | grep -o -e '\"main\":\"[a-Z]*\"' | awk -F ':' '{print $2}' | tr -d '"')
	WEATHER_TEMP=$(echo $WEATHER_INFO | grep -o -e '\"temp\":\-\?[0-9]*' | awk -F ':' '{print $2}' | tr -d '"')

	if [[ $WEATHER_MAIN = *Snow* ]]; then
		echo "^fg($CYAN)$ICON_SNOW ^fg()Snow ${WEATHER_TEMP}˚C"
	elif [[ $WEATHER_MAIN = *Rain* ]] || [[ $WEATHER_MAIN = *Drizzle* ]]; then
		echo "^fg($CYAN)$ICON_RAINY ^fg()Rainy ${WEATHER_TEMP}˚C"
	elif [[ $WEATHER_MAIN = *Cloud* ]]; then
		echo "^fg($CYAN)$ICON_CLOUDY ^fg()Cloudy ${WEATHER_TEMP}˚C"
	elif [[ $WEATHER_MAIN = *Clear* ]]; then
		echo "^fg($CYAN)$ICON_SUNNY ^fg()Sunny ${WEATHER_TEMP}˚C"
	elif [[ $WEATHER_MAIN = *Fog* ]] || [[ $WEATHER_MAIN = *Mist* ]]; then
		echo "^fg($CYAN)$ICON_CLOUDY ^fg()Fog ${WEATHER_TEMP}˚C"
	else
		echo "^fg($CYAN)$ICON_MISC ^fg()Unknown"
	fi
}

get_memory() {
	ICON_MEMORY="${ICON_DIR}mem.xbm"
	CURRENT_MEMORY=$(printf "%.f" $(free | grep Mem | awk '{print $3/$2 * 100.0}'))
	echo "^fg($MAGENTA)^i($ICON_MEMORY)^fg() Memory: $CURRENT_MEMORY% "
}

get_cpu() {
	CPU_ICON="${ICON_DIR}cpu.xbm"
	read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	CPU_ACTIVE_PREV=$((user+system+nice+softirq+steal))
	CPU_TOTAL_PREV=$((user+system+nice+softirq+steal+idle+iowait))

	usleep 50000

	read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	CPU_ACTIVE_CUR=$((user+system+nice+softirq+steal))
	CPU_TOTAL_CUR=$((user+system+nice+softirq+steal+idle+iowait))
	CPU_UTIL=$((100 * (CPU_ACTIVE_CUR - CPU_ACTIVE_PREV) / (CPU_TOTAL_CUR - CPU_TOTAL_PREV)))
	echo "^fg($GREEN)^i($CPU_ICON)^fg() $(printf "CPU: %s%%" $CPU_UTIL)"
}

while true; do
	echo "^fn($FONT)$(get_music)    $(get_network_speed)    $(get_cpu)    $(get_memory)   $(get_weather)    $(get_time)";
	sleep 1;
done | dzen2 -fg $FOREGROUND -bg $BACKGROUND -x 410 -y 10 -h 24 -w 940 -p -ta r -e ''
