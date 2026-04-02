#!/bin/bash

ip_regex="^([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])$"

input () {
    while true; do
        read -p "Please enter an IP address or hostname: " host
            if [[ $host =~ $ip_regex ]]; then
                break
            elif [[ -n $host ]]; then
                break;
            else
                echo "Not valid IP address or hostname."
            fi
    done
    echo "Host selected: $host"
}

input
