#!/bin/bash
WEATHER_SCRIPT="$HOME/.config/quickshell/scripts/weather.sh"
FORECAST_SCRIPT="$HOME/.config/quickshell/scripts/weather_wrapper_forecast.sh"
CACHE_DIR="$HOME/.cache/quickshell-weather"
CACHE_ICON="$CACHE_DIR/icon"
CACHE_DESC="$CACHE_DIR/desc"
CACHE_TEMP="$CACHE_DIR/temp"
CACHE_CITY="$CACHE_DIR/city"
CACHE_COLOR="$CACHE_DIR/color"
mkdir -p "$CACHE_DIR"

_get_city() {
    grep "^CITY_NAME=" "$WEATHER_SCRIPT" | cut -d"'" -f2
}

_get_lat() {
    grep "^LATITUDE=" "$WEATHER_SCRIPT" | cut -d'"' -f2 | cut -c1-5
}

_get_lon() {
    grep "^LONGITUDE=" "$WEATHER_SCRIPT" | cut -d'"' -f2 | cut -c1-5
}

_get_color() {
    local DESC="$1"
    case "$DESC" in
        *[Cc]lear*|*[Ss]unny*)                echo "#f59e0b" ;;
        *[Cc]loud*)                            echo "#5a4fba" ;;
        *[Rr]ain*|*[Dd]rizzle*|*[Ss]hower*)   echo "#3b82f6" ;;
        *[Tt]hunder*|*[Ss]torm*)               echo "#8b5cf6" ;;
        *[Ss]now*)                             echo "#60a5fa" ;;
        *[Ff]og*|*[Mm]ist*|*[Hh]aze*)         echo "#6b7280" ;;
        *)                                     echo "#9ca3af" ;;
    esac
}

_get_temp() {
    # Ambil dari forecast cache day0 max (konsisten dengan weather_wrapper_forecast.sh day0 max)
    FORECAST_CACHE="$HOME/.cache/quickshell-weather-forecast/forecast_data"

    if [ -f "$FORECAST_CACHE" ]; then
        DATA=$(grep "FORECAST_DAY_0" "$FORECAST_CACHE" | cut -d'|' -f5)
        if [ -n "$DATA" ]; then
            echo "$DATA" | tee "$CACHE_TEMP"
            return
        fi
    fi

    # fallback: panggil forecast script langsung
    DATA=$("$FORECAST_SCRIPT" day0 max 2>/dev/null)
    if [ -n "$DATA" ]; then
        echo "$DATA" | tee "$CACHE_TEMP"
    elif [ -f "$CACHE_TEMP" ]; then
        cat "$CACHE_TEMP"
    else
        echo "N/A"
    fi
}

case "$1" in
    temp)
        _get_temp
        ;;

    icon)
        FULL_OUTPUT=$($WEATHER_SCRIPT current 2>/dev/null)
        CLEAN_OUTPUT=$(echo "$FULL_OUTPUT" | sed 's/%{[^}]*}//g')
        ICON=$(echo "$CLEAN_OUTPUT" | awk '{print $1}' | xargs)
        if [ -n "$ICON" ]; then
            echo "$ICON" | tee "$CACHE_ICON"
        elif [ -f "$CACHE_ICON" ]; then
            cat "$CACHE_ICON"
        else
            echo "󰖐"
        fi
        ;;

    desc)
        FULL_OUTPUT=$($WEATHER_SCRIPT current 2>/dev/null)
        DESC=$(echo "$FULL_OUTPUT" | sed 's/%{[^}]*}//g' | sed 's/[|].*//g' | awk '{$1=""; print $0}' | sed 's/[0-9]*°[CF]//g' | xargs)
        if [ -n "$DESC" ]; then
            echo "$DESC" | tee "$CACHE_DESC"
        elif [ -f "$CACHE_DESC" ]; then
            cat "$CACHE_DESC"
        else
            echo "No Connection"
        fi
        ;;

    full)
        $WEATHER_SCRIPT current 2>/dev/null | sed 's/%{[^}]*}//g'
        ;;

    city)
        CITY=$(_get_city)
        if [ -n "$CITY" ]; then
            echo "$CITY" | tee "$CACHE_CITY"
        elif [ -f "$CACHE_CITY" ]; then
            cat "$CACHE_CITY"
        else
            echo "Unknown"
        fi
        ;;

    color)
        if [ -f "$CACHE_DESC" ]; then
            DESC=$(cat "$CACHE_DESC")
        else
            DESC=$($0 desc)
        fi
        _get_color "$DESC" | tee "$CACHE_COLOR"
        ;;

    latitude|lat)
        _get_lat || echo "Unknown"
        ;;

    longitude|lon|long)
        _get_lon || echo "Unknown"
        ;;

    json)
        OUTPUT=$($WEATHER_SCRIPT json 2>/dev/null)
        CITY=$(_get_city)
        [ -z "$CITY" ] && CITY=$([ -f "$CACHE_CITY" ] && cat "$CACHE_CITY" || echo "Unknown")
        TEMP=$(_get_temp)
        LAT=$(_get_lat); [ -z "$LAT" ] && LAT="Unknown"
        LON=$(_get_lon); [ -z "$LON" ] && LON="Unknown"

        if [ -z "$OUTPUT" ] || [ "$OUTPUT" = "null" ]; then
            if [ -f "$CACHE_ICON" ] && [ -f "$CACHE_DESC" ]; then
                ICON=$(cat "$CACHE_ICON")
                DESC=$(cat "$CACHE_DESC")
                COLOR=$(_get_color "$DESC")
                echo "{\"icon\":\"$ICON\",\"color\":\"$COLOR\",\"text\":\"$DESC\",\"city\":\"$CITY\",\"temp\":\"$TEMP\",\"lat\":\"$LAT\",\"lon\":\"$LON\"}"
            else
                echo "{\"icon\":\"󰖐\",\"color\":\"#ff0000\",\"text\":\"Offline\",\"city\":\"$CITY\",\"temp\":\"N/A\",\"lat\":\"$LAT\",\"lon\":\"$LON\"}"
            fi
        else
            echo "$OUTPUT" | jq -c \
                --arg city "$CITY" \
                --arg temp "$TEMP" \
                --arg lat "$LAT" \
                --arg lon "$LON" \
                '. + {city: $city, temp: $temp, lat: $lat, lon: $lon}'
        fi
        ;;

    *)
        FULL_OUTPUT=$($WEATHER_SCRIPT current 2>/dev/null)
        echo "$FULL_OUTPUT" | sed 's/%{[^}]*}//g' | grep -oP '\d+°[CF]' | head -1 || echo "N/A"
        ;;
esac
