use ../../numl.nu *

(PAGE --header '<title>Nushell as default shell</title>'
  '<h1>Nushell as defult shell</h1>'
  (l2 "As terminal default shell"
    (t "This just works and is generally not a bad idea.")
    (t "The only reason against it are:")
    (ul
      "I personally use 'bash' for quick things like opening files due to superior tab copmletion."
      "If nu would have some error for some reason you would have to fall back to something else."
    )
  )
  (l2 "As default $env.SHELL"
    (t "This tends to break a lot of programs since they expect it to be a POXIS shell.")
    (t "Some people do this and then have to apply fixes or workarounds to half the programs on their pc.")
  )
  (l2 "As login shell"
    (t "I highly advice against this.")
    (ul
      "If nu breaks for any reason you need a recovory OS to get back in."
      "Some programs expect this to be POXIS and break if its not. (same as with $env.SHELL)"
    )
    (t "It is a better idea to add a 'if interactive try to open nu' to your login shell.")
    (t "But i would not do that either due to my personal usecases for the login shell:")
    (ul
      "Open my WindowManager. (1 command for which the shell does not matter)"
      (e "The WM froze due to to high load. (in this case i want it to start up as fast as possible with as little resources as possible -> dash)")
    )
  )
) | save --force default_shell.html
