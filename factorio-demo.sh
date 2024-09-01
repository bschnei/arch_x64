#!/usr/bin/env bash
set -e

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; cd -P "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo .)")" || exit; pwd)
readonly script_dir

pkgname=factorio-demo
readonly pkgname

# get latest stable release version
latest=$(curl -s https://factorio.com/api/latest-releases | jq -r '.stable.demo')
readonly latest

# get latest package version
cd "${script_dir}/repos" || exit
if [ -d "${pkgname}" ]; then
  cd "${pkgname}" || exit
  git pull --quiet
else
  git clone ssh://aur@aur.archlinux.org/${pkgname}.git
  cd "${pkgname}" || exit
fi

current=$(sed -n -e 's/^pkgver=//p' PKGBUILD)
readonly current

# quit if the two versions are the same
if [ "${latest}" = "${current}" ]; then
  echo "${pkgname} is up-to-date (${current})"
  exit 0
fi

# get the new hash from upstream
new_sha256sum=$(curl -s "https://www.factorio.com/download/sha256sums/" | sed -n -e "s/  factorio_demo_x64_${latest}.tar.xz$//p")
readonly new_sha256sum

# modify the PKGBUILD
sed -i "s|^pkgver=.*$|pkgver=${latest}|g" PKGBUILD
sed -i "s|^pkgrel=.*$|pkgrel=1|g" PKGBUILD
sed -i "s|^sha256sums=(.*$|sha256sums=('${new_sha256sum}'|g" PKGBUILD

# clean build the new package
makepkg --force --cleanbuild --syncdeps --rmdeps --noconfirm
makepkg --printsrcinfo > .SRCINFO

# version control changes
git commit --all --message="${latest}-1"
git push

# clean unversioned files
git clean -d --force

