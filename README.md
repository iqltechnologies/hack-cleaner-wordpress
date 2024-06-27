# Hack Cleaner for WordPress
Has your wordpress website got compromised or hacked? Don't worry use this script to clean and restore your wordpress back to normal.

This is a simple shell script that lets you clean your hacked wordpress account. 

## For this script to work, your database must be intact. 

# How to use

  - login to your server with a command line
  - move to home directory (NOT public_html just one directory before public_html)
  - download and place this script at your root with the following command:
  - `wget https://cdn.jsdelivr.net/gh/iqltechnologies/hack-cleaner-wordpress/hc.sh`
  - make it executable `chmod +x hc.sh`
  - run it `./hc.sh run_all`
  - if you want to run 

## options

  - move_html : reinstall a fresh html
  - update_plugins : fetch list of plugins and install fresh wordpress 
  - update_themes : fetch list of previously installed themes and install them
  - copy_uploads : copy uploads directory
  - run_all : do everything sequentially

## copyright
Tariq Abdullah 2024

## Help and Support
tariq@iqltech.com
