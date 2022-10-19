# helpwith.fish

> My computer is missing so many man pages, sometimes I feel `--help | less`

There are a lot of things that `fish` does better than `bash`, but one thing
that neither does very well is the `help` command. Depending on whether you need
help with a function, a built-in, an executable file, or something else
entirely, you need to use a different command, be it `help`, `type`, `whatis`,
`which`, or something else. And then it still differs depending on whether you'd
like a short summary or the full information.

`helpwith.fish` provides a universal help command for the fish shell. Running
`helpwith <command>` will give you the following output:

	<command> is </path/to/bin | a function | an alias | ...>
	<command> - <short description>
	Show <man page | help page | definition>? [Enter/[q]uit]

You can also get straight to viewing the definition of any function with the
`-d/--definition` flag.

## Installation

	cd ~/.config/fish/functions
	wget https://raw.githubusercontent.com/davidhusz/helpwith.fish/main/helpwith.fish

And if, like me, you feel like typing eight letters to call this function is
simply asking too much:

	echo 'abbr --add h helpwith' >> ~/.config/fish/config.fish
