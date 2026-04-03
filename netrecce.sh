#!/bin/bash

ip_regex="^([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])$"
# probably a better way to write this

awk_parse='
NR==1 { next }
{
    hop = ""
    probe = 0
    i = 1
    while (i <= NF) {
        # Hop number
        if ($i ~ /^[0-9]+$/ && hop == "") {
            hop = $i
            current_hop = hop
            probe = 0
            i++
            continue
        }
        # If no hop number found, its a continuation concept but on same line
        if (hop == "" && current_hop != "") {
            hop = current_hop
        }
        # Timeout star
        if ($i == "*") {
            probe++
            suffix = (probe == 1) ? "" : (probe == 2) ? "b" : "c"
            print hop suffix "|*|*|*"
            i++
            continue
        }
        # Hostname or IP followed by (IP) and latency
        if ($(i+1) ~ /^\(/) {
            probe++
            suffix = (probe == 1) ? "" : (probe == 2) ? "b" : "c"
            name = $i
            ip = $(i+1)
            gsub(/[()]/, "", ip)
            i += 2
            # Collect latency
            lat = "*"
            if ($i ~ /^[0-9]/) {
                lat = $i
                i += 2  # skip number and "ms"
            }
            if (name == ip) {
                print hop suffix "|" ip "|" lat
            } else {
                print hop suffix "|" name "|" ip "|" lat
            }
            continue
        }
        i++
    }
}
'

input () {
    #recieve user input as a IP address or hostname and store to a variable
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

ping_test () {
    #intial ping to test host is reachable
    if ping -c 1 $host > /dev/null 2>&1; then
	echo "Host reached."
        return 0
    else
	echo "Host not reachable or invalid."
	return 1
    fi
}

main () {
    while true; do
        input
        if ping_test; then
            break
        fi  
    done
    trace_parse
}

trace_parse () {
    mapfile -t hops < <(traceroute $host | awk "$awk_parse")
    for hop in "${hops[@]}"; do
        echo "$hop"
    done
}

main
