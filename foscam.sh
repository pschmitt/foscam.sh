#!/usr/bin/env bash
# Documentation:
# http://www.ipcamcontrol.net/files/Foscam%20IPCamera%20CGI%20User%20Guide-V1.0.4.pdf

foscam_cmd() {
    cd $(readlink -f $(dirname "$0"))
    . foscam.conf
    curl -kLS "${foscam}:${port}/cgi-bin/CGIProxy.fcgi?cmd=${1}&usr=${username}&pwd=${password}"
}

reboot() {
    foscam_cmd "rebootSystem"
}

state() {
    local action
    case "$1" in
        get|*)
            action=getDevState
            ;;
    esac
    foscam_cmd "$action"
}

name() {
    local action
    case "$1" in
        set)
            if [[ "$#" -lt 2 ]]
            then
                echo "Usage: $0 name set NAME"
                exit 2
            fi
            action="setDevName&devName=${2}"
            ;;
        get|*)
            action=getDevName
            ;;
    esac
    foscam_cmd "$action"
}

info() {
    foscam_cmd "getDevInfo"
}

ir() {
    local action
    case "$1" in
        on)
            action=openInfraLed
            ;;
        off)
            action=closeInfraLed
            ;;
        set)
            action="setInfraLedConfig&mode=${2}"
            ;;
        get|*)
            action=getInfraLedConfig
            ;;
    esac
    foscam_cmd "$action"
}

snap() {
    local pic="/tmp/$(date '+%Y%m%d_%H%M%S.jpg')"
    foscam_cmd snapPicture2 > "$pic"
    echo "Saved picture at $pic"
}

ip() {
    local action
    case "$1" in
        get|*)
            action=getIPInfo
            ;;
    esac
    foscam_cmd "$action"
}

wifi() {
    local action
    case "$1" in
        refresh)
            action=refreshWifiList
            ;;
        list)
            action=getWifiList
            ;;
        get|*)
            action=getWifiConfig
            ;;
    esac
    foscam_cmd "$action"
}

port() {
    local action
    case "$1" in
        set)
            if [[ "$#" -lt 4 ]]
            then
                echo "Usage: $0 port set WEB_PORT MEDIA_PORT HTTPS_PORT" >&2
                exit 3
            fi
            action="setPortInfo&webPort=${2}&mediaPort=${3}&httpsPort=${4}"
            ;;
        get|*)
            action=getWifiConfig
            ;;
    esac
    foscam_cmd "$action"
}

upnp() {
    local action
    case "$1" in
        set)
            if [[ "$#" -lt 3 ]]
            then
                echo "Usage: $0 upnp set UPNP" >&2
                exit 3
            fi
            action="setUPnPConfig&isEnable=${2}"
            ;;
        get|*)
            action=getUPnPConfig
            ;;
    esac
    foscam_cmd "$action"
}

ddns() {
    local action
    case "$1" in
        set)
            action=TODO
            ;;
        get|*)
            action=getDDNSConfig
            ;;
    esac
    foscam_cmd "$action"
}

ftp() {
    local action
    case "$1" in
        test)
            action=testFtpServer
            ;;
        set)
            action=TODO
            ;;
        get|*)
            action=getFtpConfig
            ;;
    esac
    foscam_cmd "$action"
}

smtp() {
    local action
    case "$1" in
        test)
            action=smtpTest
            ;;
        set)
            action=TODO
            ;;
        get|*)
            action=getSMTPConfig
            ;;
    esac
    foscam_cmd "$action"
}

systemtime() {
    local action
    case "$1" in
        set)
            action=TODO
            ;;
        get|*)
            action=getSystemTime
            ;;
    esac
    foscam_cmd "$action"
}

factory_reset() {
    foscam_cmd "restoreToFactorySetting"
}

firmware_upgrade() {
    foscam_cmd "FwUpgrade"
}

config() {
    local action
    case "$1" in
        export)
            action=exportConfig
            ;;
        import)
            action=importConfig
            ;;
    esac
    foscam_cmd "$action"
}

log() {
    # if [[ "$#" -lt 3 ]]
    # then
    #     echo "Usage : $0 log OFFSET COUNT"
    # fi
    foscam_cmd "getLog&offset=${2}&count=${3}"
}

funcs=$(typeset -F | sed -n 's/declare -f \(.*\)/\1/p')

if grep "^${1}\$" <<< "$funcs" > /dev/null
then
    $@
else
    echo "Invalid function" >&2
    echo "Available functions:" >&2
    echo "$funcs" >&2
    exit 2
fi
