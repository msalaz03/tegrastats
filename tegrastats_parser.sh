# !/bin/bash
# Description: Helper script to help monitor the system for potential issues.

TEAL='\033[4;36m' # Teal
NC='\033[0m' # No Color
YELLOW='\033[1;33m' # Yellow

function info_log() {
    echo -e "${TEAL}SYSTEM INFO LOG:${NC} $1"
}

function warning_log() {
    echo -e "${YELLOW}SYSTEM WARNING LOG:${NC} $1"
}

function display_stats(){
	{
		TEGRADATA=$(tegrastats | head -n 1)
		echo -e "${TEAL}$(date +%H:%M:%S) GPU LOAD:${NC}\n$(echo "$TEGRADATA" | grep -oP 'GR3D_FREQ \K[0-9]+')%" # GPU Load
		echo -e "${TEAL}$(date +%H:%M:%S) CPU LOAD:${NC}\n$(echo "$TEGRADATA" | grep -oP 'CPU \[[^\]]*\]')" # CPU LOAD
		echo -e "${TEAL}$(date +%H:%M:%S) CPU TEMP:${NC}\n$(echo "$TEGRADATA" | grep -oP 'cpu@\K[0-9]+.[0-9]+C')" # CPU Temperature
		echo -e "${TEAL}$(date +%H:%M:%S) RAM USAGE:${NC}\n$(echo "$TEGRADATA" | grep -oP 'RAM [0-9]+/[0-9]+MB')" # RAM Usage
	} &
	# Wait for all background processes to complete
	wait
}

if ! command -v tegrastats &> /dev/null; then
    warning_log "Is your system a Jetson device?"
	exit 0
fi

# =================================		MAIN	 ========================================
INTERVAL=$1
if [[ INTERVAL == "" ]]; then
    warning_log "Interval not provided, skipping..."
    exit 0
fi

if [[ $1 == "--once" ]]; then
    info_log "Running system log monitoring once"
    display_stats #>> logs/$LOG_FILE 
    exit 0
fi

info_log "Starting system log monitoring with interval: $INTERVAL seconds"
while (true); do
    display_stats 
    sleep $INTERVAL
done

