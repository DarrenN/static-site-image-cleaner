Static Site Image Cleaner
=========================

A quick script that uses [Nokogiri](http://nokogiri.org/) and my own fork of the [CssParser Gem](http://github.com/DarrenN/css_parser) to search your static HTML/CSS for un-used images and delete them.

Still very much beta.

To test:
--------

	$ ruby cleaner.rb
	
That will run through the `www` directory in the package and remove any images not being used by `.html` or `.css` files.

To-do's
-------

* Take args from the command line to point to directories
* Write proper tests