use ../../numl.nu *

(PAGE --header "<title>nu faq</title>"
  "<h1>Nu FAQ</h1>"
  (t "Explanations for questions i frequently hear about nu so that i can link them and thus don't forget stuff, etc.")
  (ul ...(glob *.html
    | where ($it | path split | last) not-in ["index.html", "problem_solver.html"]
    | each {|html_file|
      let name: string = ($html_file | path parse | get stem | str title-case)
      let file_name: string = ($html_file | path split | last)
      (link (e $name) $file_name)
    }
  ))
) | save --force index.html
