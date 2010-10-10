Static Site Image Cleaner
=========================

A quick script that uses [Nokogiri](http://nokogiri.org/) and my own fork of the [CssParser Gem](http://github.com/DarrenN/css_parser) to search your static HTML/CSS for un-used images and delete them.

Still very much beta.

To-Use:
-------

-d Directory you want to check (default is `www`)
-i Directory where your images are stored (default is `img`)

ex: `ruby cleaner.rb -d WWW -i img`

or if you make it executable and drop in your `bin`:

`cleaner -d WWW -i img`

To test:
--------

	$ ruby cleaner.rb
	
That will run through the `www` directory in the package and remove any images not being used by `.html` or `.css` files.

To-do's
-------

* Write proper tests