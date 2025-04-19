use ../../numl.nu *

(PAGE --header '<title>Nushell tab completion</title>'
  '<h1>Tab completion</h1>'

  (l2 "Method1: External Completer (recommended)"
    (t "This method tells nu to use an external program for tab-completing.")
    (t (link "(nu book)" "https://www.nushell.sh/cookbook/external_completers.html"))
    (ul
      "Pro: Very good completions for most programs"
      "Pro: Low performance impact"
      "Con: Requires a extra binary"
      "Con: Slightly slower (not noticable)"
    )

    "Options:"
    (ul
      [(link "Carapace" "https://github.com/carapace-sh/carapace") ": Works well for me"]
      [(link "Fish" "https://github.com/fish-shell/fish-shell") ": Based on the fish-shell"]
      (link "Mix and match" "https://www.nushell.sh/cookbook/external_completers.html#multiple-completer")
    )

    (l3 "Setup / install methods"
      (l4 "Package managers"
        (t (link "overview" "package_management.html"))
        "Carapace:"
        (ul
          [(link "numng" "https://github.com/jan9103/numng") {|| {"name": "jan9103/nu-snippets/integration/carapace", "version": "git"}}]
        )
        "Fish:"
        (ul
          [(link "numng" "https://github.com/jan9103/numng") {|| {"name": "jan9103/nu-snippets/integration/fish_completer", "version": "git"}}]
        )
      )
      (l4 "Copying a config snippet into config.nu"
        "Carapace:"
        {||
          $env.config = (
            $env.config?
            | default {}
            | upsert completions.external {
              enable: true
              completer: {|spans|
                ^carapace $spans.0 nushell ...$spans
                | from json
                | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
              }
            }
          )
        }
        "Fish:"
        {||
          $env.config = (
            $env.config?
            | default {}
            | upsert completions.external {
              enable: true
              completer: {|spans|
                ^fish --command $'complete "--do-complete=($spans | str join " ")"'
                | $"value(char tab)description(char newline)" + $in
                | from tsv --flexible --no-infer
              }
            }
          )
        }
      )
    )
  )

  (l2 "Method2: Completion config snippets"
    (t (e 'This is the nushell "native" method. You can either write these yourself (a lot of work) or use ones someone else already wrote.'))
    (ul
      "Pro: Nothing external needed"
      "Pro: Theoretically the fastest"
      "Pro: Full control over it"
      (e 'Con: It requires a lot of resources if you try to have "everything"')
      "Con: Far from complete"
    )
    (l3 "Setup / install methods"
      (l4 "Package managers"
        (t (link "overview" "package_management.html"))
        (ul
          "Pro: no need to manually manage everything"
          "Pro: auto updates"
        )
      )
      (l4 "Manually adding it to you config"
        (ul
          "Pro: Full control"
          "Pro: Easier to get started with"
          "Pro: You see nu code and might learn something"
          "Con: A lot more work to manage (update, add, remove, etc)"
        )
        "Sources:"
        (ul
          (link "nu_scripts" "https://github.com/nushell/nu_scripts/tree/main/custom-completions")
          ()
        )
      )
    )
  )

) | save --force "tab_completion.html"
