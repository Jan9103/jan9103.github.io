# Is Nu production ready?

**STATUS: 2025-12-09 (nu v0.109.1)**

Aka:
* Should i use nu scripting at my company?
* Is nu a good embedded language?
* Should i use nu in a location where it might brick my workflow?
* etc

I like the enthusiasm, but as a fellow end-user here are a
few things you might want to consider.

## Important Note

I use nu a lot and want it to succeed.  

This is **my personal pessimistic opinion** and POV.  
There are people who disagree with each of my points.  
I will explain my points and let you build your own opinion.

## @other_nu_users which want to complain about this

And yes more users are good (potential testers, contributors, etc).  
But:
* If someone gets burned once they might not return. Thus hurting in the long-run.
* You get used to quirks when using something and think of them as outliers, etc.
  * You should agree that the wrong code getting executed with the wrong variables is a no-go and **should never ever happen** in production (16826).

So i prefer to be honest about what it can (not) do NOW.  
I host this outside of any official pages with this note.

If something is wrong feel free to send me a message, but i won't delete this just because "it might slow the adoption".

"Why don't you fix the stuff bothering you?"
...
Yes some things i could speed up (and sometimes do), but some i can't fix.  
Because they are out of my control, because i do not have infinite time, etc.  
Rust-analyzer does not even work within the nushell repo..  
Also: look at my github. i have been trying to fix the package-manager, library, breaking-change, debugger, test-library, etc situations for a while..


## My points

### Language stability

Nu has not reached 1.0 and breaks bigger scripts/configs/.. with about every second update.

Sometimes you can write code to work with both versions, but not always.

**Why care?**

* Scripts often get written once and then left to rot.
* If you use a script infrequently you might have a lot to figure out and fix.
* If colleagues/users/devices update slower/faster things will not work for everyone.

**Why not freeze the version?**

* You will stay stuck with a lot of bugs, including serious ones.
  * Example: In 0.107 a thrown error might cause nu to repeatedly execute unrelated code (bug no 16826)
* Security.
  * Nu can connect to the web, meaning a CVE in a old version of a embedded dependency could result in ACE.


### Adoption

Yes this is a self-causing issue. But it is still a issue in some use-cases.

Why would your colleague learn nu if python can do the same?  
Nu might be a bit more compact or whatever, but very different and thus "hard" to learn.

There are very few online resources.
* The book is basically the only tutorial.
* Almost all questions are asked on the discord, making them unsearchable (compared to python with stack-overflow, etc).
* AI needs a lot of example code, tutorials, etc to work properly. Nu is missing that.

These get worse due to the stability.
* Answers are outdated (new better ways, no longer works, etc)
* After learning it you have to keep up.
  * If you learn python today, don't use it for 2 years, and then write it again: it will still work the same.

And for some things you need tutorials.. How long would it take you to come up with or understand `0 | tee {|| null; ^whatever; null } | ignore`?  
(This spawns a background thread, which does not get bricked by certain "features" and does not prevent you from closing your shell)


### Tooling is missing

LSP? builtin, but do not expect a rust-analyzer.

Debugger? there are attempts.. and `strace` (c-code debugger) always works.. but no good `set -x` equivalent or [DAP](https://microsoft.github.io/debug-adapter-protocol/) AFAIK.

Formatter?
* there is a unfinished official one.
* there is [a plugin for a general-purpose one](https://github.com/blindFS/topiary-nushell).

Nagger (shellcheck or similar)?
* a lot outdated
* a lot very opinionated ones (which i disagree with)
* a few which do almost nothing

Dependency/Library/Plugin/.. manager? nothing ready for production use. And based on past pace it will take a while.

Test-framework? Dozens. But all very rudimentary, abandoned, or similar.

Libraries? nope.


### Nu is WIP and scripting feels like a third class citizen

Wait what?
Well officially the shell and shell-scripting are the same priority i think.  
But when scripting something a bit more and watch the changelog it feels like
the priority order is: shell, then language design, then scripting.

Examples:
* `mod.nu` and `def main` have been sketchy for a long time
* typing and type-checking are.. possible..
  * basic types like `map`, `tuple`, etc are missing.
  * types get ignored 99% of the time.
  * you get random type-errors.
    * example: if you order `oneof` "wrong" (`oneof<nothing, int>` is different from `oneof<int, nothing>` in some scenarios).
    * `export const FOO: list<int> = [1 2 3]` used to be "wrong" for a long time (14023).
  * for type-checking you either use regex (which is hard since a `table<foo: int>` might be detected as `list<any> (stream)`, etc) or a big 3rd party library (again: there is no dependency-manager).
* plugins are not available in libraries (and in my eyes the wrong approach for 80% of its uses, but still get pushed for a lot for some reason - but that is a different topic)
* breaking changes have no grace-period making it very hard to support "the 2 latest versions", which is required for libraries since people often up to 8 versions behind.
* the changelog has a "breaking changes" section, which is usually incomplete. e.g. `@example` no longer allowing dummy variables since `0.109.0` has no documentation at all.
