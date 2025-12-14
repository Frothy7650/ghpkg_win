module ghpkg

pub struct Project {
  name      string
  version   string
  url      string
}

pub struct Pkglist {
  projects []Project
}

pub struct Ghpkg {
  name          string
  version       string
  description   string
  clone_command string
  clone_url     string
  build         string
  binary_name   string
  binary_dir    string
  dependencies  []string
  os            []string
}

pub struct Db {
mut:
  name        string
  binary_name string
  binary_dir  string
  version     string
  description string
}
