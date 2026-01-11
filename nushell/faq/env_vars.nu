use ../../numl.nu *

(PAGE --header '<title>Env Vars</title>'
  '<h1>Environmental Variables</h1>'

  (l2 'What are env-vars?'
    (t "Environmental Variables (short env-vars or $env) are variables, which get passed to child processes.")
    (ul
      "If you start vim from nu it will inherit nu's $env."
      "If you set a variable and restart it will be gone (since nu did not change the parent-processes value)."
      "You cannot write values back to the parent process (unless there is some special stuff going on)."
    )
    (t "So if you set a $env in nu and then start vim in it vim will know the value. But also: if you set a variable and restart nu it will be gone.")
  )

  (l2 "Using env vars in nu"
    {||
      $env.FOO = "123"  # set the env var "FOO" to "123" (a string)
      print $'Value: ($env.FOO)'  # read the env var
      
      $env.FOO = ($env.FOO | str upcase)  # update the value of "FOO"

      # alternative method of setting env-vars (also sets "FOO" to "123")
      load-env {
        FOO: "123"
      }
    }
    (ul
      (t "Env vars are also affected by " (link "nu-scoping" "https://www.nushell.sh/book/environment.html#scoping") ".")
      (t "$env are a OS feature and do not natively support structured data. To pass non-string env vars around look into $env.ENV_CONVERSIONS (semi-undocumented).")
      (t "The simplest way to have values set uppon nushell start add them to your $nu.config-path.")
    )
  )
)
| save -f ./env_vars.html
