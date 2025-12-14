module ghpkg
import net.http
import chalk
import json
import os

pub fn update()
{
  // Import pkglist
  pkglist_url := "http://pkg.frothy7650.org/pkglist.json"
  pkglist_raw := http.get(pkglist_url) or {
    eprintln(chalk.red("Failed to fetch pkglist: $err"))
    return
  }

  // Parse pkglist_raw as pkglist_json
  pkglist_json := json.decode(Pkglist, pkglist_raw.body) or {
    eprintln(chalk.red("Failed to decode pkglist: $err"))
    return
  }

  // Join db_path together
  mut db_path := ''
  db_path = "${os.getenv("LOCALAPPDATA").replace('\\', '/')}/ghpkg/db.json"

  // Parse db as db_raw
  db_raw := os.read_file(db_path) or {
    eprintln(chalk.red("Could not open db.json: $err"))
    return
  }

  // Decode db_raw as db_json
  db_json := json.decode([]Db, db_raw) or {
    eprintln(chalk.red("Failed to decode JSON: $err"))
    return
  }

  for installed_pkg in db_json {
    for online_pkg in pkglist_json.projects {
      if installed_pkg.name == online_pkg.name {
        if installed_pkg.version != online_pkg.version {
          println(chalk.green('${installed_pkg.name} has an update: ${installed_pkg.version} -> ${online_pkg.version}'))
          install_package(installed_pkg.name)
        } else {
          println("${installed_pkg.name} is up to date: ${installed_pkg.version}")
        }
      }
    }
  }
}
