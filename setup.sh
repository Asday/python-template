if [ $# -ne 0 ] || [ $# -ne 4 ]; then
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

virtualenv --python=PYTHON env
. env/bin/activate

# Check the project name is a valid identifier
if ! python -c "$PROJECT_NAME=0"; then
  echo 'Your project name must be a valid python identifier.'
  rm -rf env
  exit 2
fi

pip install -r requirements-dev.txt

# Replace placeholders
mv src project_name $PROJECT_NAME

sed "s|\(import \)project_name|\1$PROJECT_NAME|g" tests/test_main.py > _tmp
mv _tmp tests/test_main.py

sed "s|__YEAR__|`date +%Y`|g" LICENSE > _tmp
mv _tmp LICENCSE

sed "s|__AUTHOR__|$AUTHOR_NAME|g" LICENSE > _tmp
mv _tmp LICENCSE

sed "s|__PROJECT_NAME__|$PROJECT_NAME|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__DESCRIPTION__|$PROJECT_DESCRIPTION|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__AUTHOR__|$AUTHOR_NAME|g" setup.py > _tmp
mv _tmp setup.py

sed "s|__EMAIL__|$AUTHOR_EMAIL|g" setup.py > _tmp
mv _tmp setup.py

mv README-template.md README.md

rm setup.sh
rm -rf .git
git init
git add .
git commit -m "Initial commit."

echo "Done.  Run \`env/bin/activate\` and you're on your way."
