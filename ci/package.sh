#!/usr/bin/env bash
#
# Packs the release tarball from prebuilt/coraza_waf-{x86_64,aarch64}.so and
# writes the matching rockspec next to it.
#
#   ci/package.sh 0.1.0
#
set -euo pipefail

version=${1:?version}
repo=${GITHUB_REPOSITORY:-api7/lua-resty-coraza-waf}
name=lua-resty-coraza-waf-${version}

for arch in x86_64 aarch64; do
    test -f "prebuilt/coraza_waf-${arch}.so" || { echo "missing $arch library" >&2; exit 1; }
done

rm -rf "dist/$name"
mkdir -p "dist/$name"
cp -r Makefile LICENSE README.md lib prebuilt "dist/$name/"
tar -C dist -czf "dist/$name.tar.gz" "$name"
rm -rf "dist/$name"

md5=$(md5sum "dist/$name.tar.gz" | cut -d' ' -f1)
sed -e "s/@VERSION@/${version}/g" -e "s#@REPO@#${repo}#g" -e "s/@MD5@/${md5}/" \
    rockspec/lua-resty-coraza-waf.rockspec.in > "dist/lua-resty-coraza-waf-${version}-1.rockspec"
ls -la dist
