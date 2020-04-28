export PATH="$PWD/node_modules/.bin/:$PATH"
# npm i
# npm audit fix

# Python vEnv Setup
pip install pip-tools
cd languages/python/validate/requirements
pip-compile --generate-hashes --upgrade prod.in
pip-compile --generate-hashes --upgrade dev.in

pip-sync prod.txt dev.txt

SOURCE_DATE_EPOCH=$(date +%s) shiv --compressed --python '/usr/bin/env python3' --console-script hello_world --output-file hello .
