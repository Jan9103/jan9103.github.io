use ../numl.nu *
(PAGE --header '<title>Are We Nu Yet</title>'
  '<h1>Are we Nu yet?</h1>'

  (notice 'This page reflects my (jan9103) personal opinion.')

  (t 'This tries to mainly answer the question "Should i use nu-scripting in production". '
    'In my eyes: ' (b 'no') ', but your usecase and definition might differ.')

  (l2 --expanded 'API/Language stability'
    (t 'Nu still recieves breaking changes basically every update. Often to core parts of the language.')
    (h3 'Why does this matter?' (ul
      $'You (b "cannot leave a script alone") for half a year and expect it to still work.'
      $'Since not every work-colleague/distro/github-user/.. updates frequently you will have to (b "write everything backwards-compatible"). I still find 2 year old versions in new help-forum posts.'
      $'You will have to (b "constantly update") and partially rewrite (b "existing scripts"). And sometimes compatability workarounds are.. time intensive.'
    ))
    (h3 'A few examples' (ul
      $'(code -l "nu" "let-env foo = bar") was changed to (code -l "nu" "$env.foo = \"bar\"") without transition period.'
      $'(code -l "nu" "timeit") used to support blocks, etc as argument.'
      $"Default flags change constantly \(example: (code -l 'nu' 'du') used to behave like (code -l 'nu' 'du -al'))."
      $'(code -l "nu" "$env.CURRENT_FILE") used to represent the file executed, not the file containing the code.'
      $'(code -l "nu" "range") was renamed to (code -l 'nu' "slice") without any deprecation period.'
      $"The idea of replacing (code -l 'nu' 'get -i')'s meaning from (code '--ignore-errors') to (code '--ignore-case') has been floating around."
    ))
    (l3 'Workarounds to this' (ul
      'You can obviously harden your code to many changes, but it takes quite some time to learn that and only reduces the maintenance cost.'
      $"I used to \(and might someday again\) maintain a (link 'forward compatability library' 'https://github.com/Jan9103/nine'), but for many changes it is essentially impossible."
      'Pin your nu version company-wide. (resulting in no support, etc)'
      $"Embed your apps as a binary with a pinned nu version \((link 'tutorial' 'https://github.com/cablehead/how-to-embed-nu')\)."
    ))
  )

  (l2 --expanded 'Tooling'
    {
      'LSP': 'Builtin and decent'
      'Treesitter (editor syntax highlighting)': (ul
        $"(link 'Official' 'https://github.com/nushell/tree-sitter-nu'): Has become pretty good. But sadly editors like helix do not update it often enough and thus do not include new syntax things."
        $"(link 'LhKipp' 'https://github.com/LhKipp/tree-sitter-nu'): archived, outdated, and pretty broken. But still the default for some editors."
      )
      'Package/Dependency/.. manager': $"Nothing mature \((link 'comparison' 'https://jan9103.github.io/nushell/faq/package_management.html'))"
      'Formatter': $"(link 'topiary' 'https://github.com/blindFS/topiary-nushell') \(AFAIK still missing a lot of features, but generally usable)"
      'Code-nagger (clippy, shellcheck, etc)': 'nope'
    }
  )

  (l2 --expanded 'Capabilities'
    (l3 'Can nu do everything bash can?'
      (p 'In most cases.')
      (p 'Jobs are new and closed one of the last few big gaps, but a lot of things like FIFO are still buggy.')
    )
    (l3 'Can nu replace python?'
      (p 'Sometimes.')
      (p 'Nu excells at some things, but is can become unwieldy to impossible for other things': (ul
        $"Opening a port is \"possible\", but comes with many restrictions \((link 'example' 'https://github.com/Jan9103/webserver.nu'))."
        'Parsing complex streams without collecting them is essentially impossible. (zip files, videos, zim files, etc).'
        'Parsing binary data is a chore.'
        'Multithreading requires workarounds at all corners.'
        'Mutable variables are lacking (they dont work in each, catch, etc).'
        'etc'
      ))
    )
  )

  (l2 --expanded 'Reliability'
    (p 'Nu has a lot of bugs, but so does everything else. So lets talk about how likely you are to encounter them:' (ul
      'Every time a "*.*.1" version was released it did have a big flaw (like not beeing installable) in the release. recent examples: 0.90, 0.92, 0.94, 0.96, 0.97, 0.99, 0.104, 0.105.'
      $'Commands like (code -l "nu" "ffmpeg") sometimes bug out when used within (code -l "nu" "par-each") or (code -l "nu" "each").'
      '(fairly uncommon now) the parser sometimes panickes from normal code.'
      $'Some commands like (code -l "nu" "find") are/contain a lot of invisible footguns.'
      'etc'
    ) 'All in all i would say after getting used to the basics and hardening your code you maybe encounter one every few weeks.')
  )

  (l2 --expanded 'Libraries'
    (p 'If you expect python level library support: nope.')
    (p "You want to interact with MongoDB, redis, twitter, etc? write it yourself.")
    (p $'But some libraries already exist: (link "incomplete list" "https://jan9103.github.io/nushell_packages/package_index.html")')
    (p 'Keep in mind that plugins have to be updated constantly and thus most are broken (especially right after a nu update)')
  )

)
| save -f ./env_vars.html

