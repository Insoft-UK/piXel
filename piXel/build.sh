# build.sh
decimal_to_base24() {
    local num=$1
    local base24_chars="0123456789CDFHJKMNRUVWXY"
    local base24=""

    # Handle the case where num is 0
    if [[ $num -eq 0 ]]; then
        echo "C"
        return
    fi

    # Convert the number to base 24
    while [[ $num -gt 0 ]]; do
        remainder=$((num % 24))
        base24="${base24_chars:remainder:1}$base24" # Prepend the corresponding character
        num=$((num / 24))
    done

    echo "$base24"
}

build_code() {
    local build_number=$1
    local major_version_number=$((build_number / 100000))
    local remainder=$((build_number - major_version_number * 100000))

    # Use the decimalToBase24 function to convert the remainder
    local base24_code
    base24_code=$(decimal_to_base24 "$remainder")

    # Concatenate major version number and base 24 code
    echo "${major_version_number}${base24_code}"
}
