def main [] {
  # TODO: generate pages
  update_index
}

def update_index [] {
  glob 'data/*.json'
  | each { path relative-to $env.PWD }
  | where ('page' in $it)
  | to json --raw
  | save --raw --force 'data/index.json'
}
