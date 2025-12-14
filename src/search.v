module ghpkg
import net.http
import chalk
import json

pub fn search_packages(pkg_name_imut string)
{
  println("Searching packages...")

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

  // Search through the pkglist_json
  results := pkglist_json.projects.filter(it.name.contains(pkg_name_imut))

  if results.len == 0 {
    println(chalk.yellow("No packages found matching '${pkg_name_imut}'"))
  }

  // Print it 
  for pkg in results {
    println("${chalk.yellow(pkg.name)} ${pkg.version} - ${chalk.green(pkg.url)}")
  }
}
