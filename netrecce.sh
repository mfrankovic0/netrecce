#!/bin/bash

ip_regex="^([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])[.]\
([0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])$"
# probably a better way to write this

    
  
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

trace_parse () {
    mapfile -t hops < <(traceroute $host | awk -f $awk_parse.awk)
    for hop in "${hops[@]}"; do
        echo "$hop"
    done
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

main
