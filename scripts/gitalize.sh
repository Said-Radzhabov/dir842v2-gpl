#!/bin/bash

SDK_DIR="$PWD"

PKG_NAME="$1"

if [ -z "$PKG_NAME" ]; then
	echo "Package name is not specified, abort" >&2
	exit 1
fi

PKG_VERSION=$(make $PKG_NAME-show-version)

if [ -z "$PKG_VERSION" ]; then
	echo "Unknown version of package $PKG_NAME" >&2
	exit 1
fi

REPO_DIR="$SDK_DIR/output/build/$PKG_NAME-$PKG_VERSION"
if [ -n "$REPO_DIR" ] && [ -d "$REPO_DIR" ]; then
	echo "$REPO_DIR already exists, abort" >&2
	exit 1
fi

make "$PKG_NAME"-extract
if [ -z "$REPO_DIR" ] || ! cd "$REPO_DIR"; then
	echo "cannot cd to $REPO_DIR, abort" >&2
	exit 1
fi

git init
echo -e "[alias]\\n\\tpatch = \"!sh $SDK_DIR/scripts/patch.sh\"" >> .git/config
git add .
git commit -m "initial commit"

PATCHES_DIR="$SDK_DIR/package/$PKG_NAME/$PKG_VERSION"

if [ ! -d "$PATCHES_DIR" ]; then
	PATCHES_DIR="$SDK_DIR/package/$PKG_NAME"
fi

shopt -s nullglob
for PATCH in "$PATCHES_DIR/"*.patch; do
	if ! git am -3k "$PATCH" && ! test -d ".git/rebase-apply"; then
		patch -Np1 -i $PATCH || exit 1
		git add . && git commit -m "[PATCH] $PATCH"
	fi
done

touch .stamp_patched
