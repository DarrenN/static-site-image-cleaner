#!/usr/bin/env ruby -wKU

# Removes all images not being used in HTML or CSS

require 'rubygems'
require 'nokogiri'
require 'css_parser'

include CssParser

files_css       = Array.new
files_html      = Array.new
files_image     = Array.new
images_used     = Array.new


# 
# Get HTML files
#
Dir.chdir('www')
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

images_used.uniq!.sort!

#
# Get IMG files
#
Dir.chdir('img')
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
