#!/usr/bin/env python3
"""weather.py — satu request Open-Meteo, satu baris JSON ke stdout.
Pengganti weather.sh + weather-wrapper.sh + weather_wrapper_forecast.sh."""
import json
import urllib.request
from datetime import datetime

CITY = "Purwakarta"
LAT, LON = -6.5569, 107.4431
DAYS = 5

URL = (
    "https://api.open-meteo.com/v1/forecast"
    f"?latitude={LAT}&longitude={LON}&timezone=auto&forecast_days={DAYS}"
    "&temperature_unit=celsius&wind_speed_unit=kn"
    "&current=weather_code,is_day"
    "&daily=weather_code,temperature_2m_max,temperature_2m_min,"
    "precipitation_sum,wind_speed_10m_max"
)

DESC = {
    0: "Clear", 1: "Mainly Clear", 2: "Partly Cloudy", 3: "Overcast",
    45: "Foggy", 48: "Foggy",
    51: "Light Drizzle", 53: "Moderate Drizzle", 55: "Dense Drizzle",
    56: "Freezing Drizzle", 57: "Freezing Drizzle",
    61: "Slight Rain", 63: "Moderate Rain", 65: "Heavy Rain",
    66: "Freezing Rain", 67: "Freezing Rain",
    71: "Slight Snow", 73: "Moderate Snow", 75: "Heavy Snow", 77: "Snow Grains",
    80: "Slight Showers", 81: "Moderate Showers", 82: "Violent Showers",
    85: "Slight Snow Showers", 86: "Heavy Snow Showers",
    95: "Thunderstorm", 96: "Thunderstorm Light Hail", 99: "Thunderstorm Heavy Hail",
}


def main():
    try:
        with urllib.request.urlopen(URL, timeout=10) as r:
            d = json.load(r)
        cur, daily = d["current"], d["daily"]

        forecast = [
            {
                "day": datetime.strptime(daily["time"][i], "%Y-%m-%d").strftime("%a"),
                "code": daily["weather_code"][i],
                "desc": DESC.get(daily["weather_code"][i], "Unknown"),
                "max": f"{round(daily['temperature_2m_max'][i])}°C",
                "min": f"{round(daily['temperature_2m_min'][i])}°C",
                "rain": f"{daily['precipitation_sum'][i]}mm",
                "wind": str(round(daily["wind_speed_10m_max"][i])),
            }
            for i in range(len(daily["time"]))
        ]

        print(json.dumps({
            "code": cur["weather_code"],
            "is_day": bool(cur["is_day"]),
            "text": DESC.get(cur["weather_code"], "Unknown"),
            "temp": forecast[0]["max"],  # sama seperti sebelumnya: max hari ini
            "city": CITY,
            "lat": str(LAT)[:5],
            "lon": str(LON)[:5],
            "forecast": forecast,
        }, ensure_ascii=False))
    except Exception:
        print(json.dumps({"error": True}))


if __name__ == "__main__":
    main()
