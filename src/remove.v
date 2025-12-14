module ghpkg
import chalk
import json
import os

pub fn remove_package(pkg_name_imut string) {
  // Determine DB path
  mut db_path := "${os.getenv("LOCALAPPDATA").replace('\\', '/')}/ghpkg/db.json"
  println("DB path: $db_path")

  // Read db.json
  db_raw_in := os.read_file(db_path) or {
    eprintln(chalk.red("Could not open db.json: $err"))
    return
  }

  // Parse JSON
  mut db_json := json.decode([]Db, db_raw_in) or {
    eprintln(chalk.red("Failed to parse JSON: $err"))
    return
  }

  // Find the package entry
  pkg_entries := db_json.filter(it.name == pkg_name_imut)
  if pkg_entries.len == 0 {
    eprintln(chalk.red("Package '$pkg_name_imut' not found in db.json"))
    return
  }

  // Determine actual binary name
  binary_name := if pkg_entries[0].binary_name != '' { pkg_entries[0].binary_name } else { pkg_name_imut }

  // Construct binary path
  mut bin_target := ''
  local_appdata := os.getenv('LOCALAPPDATA')
  if local_appdata == '' {
    eprintln(chalk.red('Could not detect LOCALAPPDATA, using C:\\Temp'))
    bin_target = 'C:/Temp/' + binary_name
  } else {
    bin_target = "${local_appdata.replace('\\', '/')}/ghpkg/bin/${binary_name}.exe"
    os.mkdir_all(os.dir(bin_target)) or {
      eprintln(chalk.red('Failed to create target folder: $err'))
      return
    }
  }

  to_continue := os.input("Do you want to remove these packages? [Y/n] ")
  if to_continue == 'n' || to_continue == 'N' {
    eprintln(chalk.red("Stopping..."))
    return
  } else if to_continue == 'y' || to_continue == 'Y' || to_continue == '' {
    println(chalk.green("Removing..."))
  }

  // Remove the package from the DB
  db_json = db_json.filter(it.name != pkg_name_imut)
  db_raw_out := json.encode_pretty(db_json)
  os.write_file(db_path, db_raw_out) or {
    eprintln(chalk.red("Failed to save db.json: $err"))
    return
  }
  println(chalk.green("Removed entry from db.json"))

  // Remove the binary
  os.rm(bin_target) or { eprintln(chalk.red("Failed to remove binary: $err")) }
  println(chalk.green("Removed binary from ${bin_target}"))
}
