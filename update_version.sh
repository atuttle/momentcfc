#!/bin/bash

# Updates the version in moment.cfc and box.json.

# Usage Example (from git root): ./update_version.sh 1.1.15

if [ -z "$1" ]; then
  echo "Usage: $0 <new_version>"
  exit 1
fi

NEW_VERSION="$1"

# Update moment.cfc
sed -i "s/MOMENT\.CFC v[0-9]\+\.[0-9]\+\.[0-9]\+/MOMENT.CFC v$NEW_VERSION/" /home/kenric/GitHub/kenricashe/momentcfc/moment.cfc

# Update box.json
sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" /home/kenric/GitHub/kenricashe/momentcfc/box.json

echo "Updated to version $NEW_VERSION"
