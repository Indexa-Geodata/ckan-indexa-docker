#!/bin/bash

cd /usr/lib/ckan/default/src
if [ "$DEV" == true ]; then
    echo 'DEV mode is enabled'
else
    echo 'DEV mode is disabled'
    rm -r ckanext-indexa
    git clone https://github.com/enprava/ckanext-indexa.git
fi

/usr/lib/ckan/default/bin/pip install -e ckanext-indexa
/usr/lib/ckan/default/bin/pip install -r ckanext-indexa/requirements.txt