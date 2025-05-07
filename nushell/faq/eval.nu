use ../../numl.nu *

(PAGE --header '<title>Nushell eval</title>'
  '<h1>Eval in nu</h1>'
  (t "Eval is often a bad workaround and should be avoided in all languages. "
    "But sometimes you need it. "
    "So i will show both alternatives and ways to use it.")


  (l2 "Eval"
    (l3 "Method 1: Using -c"
      (t "Downside: you have to manually pass all variables, etc")
      {||
        def eval_via_c [code: string]: nothing -> string {
          # you can also use "^nu", but "^$nu.current-exe" avoids issues if someones $env.PATH is messed up, has multiple installations, etc
          ^$nu.current-exe --no-config-file --no-history -c $code
        }
      }
    )

    (l3 "Method 2: Using a temporary script"
      (t "Downside: you have to manually pass all variables, etc")
      {||
        def eval_via_script [code: string]: nothing -> string {
          let tmpfile: path = (mktemp)
          $code | save --raw --force $tmpfile
          # we use "try" to ensure that the file gets cleaned up
          try {
            let result = (^$nu.current-exe --no-config-file --no-history $tmpfile)
            rm $tmpfile
            return $result
          } catch {|error|
            rm $tmpfile
            $error.raw  # rethrow error
          }
        }
      }
    )

    (l3 "Method 3: Using source or use"
      (t "Downside: this only works in the context of a shell or shell config, not within a script. "
        "This is due to the requirement that source and use both require the target-file to exist before the script starts executing.")
      (t "Downside: env.nu is deprecated, so this might stop working there.")
      (t "Upside: you can export functions, use defined variables, etc.")
      (code --language nu "
        # save_path: has to be the same in both part1 and part2 (and also unique)
        const save_path: path = '/example/path.nu'

        # put this part into $nu.env-path
        let code: string = '
          let foo = \"bar\"
          def hello_world [] { print \"Hello World\" }
          rm -rf /foo/*
        '
        $code | save --raw --force $save_path


        # put this part into $nu.config-path
        # you can also use \"use\" or \"overlay use\" instaed of \"source\", but that comes with its own restrictions
        source $save_path
      ")
    )
  )


  (l2 "Alternatives"
    (l3 "Building external commands"
      {||
        let foo = true

        # build a array of arguments
        mut my_command: list<string> = ["git", "commit"]
        if $foo {
          $my_command = ($my_command | append "-a")
        }
        $my_command = ($my_command | append (glob *.nu))

        # run it
        ^...($my_command)
      }
      (t "Another method to build the array:")
      (code --language "nu" '
        ^...([
          "git" "commit"
          (if $foo { "-a" })
          ...(glob *.nu)
        ] | compact)
      ')
    )

    (l3 "Closures (and match, functions, if, etc)"
      {||
        let greeting_closure = {|name|
          print $"Hello, ($name)!"
        }

        do $greeting_closure "World"
      }
      {||
        let mode: string = "git"
        let closure = ({
          "git": {|url| ^git clone $url}
          "jj": {|url| ^jj clone $url}
        } | get $mode)
        do $closure "foo"
      }
      {||
        def each2 [each_closure, --thread-count(-t): int]: any -> any {
          let input = $in
          match $thread_count {
            1 => {
              $input | each $each_closure
            }
            $other => {
              $input | par-each --threads $other $each_closure
            }
          }
        }

        ["foo"] | each2 -t 1 { str title-case }
      }
    )
  )
)
