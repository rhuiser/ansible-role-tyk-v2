#!/bin/bash
# Usage ./init-tyk-gw.sh DASHBOARD_HOSTNAME

LOCALIP=$1
INITIAL_USER=john.smith
PASS="Welcome123"

echo "Creating Organisation"
ORGDATA=$(curl --silent --header "admin-auth: 12345" --header "Content-Type:application/json" --data '{"owner_name": "Default Org.","owner_slug": "default", "cname_enabled": true, "cname": ""}' http://$LOCALIP:3000/admin/organisations 2>&1)
#echo $ORGDATA
ORGID=$(echo $ORGDATA | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Meta"]')
echo "ORGID: $ORGID" 

echo "Adding new user"
USER_DATA=$(curl --silent --header "admin-auth: 12345" --header "Content-Type:application/json" --data '{"first_name": "John","last_name": "Smith","email_address": "'$INITIAL_USER'@default.com","password":"'$PASS'", "active": true,"org_id": "'$ORGID'"}' http://$LOCALIP:3000/admin/users 2>&1)
#echo $USER_DATA
USER_CODE=$(echo $USER_DATA | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Message"]')
echo "USER AUTH: $USER_CODE" 

USER_LIST=$(curl --silent --header "authorization: $USER_CODE" http://$LOCALIP:3000/api/users 2>&1)
#echo $USER_LIST

USER_ID=$(echo $USER_LIST | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["users"][0]["id"]')
echo "NEW ID: $USER_ID"

echo "Setting password"
OK=$(curl --silent --header "authorization: $USER_CODE" --header "Content-Type:application/json" http://$LOCALIP:3000/api/users/$USER_ID/actions/reset --data '{"new_password":"'$PASS'"}')



