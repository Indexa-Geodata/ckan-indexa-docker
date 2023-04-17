#!/bin/bash
#
#BASIC SETUP
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.site_id = Indexa Geodata"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.site_urL = ${CKA_SITE_URL}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "sqlalchemy.url = ${CKAN_SQLALCHEMY_URL}"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.auth.create_user_via_web = false"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.locale_default = es"

/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini db init

#PLUGINS
#
#datastore
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.datastore.write_url = postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@db/$POSTGRES_DATABASE_CKAN"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.datastore.read_url = postgresql://$DATASTORE_USER:$DATASTORE_PASSWORD@db/$POSTGRES_DATABASE_DATASTORE"
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.storage_path = /var/lib/ckan/default"

#ckanext-xloader
/usr/lib/ckan/default/bin/pip install ckanext-xloader
/usr/lib/ckan/default/bin/pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt
/usr/lib/ckan/default/bin/pip install -U requests[security]
/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckanext.xloader.jobs_db.uri = ${CKAN_SQLALCHEMY_URL}"

#ckanext-hierarchy
cd /usr/lib/ckan/default/src
/usr/lib/ckan/default/bin/pip install -e "git+https://github.com/enprava/ckanext-hierarchy.git#egg=ckanext-hierarchy"
/usr/lib/ckan/default/bin/pip install -r ckanext-hierarchy/requirements.txt

#ckanext-indexa
cd /usr/lib/ckan/default/src
git clone https://github.com/enprava/ckanext-indexa.git
/usr/lib/ckan/default/bin/pip install -e ckanext-indexa
/usr/lib/ckan/default/bin/pip install -r ckanext-indexa/requirements.txt

#setting ckan.plugins

/usr/lib/ckan/default/bin/ckan config-tool "/etc/ckan/default/ckan.ini" "ckan.plugins = stats text_view image_view recline_view datastore xloader hierarchy_display hierarchy_form hierarchy_group_form indexa"

#DEPLOY
/usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini run --host 0.0.0.0
