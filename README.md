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
### Windows
It is reccomended to download the prebuild binary.
#### Source
Make sure you have git and vlang.
```bash
git clone https://github.com/Frothy7650/ghpkg_win.git .ghpkg
cd ghpkg
./install.bat
```
