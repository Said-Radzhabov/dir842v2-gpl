#!/bin/sh

message() {
	tput smso 2>/dev/null || true
	echo ">>>   $*"
	tput rmso 2>/dev/null || true
}

fw_file="$1"
flash_fw_size="$2"
flash_fw_offset="$3"

flash_fw_offset=$(printf "%d\n" "$flash_fw_offset")
current_fw_size=$(stat -L -c %s "$fw_file"); \
flash_fw_diff=$(echo "($flash_fw_offset + $current_fw_size) - $flash_fw_size" | bc)

if [ "$flash_fw_diff" -gt "0" ]; then
	flash_fw_diff_fmt=$(numfmt --to=iec "$flash_fw_diff" || echo "")
	message "Firmware size is too large: ${flash_fw_diff} bytes ($flash_fw_diff_fmt)"
	exit 1
else
	flash_fw_diff=$(echo "$flash_fw_diff * -1" | bc)
	flash_fw_diff_fmt=$(numfmt --to=iec "$flash_fw_diff" || echo "")
	message "Firmware size is correct. Reserve: ${flash_fw_diff} bytes ($flash_fw_diff_fmt)"
fi
