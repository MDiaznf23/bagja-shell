#!/bin/bash
WEATHER_SCRIPT="$HOME/.config/quickshell/scripts/weather.sh"
CACHE_DIR="$HOME/.cache/quickshell-weather"
CACHE_ICON="$CACHE_DIR/icon"
CACHE_DESC="$CACHE_DIR/desc"
CACHE_TEMP="$CACHE_DIR/temp"
mkdir -p "$CACHE_DIR"
case "$1" in
    temp)
        FULL_OUTPUT=$($WEATHER_SCRIPT current 2>/dev/null)
        TEMP=$(echo "$FULL_OUTPUT" | sed 's/%{[^}]*}//g' | grep -oP '\d+°[CF]' | head -1)
        
        if [ -n "$TEMP" ]; then
            echo "$TEMP" | tee "$CACHE_TEMP"
        elif [ -f "$CACHE_TEMP" ]; then
            cat "$CACHE_TEMP"
        else
            echo "N/A"
        fi
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
            echo "󰖐"  # Icon offline/loading
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
        grep "^CITY_NAME=" "$WEATHER_SCRIPT" | cut -d"'" -f2 || echo "Unknown"
        ;;
    
    latitude|lat)
        grep "^LATITUDE=" "$WEATHER_SCRIPT" | cut -d'"' -f2 | cut -c1-5 || echo "Unknown"
        ;;
    
    longitude|lon|long)
        grep "^LONGITUDE=" "$WEATHER_SCRIPT" | cut -d'"' -f2 | cut -c1-5 || echo "Unknown"
        ;;
    
    json)
        OUTPUT=$($WEATHER_SCRIPT json 2>/dev/null)
        
        # if fail, use cache
        if [ -z "$OUTPUT" ] || [ "$OUTPUT" = "null" ]; then
            # make from cache
            if [ -f "$CACHE_ICON" ] && [ -f "$CACHE_DESC" ]; then
                ICON=$(cat "$CACHE_ICON")
                DESC=$(cat "$CACHE_DESC")
                case "$DESC" in
                    *[Cc]lear*|*[Ss]unny*)
                        COLOR="#f59e0b"
                        ;;
                    *[Cc]loud*)
                        COLOR="#5a4fba"
                        ;;
                    *[Rr]ain*|*[Dd]rizzle*|*[Ss]hower*)
                        COLOR="#3b82f6"
                        ;;
                    *[Tt]hunder*|*[Ss]torm*)
                        COLOR="#8b5cf6"
                        ;;
                    *[Ss]now*)
                        COLOR="#60a5fa"
                        ;;
                    *[Ff]og*|*[Mm]ist*|*[Hh]aze*)
                        COLOR="#6b7280"
                        ;;
                    *)
                        COLOR="#9ca3af"
                        ;;
                esac
                echo "{\"icon\": \"$ICON\", \"color\": \"$COLOR\", \"text\": \"$DESC\"}"
            else
                # Default 
                echo "{\"icon\": \"󰖐\", \"color\": \"#ff0000\", \"text\": \"Offline\"}"
            fi
        else
            echo "$OUTPUT"
        fi
        ;;
    
    *)
        FULL_OUTPUT=$($WEATHER_SCRIPT current 2>/dev/null)
        echo "$FULL_OUTPUT" | sed 's/%{[^}]*}//g' | grep -oP '\d+°[CF]' | head -1 || echo "N/A"
        ;;
esac
