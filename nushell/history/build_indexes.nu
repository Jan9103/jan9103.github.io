let dirs: list<path> = (ls './data' | where type == 'dir').name
for dir in $dirs {
  (ls $dir).name
  | each { path parse | get stem }
  | where $it != 'features'
  | to json --raw
  | save --force --raw ($dir | path join "features.json")
}
$dirs
| each { path basename }
| to json --raw
| save --force --raw './data/packages.json'
