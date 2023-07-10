#!/bin/bash

#BASIC SETUP
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.site_id = ${CKAN_SITE_ID}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.site_urL = ${CKAN_SITE_URL}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "sqlalchemy.url = ${CKAN_SQL}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.auth.create_user_via_web = false"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.locale_default = es"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.cors.origin_allow_all = True"

/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.auth.anon_create_dataset = true"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.auth.user_create_organizations = true"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.auth.user_delete_groups = true"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.max_resource_size = ${CKAN_MAX_FILE_SIZE}"
/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini db init

#datastore
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.datastore.write_url = postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DATABASE_DATASTORE}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.datastore.read_url = postgresql://${DATASTORE_USER}:${DATASTORE_PASSWORD}@db/${POSTGRES_DATABASE_DATASTORE}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.storage_path = /var/lib/ckan/default"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.storage_path = /var/lib/ckan/default"

#ckanext-xloader
/usr/lib/ckan/default/bin/pip install ckanext-xloader
/usr/lib/ckan/default/bin/pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt
/usr/lib/ckan/default/bin/pip install -U requests[security]
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckanext.xloader.jobs_db.uri = ${CKAN_SQL}"

# # #ckanext-geoview
# cd /usr/lib/ckan/default/src
# git clone https://github.com/ckan/ckanext-geoview.git
# /usr/lib/ckan/default/bin/pip install -e ckanext-geoview

#ckanext-hierarchy
cd /usr/lib/ckan/default/src
/usr/lib/ckan/default/bin/pip install -e "git+https://github.com/enprava/ckanext-hierarchy.git#egg=ckanext-hierarchy"
/usr/lib/ckan/default/bin/pip install -r ckanext-hierarchy/requirements.txt

#ckanext-indexa
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

#setting ckan.plugins

/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.plugins = stats text_view image_view resource_proxy recline_view webpage_view datastore xloader hierarchy_display hierarchy_form hierarchy_group_form indexa"

#CREATING USERS

/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini user add user=${CKAN_SYADMIN} email=${CKAN_SYADMIN_EMAIL} name=${CKAN_SYADMIN} password=${CKAN_SYADMIN_PASSWORD}

/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini user add user=${CKAN_USER} email=${CKAN_USER_EMAIL} name=${CKAN_USER} password=${CKAN_USER_PASSWORD}

/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini sysadmin add ${CKAN_SYADMIN}

/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini user remove ${CKAN_SITE_ID}

#DEPLOY
/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini run --host 0.0.0.0
