use ../../numl.nu *

def render_layer [layer]: nothing -> string {
  if ($layer | describe) == "string" {
    return $layer
  }

  $layer
  | transpose k v
  | each {|i| $"<details><summary>(e $i.k)</summary>(render_layer $i.v)</details>"}
  | str join ''
}

(PAGE
"<style>details{margin-left:10px;border-left:1px solid black;}</style>"
"<h1>Problem Solver</h1>"
(t "Usage: click on the option which most closely describes your problem.")
"<br>"
(render_layer {
  "it involves source, use, or overlay": {
    '"file not found"': (t "The file you are trying to source has to exist before the parent script is " (b "LOADED"))
  }
})
"<br>"
)
| save --raw -f problem_solver.html
