/bin/awk

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