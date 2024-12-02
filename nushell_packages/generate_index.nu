use ../nulib/nutils/html.nu

def main [] {
  let head: string = (open --raw ./head.html)
  let tail: string = (open --raw ./tail.html)
  let db: list = (open ./database.json)

  generate_file ($head | str replace '%intro%' '<h1>numng package index</h1>') ($db | where (not ("theme" in $it.tags))) $tail
  | save --raw --force ./package_index.html

  generate_file ($head | str replace '%intro%' '<h1>numng theme index</h1><style>body>.q{display:none;}</style>') ($db | where ("theme" in $it.tags)) $tail
  | save --raw --force ./themes.html
}

def generate_file [head: string, database: list, tail: string]: nothing -> string {
  [
    $head
    (
      $database
      | sort-by name
      | each {|pkg|
        # yes the id is basically unicode, but that is allowed https://html.spec.whatwg.org/multipage/dom.html#the-id-attribute
        let hn: string = $'pkg-(html escape $pkg.name | str replace --all " " "_")'
        let tags: list<string> = (
          []
          | append ($pkg.tags | each {|i| $'tag_(html escape $i)'})
          | append ($pkg.names | columns | each {|i| $'pm_(html escape $i)'})
          | append (if "status" in $pkg { [$"status_(html escape $pkg.status)"] } else { [] })
        )
        [
          $'<li class="($tags | str join " ")">'
          $'<input type="checkbox" id="($hn)" class="smt">'
          $'<label for="($hn)">(html escape $pkg.name) <span>click to toggle details</span></label>'
          (if "description" in $pkg { $'<div>(html escape $pkg.description)</div>' } else { '' })
          '<ul>'
          $'<li><a href="(html escape $pkg.repo)">repo</a></li>'
          $'<li><a href="https://github.com/Jan9103/numng_repo/blob/main/repo/(html escape $pkg.name).json">definition</a></li>'
          (if 'license' in $pkg { $'<li class="pl">(html escape $pkg.license)</li>' } else { '' })
          (if 'version' in $pkg { $'<li class="pv">(html escape $pkg.version)</li>' } else { '' })
          (if not ($pkg.format in [null, "numng"]) { $'<li class="pf">(html escape $pkg.format)</li>' } else { '' })
          (if 'status' in $pkg { $'<li class="ps">(html escape $pkg.status)</li>' } else { '' })
          '</ul>'
          '<div class="smc">'
            '<div class="si">'
              (if "nupm" in $pkg.names {$'<div class="pm_nupm"><pre class="y">(html escape $pkg.names.nupm)</pre></div>'} else {''})
              (if "numng" in $pkg.names {$'<div class="pm_numng"><pre>{<span class="y">"name"</span>: <span class="y">"(html escape $pkg.names.numng)"</span>}</pre></div>'} else {''})
            '</div>'
            (if not ($pkg.exported_libs? in [null, []]) { "<div class="sx"><ul>" + ($pkg.exported_libs | each {|i| $'<li>(html escape $i)</li>' } | str join '') + "</ul></div>" } else {''})
          '</div>'
          '</li>'
        ]
      }
      | flatten --all
    )
    $tail
  ]
  | flatten
  | str join ""
}
