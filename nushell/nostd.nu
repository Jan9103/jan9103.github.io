use ../numl.nu *

(PAGE --header '<title>Nu: nostd</title>'
  '<h1>Nu: nostd</h1>'

  (l2 --expanded "Nostd"
    (t "If you come from rust you might already know nostd.")
    (t "In the nu context it means the same thing: the 'std' library is not used and could thus be disabled while running/compiling the code.")
  )

  (l2 "Why?"
    (t "Speed.")
    (t "Just try running the following in your terminal:")
    {||
      use std/bench  # benchmarking tool

      (bench
        --rounds 10  # run each test 10 times
        --warmup 1  # make sure it is not a disk issue
        # standard nushell with std
        {|| ^$nu.current-exe --no-config-file --no-history -c '' }
        # loading a single std module
        {|| ^$nu.current-exe --no-config-file --no-history -c 'use std/clip' }
        # loading all of std
        {|| ^$nu.current-exe --no-config-file --no-history -c 'use std' }
        # disable std
        {|| ^$nu.current-exe --no-config-file --no-history --no-std-lib -c ''}
      )
      | explore  # make it easier to explore the resulting data
    }
    (t "I get the following results:")
    (ntable
      --header-row ['mode' 'mean startup time' 'relative']
      ['no std' '27ms' '1x']
      ['std enabled (default)' '63ms' '2.33x']
      ['use std/clip' '72ms' '2.66x']
      ['use all' '301ms' '11.03x']
    )
    (t 'Why does just having it enabled add so much time? its probably parsing the AST.')
    (t 'Yes nostd is the nuclear approach, but depending on the usecase 50ms can make quite a difference.')
    (t 'And i hope that this at least gets you to use specific modules instead of ' {||use std} '.')
  )

  (l2 'Should i use it?'
    (t 'As you can see from the example in "why": it can be a huge speedup in the best case (std beeing imported for absolutely no reason).')
    (t 'But in a real-world-usecase you probably would actually make use of std and thus probably have more code without it.')
    (t 'Thus it depends on your specific usecase.')
    (t 'If std has one function doing exactly what you need it might still not be worth it. For example:')

    (l3 'Example 1: clip copy'
      (t 'Lets say you have a tiny frequently called script and want to copy a string to your clipboard.')

      (t 'Here is the code of ' (code 'std/clip copy') '(MIT License)')
      {||
        export def copy [
          --ansi (-a)                 # Copy ansi formatting
        ]: any -> nothing {
          let input = $in | collect
          if not $ansi {
            $env.config.use_ansi_coloring = false
          }
          let text = match ($input | describe -d | get type) {
            $type if $type in [ table, record, list ] => {
              $input | table -e
            }
            _ => {$input}
          }

          print -n $'(ansi osc)52;c;($text | encode base64)(ansi st)'
        }
      }
      (t 'But you can usually shorten it to:')
      {||
        alias clip_copy = print -n $'(ansi osc)52;c;($in | encode base64)(ansi st)'
      }
      (ul
        'The std solution is more code, which is convenient, but often not needed.'
        'If you use nothing else of std this still adds the full "std enabled" overhead.'
        (c 'If you ' {||use std} ' instead of ' {||use std/clip} ' you get a lot more overhead')
        (c 'Even if you ' {||use std/clip [copy]} ' it still loads 3 times the amount of functions you need (prefix, paste, copy)')
      )
      (t 'but')
      (ul
        'You have to figure out the snippet'
        'The gain is "only" a few ms and when using the clipbord the human will be a lot slower.'
        (c 'Less code means less maintenacne. Yes it is only ' (code 'print') ', ' (code 'encode') ', and ' (code 'ansi') ', but it might still break. Altought the same is true for std changing.')
        (c 'If you also add ' {||use std/log} ' or similar the advantages of std start to add up.')
      )
    )
  )

  (l2 'How can i use it?'
    (l3 'In scripts'
      (t 'just replace your old hashbang ' (code '#!/usr/bin/env nu') ' with ' (code '#!/usr/bin/env nu --no-config-file --no-history') '.')
      (t 'But keep in mind that EVERYTHING in your script (including libraries used) have to be nostd too.')
    )
    (l3 'In the interactive shell'
      (t "Depends on your terminal. If you can't configure arguments for your shell you could use a wrapper-script, but that might mitigate the upside.")
      (t "And in general 'std/bench', etc can be quite useful in a shell context.")
      (t 'But keep in mind that EVERYTHING in your config (including libraries used) has to be nostd too and that you wont be able to ' (code 'use std') ' at runtime.')
    )
    (l3 'In libraries/modules'
      (t "Even if your library is std compatible it only has any upside if whatever loads it uses it.")
      (t "Just do not import 'std' and only use libraries which do the same.")
    )
  )
) | save -rf 'nostd.html'
