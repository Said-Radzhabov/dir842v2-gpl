#!/bin/bash

TOP_DIR=$(realpath "$(dirname "$(realpath $0)")/../")
PROFILES="$1"

cd "$TOP_DIR"
export PATH="$TOP_DIR/output/host/usr/bin:$TOP_DIR/output/host/usr/sbin:$PATH"

if [ -z "$PROFILES" ]; then
	PROFILES=$(scripts/selector BR2_HAVE_DOT_CONFIG=y) # all profiles
fi

LAST_PROFILE=$(cat .last_profile 2> /dev/null)

cleaning() {
	printf "\n===================================\n"

	rm -rf output/build/buildroot-config

	if [ -n "$LAST_PROFILE" ]; then
		echo "$LAST_PROFILE" > .last_profile
	else
		rm .last_profile 2> /dev/null
		LAST_PROFILE='not set'
	fi
	printf "%bYour current PROFILE is %s%b\n" "$BLUE" "$LAST_PROFILE" "$NC"
	exit 0
}

trap cleaning SIGINT

title() {
	(tput setaf 2
	tput rev
	echo -n "$@"
	tput sgr0
	echo) >&2
}

die() {
	echo "$@" >&2
	exit 1
}

mkdir -p output/dm_fastbuild/

for profile in $PROFILES; do
	title "Building $profile..."
	mkdir -p "output/dm_fastbuild/$profile"
	rm -rf output/build/buildroot-config

	make PROFILE=$profile prepare ||
		die "Cannot prepare $profile"

	make datamodel-clean

	DM_FASTBUILD=y DM_ENDIAN=little make datamodel ||
		die "Datamodel failed to build for $profile"

	dm_convert -r output/build/datamodel-*/buildroot-build/full_dm.bin "output/dm_fastbuild/$profile/reversed_dm.json" ||
		die "Cannot convert full_dm.bin back to JSON"

	rm -f "output/dm_fastbuild/$profile/full_dm.bin"
	cp -r output/build/datamodel-*/buildroot-build/* "output/dm_fastbuild/$profile"
done

cleaning
