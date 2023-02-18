#
# libcontacts.sh
#
# This file includes the generating and parsing of BMMM message packages.
#


function bmmm_gen() {
    from_name="$1"
    from_kpid="$2"
    to_name="$3"
    to_kpid="$4"
    rawmsgfile="$5"
    part1="p: bmmm-1.0
app: cismail-format-v1
time: $(date +%s)
from: $from_name
to: $to_name
from_key: $from_kpid
to_key: $to_kpid
markup: plain
garbage_bytes: "
    part3="----------
$(cat "$rawmsgfile")"

current_length="$(wc --bytes <<< "$part1$part3")"
pad_unit_size=256
[[ current_length -ge 4096 ]] && pad_unit_size=1024
need_bytes="$((pad_unit_size-current_length%pad_unit_size-1))"
part2="$(dd if=/dev/urandom of=/dev/stdout bs="$pad_unit_size" count=1 2>/dev/null | base64 -w0 | cut -c1-"$need_bytes")"
echo "$part1$part2"
echo "$part3"
}


function bmmm_get_header() {
    prop="$1"
    file="$2"
    grep "$prop: " "$file" | head -n1 | cut -d: -f2- | cut -c2-
}
