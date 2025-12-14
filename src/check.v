module ghpkg
import chalk
import json
import os

pub fn check()
{
  println("Checking binaries...")

  // Find binary location
  mut bin_location := ''
  local_appdata := os.getenv('LOCALAPPDATA')
  if local_appdata == '' {
    eprintln(chalk.red("Could not detect LOCALAPPDATA, using C:\\Temp"))
    bin_location = 'C:\\Temp\\'
  } else {
    bin_location = "${local_appdata.replace('\\', '/')}/ghpkg/bin"
    // Ensure the folder exists
    os.mkdir_all(os.dir(bin_location)) or {
      eprintln(chalk.red("Failed to create target folder: $err"))
      return
    }
  }

  // Join db_path together
  mut db_path := "${os.getenv("LOCALAPPDATA").replace('\\', '/')}/ghpkg/db.json"
  println("DB path: $db_path")

  // Parse db as db_raw
  db_raw_in := os.read_file(db_path) or {
    eprintln(chalk.red("Could not open db.json: $err"))
    return
  }

  // Parse db_raw as db_json
  mut db_json := json.decode([]Db, db_raw_in) or {
    eprintln(chalk.red("Failed to decode JSON: $err"))
    return
  }

  // Iterate over db_json and remove entries with missing binaries
  mut updated_db := []Db{}  // new list to hold entries that exist

  for pkg in db_json {
    // Determine expected binary path
    mut bin_path := os.join_path(bin_location, pkg.binary_name)

    // Check if binary exists
    if os.exists(bin_path) {
      updated_db << pkg  // keep this entry
      println(chalk.green("${pkg.name}: binary exists at $bin_path"))
    } else {
      println(chalk.yellow("${pkg.name}: binary missing at $bin_path, removing from db.json"))
    }
  }

  // Save updated list back to db.json
  db_raw_out := json.encode_pretty(updated_db)
  os.write_file(db_path, db_raw_out) or {
    eprintln(chalk.red("Failed to update db.json: $err"))
    return
  }
}
