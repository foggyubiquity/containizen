pip install pip-tools
pip-sync requirements/prod.txt requirements/dev.txt

# export APP=$(grep "name=" ./setup.py | cut -d"\"" -f2 | cut -d"'" -f2)
pip install -r requirements/prod.txt --upgrade --target pkgs
SOURCE_DATE_EPOCH=$(date +%s) shiv --compressed --python '/usr/bin/env python3' --console-script main --output-file containizen --site-packages pkgs .
