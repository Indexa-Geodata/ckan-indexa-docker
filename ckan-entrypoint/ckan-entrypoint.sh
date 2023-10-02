#!/bin/bash

CKAN_INI=/etc/ckan/default/ckan.ini

#BASIC SETUP
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.site_id = ${CKAN_SITE_ID}"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.site_urL = ${CKAN_SITE_URL}"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "sqlalchemy.url = ${CKAN_SQL}"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.auth.create_user_via_web = false"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.locale_default = es"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.cors.origin_allow_all = true"

/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.auth.anon_create_dataset = false"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.auth.user_create_organizations = true"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.auth.user_delete_groups = true"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.auth.user_create_groups = true"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.max_resource_size = ${CKAN_MAX_FILE_SIZE}"
sed -i "s/recline.Backend.DataProxy.timeout = 10000;/recline.Backend.DataProxy.timeout = 180000;/g" /usr/lib/ckan/default/src/ckan/ckanext/reclineview/theme/public/recline_view.js

/usr/lib/ckan/default/bin/ckan -c ${CKAN_INI} db init

#datastore
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.datastore.write_url = postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DATABASE_DATASTORE}"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.datastore.read_url = postgresql://${DATASTORE_USER}:${DATASTORE_PASSWORD}@db/${POSTGRES_DATABASE_DATASTORE}"
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.storage_path = /var/lib/ckan/default"

#ckanext-xloader
/usr/lib/ckan/default/bin/pip install ckanext-xloader
/usr/lib/ckan/default/bin/pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt
/usr/lib/ckan/default/bin/pip install -U requests[security]
/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckanext.xloader.jobs_db.uri = ${CKAN_SQL}"

#ckanext-hierarchy
cd /usr/lib/ckan/default/src
if [ "$DEV" == true ]; then
    echo 'Installing ckanext-hierarchy in development mode'
else
    echo 'Installing ckanext-hierarchy in production mode'
    git clone https://github.com/enprava/ckanext-hierarchy.git
fi
/usr/lib/ckan/default/bin/pip install -e ckanext-hierarchy
/usr/lib/ckan/default/bin/pip install -r ckanext-hierarchy/requirements.txt

#ckanext-indexa
if [ "$INDEXA" == true ]; then
    bash /ckan-entrypoint/ckanext-indexa.sh
fi

#setting ckan.plugins
if [ "$INDEXA" == true ]; then
    /usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.plugins = stats text_view image_view resource_proxy recline_view webpage_view datastore xloader hierarchy_display hierarchy_form hierarchy_group_form indexa"
else
    /usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.plugins = stats text_view image_view resource_proxy recline_view webpage_view datastore xloader hierarchy_display hierarchy_form hierarchy_group_form"
fi

/usr/lib/ckan/default/bin/ckan config-tool "${CKAN_INI}" "ckan.views.default_views = image_view text_view recline_view webpage_view"

#CREATING USERS

/usr/lib/ckan/default/bin/ckan -c ${CKAN_INI} user add user=${CKAN_SYADMIN} email=${CKAN_SYADMIN_EMAIL} name=${CKAN_SYADMIN} password=${CKAN_SYADMIN_PASSWORD}

/usr/lib/ckan/default/bin/ckan -c ${CKAN_INI} user add user=${CKAN_USER} email=${CKAN_USER_EMAIL} name=${CKAN_USER} password=${CKAN_USER_PASSWORD}

/usr/lib/ckan/default/bin/ckan -c ${CKAN_INI} sysadmin add ${CKAN_SYADMIN}

#DEPLOY
/usr/lib/ckan/default/bin/ckan -c ${CKAN_INI} run --host 0.0.0.0
