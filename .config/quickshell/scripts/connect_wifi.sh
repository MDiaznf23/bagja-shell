#!/bin/bash
SSID="$1"
PASSWORD="$2"

if [ -z "$SSID" ]; then
    echo "ERROR_NO_SSID"
    exit 1
fi

# SKENARIO 1: User menginput password (Jaringan baru / Update password salah)
if [ -n "$PASSWORD" ]; then
    # Hapus profil lama jika ada, agar tidak bentrok dengan password baru
    nmcli connection delete "$SSID" &>/dev/null
    sleep 0.5
    ERROR_MSG=$(nmcli device wifi connect "$SSID" password "$PASSWORD" 2>&1)
else
# SKENARIO 2: Tanpa password (Jaringan Open ATAU Jaringan Secured yang sudah tersimpan)
    # Perintah ini sangat pintar: 
    # - Kalau Open, langsung connect. 
    # - Kalau Secured & sudah tersimpan, otomatis pakai password dari sistem.
    ERROR_MSG=$(nmcli device wifi connect "$SSID" 2>&1)
fi

EXIT_CODE=$?

# Pengecekan apakah sukses terhubung
if [ $EXIT_CODE -eq 0 ] || echo "$ERROR_MSG" | grep -qi "enqueued\|successfully"; then
    echo "SUCCESS"
    exit 0
else
    # Jika gagal, cek apakah karena masalah otentikasi/password
    if echo "$ERROR_MSG" | grep -qi "secret\|password\|auth\|802-1x\|psk\|key"; then
        
        # Jaga-jaga: Kalau gagal konek ke jaringan yang tersimpan karena passwordnya sudah berubah di router,
        # kita hapus profilnya di sistem supaya tidak "nyangkut" dan user bisa input password baru.
        if [ -z "$PASSWORD" ]; then
            nmcli connection delete "$SSID" &>/dev/null
        fi
        
        echo "AUTH_FAILED"
    else
        echo "CONNECT_FAILED"
    fi
    exit 1
fi
