#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Updating phase release for: ${package_name}"
if [ -n "$service_account_json_key_path" ] ; then
    echo "Downloading credentials from remote file"
    wget -O "${SCRIPT_DIR}/credentials.json" "${service_account_json_key_path}"
elif [ -n "$service_account_json_local_path" ] ; then
     echo "Using credentials stored locally"
     cp "$service_account_json_local_path" "${SCRIPT_DIR}/credentials.json"
else
    echo "Using local content credentials"
    echo "$service_account_json_key_content" > "${SCRIPT_DIR}/credentials.json"
fi

echo "Creating menv"
python3 -m venv env
source env/bin/activate

echo "Installing pip requirements"
pip install urllib3 pyparsing==3.1.4 google-api-python-client==2.86.0 oauth2client

echo "Running: ${SCRIPT_DIR}/rollout_update.py ${package_name} ${SCRIPT_DIR}/credentials.json ${track} ${force_rollout}"
python "${SCRIPT_DIR}/rollout_update.py" "${package_name}" "${SCRIPT_DIR}/credentials.json" "${track}" "${force_rollout}"

echo "Cleanup"
deactivate
rm "${SCRIPT_DIR}/credentials.json"
