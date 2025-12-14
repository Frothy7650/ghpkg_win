module ghpkg
import net.http
import chalk
import json

pub fn list_global()
{
  println("Listing all packages...")

  // Import pkglist
  pkglist_url := "http://pkg.frothy7650.org/windows.json"
  pkglist_raw := http.get(pkglist_url) or {
    eprintln(chalk.red("Failed to fetch JSON: $err"))
    return
  }

  // Decode pkglist_raw
  pkglist_json := json.decode(Pkglist, pkglist_raw.body) or {
    eprintln(chalk.red("Failed to fetch pkglist: $err"))
    return
  }

  // List pkglist
  for project in pkglist_json.projects {
    println("${chalk.yellow(project.name)} ${project.version} - ${chalk.green(project.url)}")
  }
}
