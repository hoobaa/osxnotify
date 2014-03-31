osxnotify
================
You can notify from CLI on OS X.
This is copied from https://github.com/hoobaa/osxnotify .

Compile and Install
-------

	$ clang -framework Foundation osxnotify.m -o osxnotify
    $ sudo cp osxnotify /usr/local/bin/

Usage
-----

	Usage: osxnotify [-identifier <identifier>] [-title <title>] [-subtitle <subtitle>] [-informativeText <text>]
	
	Options:
	    -identifier NAME        some existing app identifier(default: com.apple.finder)
	    -title TEXT             title text
	    -subtitle TEXT          subtitle text
	    -informativeText TEXT   informative text

License
-------

    Public License.
