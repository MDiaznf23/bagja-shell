#!/bin/bash
# Wrapper script output JSON friendly
WEATHER_SCRIPT="$HOME/.config/quickshell/scripts/weather.sh"

# Cache file 
CACHE_DIR="$HOME/.cache/quickshell-weather-forecast"
mkdir -p "$CACHE_DIR"

# get forecast
get_forecast_data() {
    CACHE_FILE="$CACHE_DIR/forecast_data"
    CACHE_DATE="$CACHE_DIR/last_update"
    TODAY=$(date +%Y-%m-%d)
    
    # Chech cache
    if [ -f "$CACHE_DATE" ] && [ -f "$CACHE_FILE" ]; then
        CACHED_DATE=$(cat "$CACHE_DATE")
        if [ "$CACHED_DATE" = "$TODAY" ]; then
            cat "$CACHE_FILE"
            return
        fi
    fi
    
    # Take new data
    DATA=$($WEATHER_SCRIPT forecast 2>/dev/null)
    if [ -n "$DATA" ]; then
        echo "$DATA" | tee "$CACHE_FILE"
        echo "$TODAY" > "$CACHE_DATE"
    elif [ -f "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    fi
}

case "$1" in
    day0|day1|day2|day3|day4)
        DAY_NUM="${1#day}"
        
        case "$2" in
            icon)
                CACHE_FILE="$CACHE_DIR/${1}_icon"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f3)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "󰖐"
                fi
                ;;
            desc)
                CACHE_FILE="$CACHE_DIR/${1}_desc"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f4)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "N/A"
                fi
                ;;
            max|high)
                CACHE_FILE="$CACHE_DIR/${1}_max"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f5)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "N/A"
                fi
                ;;
            min|low)
                CACHE_FILE="$CACHE_DIR/${1}_min"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f6)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "N/A"
                fi
                ;;
            rain)
                CACHE_FILE="$CACHE_DIR/${1}_rain"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f7)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "0mm"
                fi
                ;;
            wind)
                CACHE_FILE="$CACHE_DIR/${1}_wind"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f8)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "0"
                fi
                ;;
            day|name)
                CACHE_FILE="$CACHE_DIR/${1}_day"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f2)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "N/A"
                fi
                ;;
            full)
                get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}"
                ;;
            *)
                # Default: return icon
                CACHE_FILE="$CACHE_DIR/${1}_icon"
                DATA=$(get_forecast_data | grep "FORECAST_DAY_${DAY_NUM}" | cut -d'|' -f3)
                if [ -n "$DATA" ]; then
                    echo "$DATA" | tee "$CACHE_FILE"
                elif [ -f "$CACHE_FILE" ]; then
                    cat "$CACHE_FILE"
                else
                    echo "󰖐"
                fi
                ;;
        esac
        ;;
    
    all)
        get_forecast_data
        ;;
    
json)
    RESULT="["
    FIRST=true
    for i in {0..4}; do
        LINE=$(get_forecast_data | grep "FORECAST_DAY_${i}")
        if [ -n "$LINE" ]; then
            DAY=$(echo "$LINE" | cut -d'|' -f2 | cut -c1-3)
            ICON=$(echo "$LINE" | cut -d'|' -f3)
            DESC=$(echo "$LINE" | cut -d'|' -f4)
            MAX=$(echo "$LINE" | cut -d'|' -f5)
            MIN=$(echo "$LINE" | cut -d'|' -f6)
            RAIN=$(echo "$LINE" | cut -d'|' -f7)
            WIND=$(echo "$LINE" | cut -d'|' -f8)

            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                RESULT+=","
            fi

            RESULT+="{\"day\":\"$DAY\",\"icon\":\"$ICON\",\"desc\":\"$DESC\",\"max\":\"$MAX\",\"min\":\"$MIN\",\"rain\":\"$RAIN\",\"wind\":\"$WIND\"}"
        fi
    done
    RESULT+="]"
    echo "$RESULT"
    ;;
    
    refresh)
        # Clear cache and refresh data
        rm -rf "$CACHE_DIR"
        mkdir -p "$CACHE_DIR"
        get_forecast_data > /dev/null
        echo "Cache refreshed"
        ;;
    
    *)
        echo "Usage: $0 {day0|day1|day2|day3|day4} {icon|desc|max|min|rain|wind|day|full}"
        echo "       $0 {all|json|refresh}"
        echo ""
        echo "Examples:"
        echo "  $0 day0 icon      # Icon today"
        echo "  $0 day1 max       # max temp tomorrow"
        echo "  $0 day2 desc      # Deskripsi cuaca lusa"
        echo "  $0 all            # all forecast data"
        echo "  $0 json           # Output JSON"
        exit 1
        ;;
esac
