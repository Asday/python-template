#!/bin/bash
set -e

if [ $# -ne 0 ] && [ $# -ne 4 ]; then
  echo 'Usage:  ./setup.sh [project_name project_description author_name author_email]'
  exit 1
fi

if [ $# -eq 0 ]; then
  # Wizard mode
  read -p 'Project name:  ' PROJECT_NAME
  read -p 'Short project description:  ' PROJECT_DESCRIPTION
  read -p 'Your name:  ' AUTHOR_NAME
  read -p 'Your email:  ' AUTHOR_EMAIL
else
  PROJECT_NAME=$1
  PROJECT_DESCRIPTION=$2
  AUTHOR_NAME=$3
  AUTHOR_EMAIL=$4
fi

escape_apostrophes() {
  echo "$1" | sed "s|'|\\\\\\\'|g"
}

# Get the list of Python versions installed.
PYTHON_VERSIONS=$(find /usr/bin -executable -regex '.*python[0-9]+\.[0-9]+' -print)
LATEST_PYTHON_VERSION=$(echo "$PYTHON_VERSIONS" | sort | tail -n1)

virtualenv --python=$LATEST_PYTHON_VERSION env
. env/bin/activate

# Check the project name is a valid identifier
if ! python -c "$PROJECT_NAME=0"; then
  echo 'Your project name must be a valid python identifier.'
  rm -rf env
  exit 3
fi

# Add the python versions to the setup and tox.
./inject_python_versions.py

pip install -r requirements-dev.txt

# Replace placeholders
mv src/project_name src/$PROJECT_NAME

sed "s|\(import \)project_name|\1$PROJECT_NAME|g" tests/test_main.py > _tmp
mv _tmp tests/test_main.py

sed "s|__YEAR__|`date +%Y`|g" LICENSE > _tmp
mv _tmp LICENSE

sed "s|__AUTHOR__|$(escape_apostrophes "$AUTHOR_NAME")|g" LICENSE > _tmp
mv _tmp LICENSE

sed "s|__PROJECT_NAME__|$PROJECT_NAME|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__DESCRIPTION__|$(escape_apostrophes "$PROJECT_DESCRIPTION")|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__AUTHOR__|$(escape_apostrophes "$AUTHOR_NAME")|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__EMAIL__|$AUTHOR_EMAIL|g" setup.py > _tmp
mv _tmp setup.py

# Clean up.
mv README-template.md README.md

rm setup.sh
rm inject_python_versions.py
rm -rf .git
git init
git add .
git commit -m "Initial commit."

echo "Done.  Run \`. env/bin/activate\` and you're on your way."
