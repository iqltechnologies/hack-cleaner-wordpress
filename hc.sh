#!/bin/bash

echo " HACK Cleaner   _   IQL Technologies   "
echo " |_|  _.  _ |  /  |  _   _. ._   _  ._ "
echo " | | (_| (_ |<_\_ | (/_ (_| | | (/_ |  "
echo "          tariq@iqltech.com            "
echo "               V.1.0                   "

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WP_CONFIG_BACKUP_FILE="$SCRIPT_DIR/public_html_backup/wp-config.php"
WP_CONFIG_SAMPLE="$SCRIPT_DIR/public_html/wp-config-sample.php"
WP_CONFIG_NEW="$SCRIPT_DIR/public_html/wp-config.php"
PLUGINS_DIR="$SCRIPT_DIR/public_html_backup/wp-content/plugins"
THEMES_DIR="$SCRIPT_DIR/public_html_backup/wp-content/themes"
UPLOADS_DIR="$SCRIPT_DIR/public_html_backup/wp-content/uploads"


function move_html {
  echo "Navigating to the script directory..."
  cd "$SCRIPT_DIR"

  echo "Moving public_html to public_html_backup..."
  mv public_html public_html_backup

  echo "Creating empty public_html..."
  mkdir public_html
  cd public_html

  echo "Downloading WordPress..."
  wget https://wordpress.org/latest.zip

  echo "Unzipping WordPress..."
  unzip latest.zip

  echo "Moving WordPress to public_html..."
  mv wordpress/* ./

  echo "Removing WordPress Zip Archive..."
  rm latest.zip
}

function config_setup {
  cd "$SCRIPT_DIR"

  echo "Checking if wp-config.php exists in public_html_backup directory..."
  if [ ! -f "$WP_CONFIG_BACKUP_FILE" ]; then
    echo "Error: $WP_CONFIG_BACKUP_FILE not found!"
    exit 1
  fi

  echo "wp-config.php found. Extracting values..."
  DB_NAME=$(grep "define( 'DB_NAME'" $WP_CONFIG_BACKUP_FILE | cut -d \' -f 4)
  DB_USER=$(grep "define( 'DB_USER'" $WP_CONFIG_BACKUP_FILE | cut -d \' -f 4)
  DB_PASSWORD=$(grep "define( 'DB_PASSWORD'" $WP_CONFIG_BACKUP_FILE | cut -d \' -f 4)
  DB_HOST=$(grep "define( 'DB_HOST'" $WP_CONFIG_BACKUP_FILE | cut -d \' -f 4)
  TABLE_PREFIX=$(grep "\$table_prefix" $WP_CONFIG_BACKUP_FILE | cut -d \' -f 2)

  echo "Extracted values:"
  echo "DB_NAME: $DB_NAME"
  echo "DB_USER: $DB_USER"
  echo "DB_PASSWORD: $DB_PASSWORD"
  echo "DB_HOST: $DB_HOST"
  echo "TABLE_PREFIX: $TABLE_PREFIX"

  echo "Checking if wp-config-sample.php exists in public_html directory..."
  if [ ! -f "$WP_CONFIG_SAMPLE" ]; then
    echo "Error: $WP_CONFIG_SAMPLE not found!"
    exit 1
  fi

  echo "wp-config-sample.php found. Creating new wp-config.php..."
  cp $WP_CONFIG_SAMPLE $WP_CONFIG_NEW

  echo "Setting extracted values in wp-config.php..."
  sed -i "s/database_name_here/$DB_NAME/" $WP_CONFIG_NEW
  sed -i "s/username_here/$DB_USER/" $WP_CONFIG_NEW
  sed -i "s/password_here/$DB_PASSWORD/" $WP_CONFIG_NEW
  sed -i "s/localhost/$DB_HOST/" $WP_CONFIG_NEW
  sed -i "s/\$table_prefix = 'wp_';/\$table_prefix = '$TABLE_PREFIX';/" $WP_CONFIG_NEW

  echo "wp-config.php has been created and configured successfully in public_html."
}

function update_plugins {
  echo "Checking WordPress Plugins which were previously installed"
  if [ ! -d "$PLUGINS_DIR" ]; then
    echo "Error: $PLUGINS_DIR not found!"
    exit 1
  fi

  echo "Plugins directory found. Retrieving list of plugins..."
  PLUGINS=$(ls -d $PLUGINS_DIR/*/ | xargs -n 1 basename)

  echo "Found plugins:"
  echo "$PLUGINS"

  for PLUGIN in $PLUGINS; do
    echo "Processing plugin: $PLUGIN"
    PLUGIN_URL="https://downloads.wordpress.org/plugin/$PLUGIN.latest-stable.zip"
    echo "Downloading $PLUGIN from $PLUGIN_URL..."
    wget -q $PLUGIN_URL -O /tmp/$PLUGIN.zip

    if [ $? -eq 0 ]; then
      echo "Download successful. Extracting $PLUGIN..."
      unzip -q /tmp/$PLUGIN.zip -d $SCRIPT_DIR/public_html/wp-content/plugins
      if [ $? -eq 0 ]; then
        echo "Extraction successful for $PLUGIN."
      else
        echo "Error extracting $PLUGIN."
      fi
      rm /tmp/$PLUGIN.zip
    else
      echo "Error downloading $PLUGIN."
    fi
  done
  echo "Plugin update process completed."
}

function update_themes {
  echo "Checking if themes directory exists in public_html_backup..."
  if [ ! -d "$THEMES_DIR" ]; then
    echo "Error: $THEMES_DIR not found!"
    exit 1
  fi

  echo "Themes directory found. Retrieving list of themes..."
  THEMES=$(ls -d $THEMES_DIR/*/ | xargs -n 1 basename)

  echo "Found themes:"
  echo "$THEMES"

  for THEME in $THEMES; do
    echo "Processing theme: $THEME"
    THEME_URL="https://downloads.wordpress.org/theme/$THEME.latest-stable.zip"
    echo "Downloading $THEME from $THEME_URL..."
    wget -q $THEME_URL -O /tmp/$THEME.zip

    if [ $? -eq 0 ]; then
      echo "Download successful. Extracting $THEME..."
      unzip -q /tmp/$THEME.zip -d $SCRIPT_DIR/public_html/wp-content/themes
      if [ $? -eq 0 ]; then
        echo "Extraction successful for $THEME."
      else
        echo "Error extracting $THEME."
      fi
      rm /tmp/$THEME.zip
    else
      echo "Error downloading $THEME."
    fi
  done

  echo "Theme update process completed."
}

function copy_uploads {
  echo "Moving uploads folder and removing all sh and php files"
  if [ ! -d "$UPLOADS_DIR" ]; then
    echo "Error: $UPLOADS_DIR not found!"
    exit 1
  fi

  echo "Uploads directory found. Cleaning up .php and .sh files..."
  find "$UPLOADS_DIR" -type f \( -name "*.php" -o -name "*.sh" \) -delete

  echo "All .php and .sh files removed from uploads directory."
  echo "Copying uploads directory to public_html/wp-content..."
  cp -f "$UPLOADS_DIR" "$SCRIPT_DIR/public_html/wp-content/uploads"

  echo "Uploads directory moved successfully."
}

function run_all {
  move_html
  config_setup
  update_plugins
  update_themes
  copy_uploads
}

case "$1" in
  move_html) move_html ;;
  config_setup) config_setup ;;
  update_plugins) update_plugins ;;
  update_themes) update_themes ;;
  copy_uploads) copy_uploads ;;
  run_all) run_all ;;
  *) echo "Usage: $0 {move_html|config_setup|update_plugins|update_themes|copy_uploads|run_all}"
     exit 1 ;;
esac
