# GHPKG

**In-development package manager using GitHub repositories to clone and build.**

---

## Features / Commands

| Flag | Description                  | Added |
|------|------------------------------|-------|
| `-S <package>` | Sync / install a package    | Yes   |
| `-R <package>` | Remove a package           | Yes   |
| `-Q <name>`   | Search packages            | Yes   |
| `-L`          | List locally installed packages | Yes   |
| `-Lg`         | List globally available packages | Yes   |
| `-U`          | Update an installed package | Yes    |
| `-C`          | Verify package existence | Yes   |

---

## Installation
### Linux
If you are on Arch linux, or an Arch based distro, ghpkg is on the AUR.
Make sure you have git and vlang.
```bash
git clone https://github.com/Frothy7650/ghpkg.git .ghpkg
cd .ghpkg
./install.sh
```
### Windows
Make sure you have git and vlang.
```bash
git clone https://github.com/Frothy7650/ghpkg.git .ghpkg
cd ghpkg
./install.bat
```

## Supported operating systems
| OS | Supported |
|----|-----------|
| Windows | yes |
| Arch linux | yes |
| MacOS | no |
| Debian | yes |
