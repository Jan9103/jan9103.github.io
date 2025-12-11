def main [repo_base_path: path, database_file: path] {
  let repo_base_path = ($repo_base_path | path expand)
  ^fd -e json . $repo_base_path
  | lines
  | par-each {|package_path|
    let package = (open $package_path)
    let result = {
      "name": $package._.name
      "repo": $package._.source_uri
      "names": {"numng": $package._.name}
      "format": $package._.package_format?
      "tags": ([
        (if "shell_config" in $package._ { "config" })
        (if $package._.name =~ "nu_plugin_[^/]+$" { "plugin" })
        (if "nu_plugins" in $package._ { "plugin" })
        (if "nu_libs" in $package._ { "lib" })
        (if "bin" in $package._ { "bin" })
        (if $package._.package_format? == "packer.nu" { "shell" })
      ] | append ($package._.":tags"? | default []) | uniq | where $it != null)
      "exported_libs": ($package._.nu_libs? | default {} | columns)
    }
    let result = (if ":nupm_name" in $package._ { $result | insert names.nupm $package._.":nupm_name" } else { $result })
    let result = (if ":description" in $package._ { $result | insert description $package._.":description" } else { $result })
    let result = (if ":status" in $package._ { $result | insert status $package._.":status" } else { $result })
    let result = (if ":license" in $package._ { $result | insert license $package._.":license" } else { $result })
    $result
  }
  | to json --raw  # direct conversion to compress it
  | save --force --raw $database_file
}
