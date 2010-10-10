#!/usr/bin/env ruby -wKU

# Removes all images not being used in HTML or CSS

require 'rubygems'
require 'nokogiri'
require 'css_parser'
require 'optparse'

include CssParser

files_css       = Array.new
files_html      = Array.new
files_image     = Array.new
images_used     = Array.new

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
 # TODO: Put command-line options here
 options[:dir] = ""
  opts.on( '-d', '--dir DIRECTORY', "Mandatory argument" ) do|d|
    options[:dir] = d
  end
  
  options[:img] = ""
    opts.on( '-i', '--img IMAGE DIRECTORY', "Mandatory argument" ) do|i|
      options[:img] = i
    end
 
 # This displays the help screen, all programs are
 # assumed to have this option.
 opts.on( '-h', '--help', 'Display this screen' ) do
   puts opts
   exit
 end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

# If no -file is set then grab a list

if options[:dir].empty?
 Dir.chdir('www')
else
 Dir.chdir(options[:dir])
end

# 
# Get HTML files
#
# Dir.chdir('www')
 files_html = Dir.glob('*.html')

#
# Rip through HTML with Nokogiri and load up
# our arrays
#
files_html.each do |html|
  
  # Get all CSS from <link>
  doc = Nokogiri::HTML(File.open(html))
  doc.css("link").each { |node| files_css << node['href'] }
  
  # Get all img src
  doc.css("img").each { |node| images_used << node['src'] }
  
  #
  # Use CssParser to find any img refs
  # place in the inline CSS of the document
  #
  css_block = doc.css("style").inner_html
  
  css_parser = CssParser::Parser.new({:local => true})
  css_parser.add_block!(css_block)
  css_parser.each_selector() do |selector, declarations, specificity|
    if (selector =~ (/@import url\('[\w\W]*'\);/))
      images_used << declarations.scan(/url\('([\w\W]*)'\);/)[0][0].to_s
    end
  end
  
  #
  # using the CssParser for @imports doesn't work
  # so we will use a RegEx to pull them out
  # from the inline CSS ourself - which sucks
  #   
  # split up the CSS  
  tmp = css_block.strip.split(/\n/)
  
  # scan for @imports and add to files_css array
  tmp.each do |t|
    t.scan(/@import url\('[\w\W]*'\);/) { |s| files_css << s.scan(/@import url\('([\w\W]*)'\);/)[0][0].to_s }
  end  
  
end

#
# We now use CssParser to load all external CSS
# we can find and look for url() declarations
#
files_css.uniq!
files_css.each do |css|
  
  css_parser = CssParser::Parser.new({:local => true, :css_dir => 'css'})
  css_parser.load_uri!(css)
    css_parser.each_selector() do |selector, declarations, specificity|
      if (declarations =~ (/url\('[\w\W]*'\)/))
        images_used << declarations.scan(/url\('([\w\W]*)'\)/)[0][0].to_s.gsub(/\.\.\//,'')
      end
    end
  
end

images_used = images_used.uniq
images_used = images_used.sort

#
# Get IMG files
#

if options[:img].empty?
 Dir.chdir('img')
else
 Dir.chdir(options[:img])
end

files_image = Dir.glob('*')

# Strip out image directory
images_used.map! {|m| m.gsub(/img\//,'')}

# Get images that are not used
delete_images = files_image - images_used

# Delete them
delete_images.each do |d|
  print "Deleting: #{d} \n"
  File.delete(d)
end
