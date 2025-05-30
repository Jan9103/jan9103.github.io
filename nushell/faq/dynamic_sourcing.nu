use ../../numl.nu *

(PAGE --header '<title>Dynamic sourcing</title>'
  '<h1>Dynamic sourcing</h1>'

  (l2 --expanded "Understanding the problem"
    (t "In nushell the target file of " (b "source") " and " (b "use") " have to be constant.")
    (t "Additionally a imported file has to exist before the script/config/.. is loaded.")
    (t "This breaks a lot of the intuitive options.")
  )

  (l2 "Method1: if else"
    (t "Yes the target has to be constant, but a lot of things can be constant. This includes")
    (code --language "nu" 'source (if $nu.os-info.name == "windows" {"windows.nu"} else {"linux.nu"})')
    "and (credit to bahex for this one)"
    (code --language "nu" '
      module unix {
        export def hello [] { "hello unix" }
      }
      module windows {
        export def hello [] { "hello windows" }
      }

      use (if $nu.os-info.family == "unix" { "unix" } else { "windows" }) *
      hello
    ')
  )

  (l2 "Method2: autoload dirs"
    (t "The variables " (b "$nu.user-autoload-dirs") " and " (b "$nu.vendor-autoload-dirs")
      " contain a list of directories from which all scripts will be sourced on startup.")
    (t "Thus you can just put things in there or not depending on your device.")
    (link "More information" "https://www.nushell.sh/book/configuration.html#startup-variables")
  )

  (l2 "Method3: (nu config only) config.nu + env.nu"
    (notice "There has been a discussion to remove env.nu for quite a while. So this method might break at some point.")

    (t "A file has to exist when a script is loaded, but noone said it has to be loaded on shell start.")
    (t (b "env.nu") " is loaded before " (b "config.nu") " and thus it is possible to generate a script "
      "in " (b "env.nu") " and then later load it in " (b "config.nu") ".")
    (t "Example:")
    (b "env.nu") ":"
    {||
      [
        (if $nu.os-info.family == "unix" { "source foo.nu" } else { "source bar.nu" })
        (if $env.USER == "bob" { "source bob.nu" } else { "" })
      ] | str join "\n" | save -rf "dynamic_loader.nu"
    }
    (b "config.nu") ":"
    (code --language "nu" 'source dynamic_loader.nu')
  )

  (l2 "Method4: package managers"
    (t "Some package managers allow dynamic configurations, but you can also just keep a seperate "
      "package list for each of your devices.")
    (t "Yes this means you have to maintain something on a 'per-device' basis, but a package-list "
      "is a lot easier in my eyes.")
    (link "More information" "./package_management.html")
  )

) | save -rf 'dynamic_sourcing.html'

