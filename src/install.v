module ghpkg
import net.http
import chalk
import json
import os

pub fn install_package(pkg_name_imut string)
{
  // Take pkg_name_imut through function call and make it mutable
  mut pkg_name := pkg_name_imut
  println("Installing package $pkg_name")

  // Import pkglist
  pkglist_url := "http://pkg.frothy7650.org/windows.json"
  pkglist_text := http.get(pkglist_url) or {
    eprintln(chalk.red("Failed to fetch JSON: $err"))
    return
  }

  // Parse as JSON
  registry := json.decode(Pkglist, pkglist_text.body) or {
    eprintln(chalk.red('Failed to parse JSON: $err'))
    return
  }

  // Search registry for pkg_name
  mut pkg_exists := false
  mut ghpkg_url := ''
  mut pkg_version := ''
  for project in registry.projects {
    if project.name.to_lower() == pkg_name.to_lower() {
      println(chalk.green('Found package: $project.name'))
      println(chalk.green('URL: $project.url'))
      pkg_name = project.name
      ghpkg_url = project.url
      pkg_version = project.version
      pkg_exists = true
      break
    }
  }

  if !pkg_exists {
    println(chalk.red('Package "$pkg_name" not found in registry'))
    return
  }

  // Determine paths
  mut pkg_path := os.join_path(os.temp_dir(), "ghpkg")

  // Join db_path together
  mut db_path := os.join_path(os.getenv("LOCALAPPDATA").replace('\\', '/'), "ghpkg", "db.json")
  println("DB path: $db_path")

  // Clone the repo and setup clone_path
  clone_path := os.join_path(pkg_path, pkg_name)
  println(chalk.green("Cloning $ghpkg_url ..."))
  os.system('git clone $ghpkg_url "${clone_path}"2')

  // Parse ghpkg file
  mut ghpkg_file := os.read_file("${clone_path}2/ghpkg") or {
    eprintln(chalk.red('Could not read file: $err'))
    return
  }

  // Replace $temp with actual pkg_path directory
  pkg_path = pkg_path.replace('\\', '/')
  ghpkg_file = ghpkg_file.replace("\$temp", "${pkg_path}")

  // Decode ghpkg_file as ghpkg_json
  ghpkg_json := json.decode(Ghpkg, ghpkg_file) or {
    eprintln(chalk.red('Invalid JSON: $err'))
    return
  }

  // Check OS compatibility
  current_os := os.user_os()
  mut supported := false
  for pkg_os in ghpkg_json.os {
    if pkg_os == current_os {
      supported = true break
    }
  }

  if !supported {
    eprintln(chalk.red("This package does not support your OS: $current_os"))
    return
  }

  // Check dependencies
  for dep in ghpkg_json.dependencies {
    mut res := os.Result{} // Special type for a return value
    os.execute("where $dep")
    if res.exit_code != 0 {
      eprintln(chalk.red("Dependency '$dep' is missing"))
      return
    }
  }

  // Clone pkg_url
  println(chalk.green("Cloning ${ghpkg_json.clone_url}..."))
  os.system('${ghpkg_json.clone_command} ${ghpkg_json.clone_url} "${clone_path}"')

  // Build
  println(chalk.yellow("Building..."))
  os.system(ghpkg_json.build)

  // find binary PATHed location to move to
  mut binary_name := ''
  if ghpkg_json.binary_name.ends_with(".exe") {
    binary_name = "${ghpkg_json.binary_name}"
  } else {
    binary_name = "${ghpkg_json.binary_name}.exe"
  }

  mut bin_target := ''
  local_appdata := os.getenv('LOCALAPPDATA')
  if local_appdata == '' {
    eprintln(chalk.red('Could not detect LOCALAPPDATA, using C:\\Temp'))
    bin_target = 'C:/Temp/' + binary_name
  } else {
    bin_target = "${local_appdata.replace('\\', '/')}/ghpkg/bin/${binary_name}"
    // Ensure the folder exists
    os.mkdir_all(os.dir(bin_target)) or {
      eprintln(chalk.red('Failed to create target folder: $err'))
      return
    }
  }

  // Prompt user for permission to install
  to_continue := os.input("Proceed with installation? [Y/n] ")
  if to_continue == 'n' || to_continue == 'N' {
    eprintln(chalk.red("Stopping..."))
    return
  } else if to_continue == 'y' || to_continue == 'Y' || to_continue == '' {
    println(chalk.green("Installing..."))
  }

  // Move binary
  mut src := ""
  if ghpkg_json.binary_dir != "" {
    src = "${clone_path}/${ghpkg_json.binary_dir}/${ghpkg_json.binary_name}.exe"
  } else {
    src = "${clone_path}/${ghpkg_json.binary_name}.exe"
  }
  os.cp(src, bin_target) or { eprintln(chalk.red("Failed to copy binary: $err")) return }

  println(chalk.green('Package built and moved to $bin_target'))

  // Parse db.json as db_raw
  db_raw_in := os.read_file(db_path) or {
    eprintln(chalk.red("Could not find db: $err"))
    return
  }

  // Parse db.json as db_json
  mut db_json := json.decode([]Db, db_raw_in) or {
    eprintln(chalk.red("Could not decode JSON: $err"))
    return
  }

  // Check if pkg already exists
  db_json = db_json.filter(it.name != ghpkg_json.name)

  // Append name, version, and description from ghpkg to db_json
  db_json << Db{
    name: ghpkg_json.name
    binary_name: ghpkg_json.binary_name
    binary_dir: ghpkg_json.binary_dir
    version: pkg_version
    description: ghpkg_json.description
  }

  // Encode db_json as db_raw_out
  db_raw_out := json.encode_pretty(db_json)

  // Write db_raw_out to db_path
  os.write_file(db_path, db_raw_out) or {
    eprintln(chalk.red("Failed to write to DB: $err"))
    return
  }

  println(chalk.yellow("Warning: temporary directory is not automatically removed, to remove, delete ghpkg folder in %TEMP%"))
}
