function helpwith --description 'Display help for any kind of command'
	argparse -n helpwith d/definition no-alias -- $argv
	set cmd $argv[1]
	set -q _flag_no_alias && set onlyfiles -f
	set type (type -t $onlyfiles $cmd 2> /dev/null)
	set cachedir ~/.cache/helpwith.fish
	set cachefile $cachedir/$cmd
	set historyfile ~/.local/share/fish/fish_history
	
	function show
		set prompt "Show $argv? (Enter/[q]uit) "
		read -n 1 -P $prompt reply
		while [ -n $reply -a $reply != q ]
			echo 'Invalid input, please try again.'
			read -n 1 -P $prompt reply
		end
		test -z $reply
	end
	
	function runwithhistory -V historyfile
		printf -- '- cmd: %s\n  when: %s\n' "$argv" (date +%s) >> $historyfile
		history merge
		$argv
	end
	
	function definition
		set source (functions -D $argv[1])
		if command -q bat
			set pager bat -l fish --pager 'less -R'
		else
			set pager less
		end
		if [ $source != '-' -a $source != stdin ]
			$pager $source
		else
			type $argv[1] | tail -n +3 | $pager
		end
	end
	
	function savecache -V cachedir -V cachefile
		mkdir -p $cachedir
		tee $cachefile
	end
	
	function printcache -V cmd -V cachefile
		# fish's built-in test function can't do timestamp comparisons
		set test (type -P test)
		if $test $cachefile -nt (man -w $cmd)
			cat $cachefile
		else
			return 1
		end
	end
	
	if not set -q _flag_definition
		switch $type
			case builtin function
				# we have to use `fish -c alias` instead of just `alias` here
				# because otherwise it fucks with the control characters for
				# some reason
				if fish -c alias | string match -qr "alias $cmd (?<def>.*)\$" \
						&& not set -q _flag_no_alias
					echo "$cmd is an alias of $def"
					if string match -qr "^.$cmd" $def \
							&& show "help for wrapped command '$cmd'"
						echo ---
						helpwith --no-alias $cmd
					end
				else
					echo "$cmd is a $type"
					if man -w $cmd.1 &> /dev/null
						# $cmd is builtin, or pre-defined function
						man $cmd.1 | grep --color=never -om1 "$cmd - .*\$"
						if show man page
							man $cmd.1
						end
					else
						# $cmd is a user-defined function
						echo $cmd - (type $cmd | sed -En '0,/--description/ s/^.*--description (.*)$/\1/p' | string unescape)
						if show definition
							definition $cmd
						end
					end
				end
			case file
				type $onlyfiles $cmd
				if man -w $cmd &> /dev/null
					# $cmd is a program with a man page
					printcache ||
						# HACK: why does `man jq > /dev/null` generate weird error messages?
						man $cmd 2> /dev/null | grep -m1 "$cmd.* - " | string trim | savecache
					if show man page
						runwithhistory man $cmd
					end
				else
					# $cmd is a program without a man page
					if show help page
						$cmd --help | less
					end
				end
			case '*'
				if abbr --list | string match -q $cmd
					# $cmd is an abbreviation
					abbr --show | string match -qr -- "-- $cmd (?<def>.*)\$"
					echo "$cmd is an abbreviation for $def"
				else
					# $cmd is an unknown command
					echo "Could not find any information for $cmd" >&2
					return 1
				end
		end
	else
		definition $cmd
	end
	
	# Erase inner functions so that they don't persist after `helpwith` was executed
	functions --erase show runwithhistory definition savecache printcache
end

# TODO: add option completions
complete -c helpwith --erase
complete -c helpwith -fa '(complete -C "" | cut -f1 | uniq)'
