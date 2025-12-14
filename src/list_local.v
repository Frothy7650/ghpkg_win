module ghpkg
import chalk
import json
import os

pub fn list_local()
{
  println("Listing all packages...")

  // Join db_path together
  mut db_path := "${os.getenv("LOCALAPPDATA").replace('\\', '/')}/ghpkg/db.json"
  println("DB path: $db_path")

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

  // List db_json
  for entry in db_json {
    println("${chalk.yellow(entry.name)} ${entry.version} - ${chalk.green(entry.description)}")
  }
}
