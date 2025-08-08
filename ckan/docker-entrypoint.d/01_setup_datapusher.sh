#!/bin/bash

if [[ $CKAN__PLUGINS == *"datapusher"* ]]; then
   # Datapusher settings have been configured in the .env file
   # Set API token if necessary
   if [ -z "$CKAN__DATAPUSHER__API_TOKEN" ] ; then
      # Determine which user will own the DataPusher token
      SYSADMIN_NAME=${CKAN_SYSADMIN_NAME:-ckan_admin}

      # Ensure the sysadmin user exists (it may not if the name was customized)
      if ! ckan -c "$CKAN_INI" user show "$SYSADMIN_NAME" >/dev/null 2>&1; then
         ckan -c "$CKAN_INI" user add "$SYSADMIN_NAME" \
            password="${CKAN_SYSADMIN_PASSWORD}" \
            email="${CKAN_SYSADMIN_EMAIL}"
         ckan -c "$CKAN_INI" sysadmin add "$SYSADMIN_NAME"
      fi

      echo "Set up ckan.datapusher.api_token in the CKAN config file"
      ckan config-tool $CKAN_INI "ckan.datapusher.api_token=$(ckan -c $CKAN_INI user token add $SYSADMIN_NAME datapusher | tail -n 1 | tr -d '\t')"
   fi
else
   echo "Not configuring DataPusher"
fi
