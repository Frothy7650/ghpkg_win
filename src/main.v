module main
import ghpkg
import chalk
import os

fn main() {
  args := os.args
  if args.len < 2 {
    eprintln(chalk.red('No arguments provided'))
    return
  }

  match true {
    args[1] == "-S" && args.len > 2 {
      for pkg in args[2..] {
        ghpkg.install_package(pkg)
      }
    }
    args[1] == "-R" && args.len > 2 {
      for pkg in args[2..] {
        ghpkg.remove_package(pkg)
      }
    }
    args[1] == "-Q" && args.len > 2 {
      for name in args[2..] {
        ghpkg.search_packages(name)
      }
    }
    args[1] == "-L" { ghpkg.list_local() }
    args[1] == "-Lg" { ghpkg.list_global() }
    args[1] == "-U" { ghpkg.update() }
    args[1] == "-C" { ghpkg.check() }
    else {
      eprintln("Usage:")
      println("  -S <pkg>   install package")
      println("  -R <pkg>   remove package")
      println("  -Q <name>  search packages")
      println("  -L         list local packages")
      println("  -Lg        list global packages")
      println("  -U         update installed packages")
      println("  -C         check local database against installed binaries")
      return
    }
  }
}
