IDENTITY_TOKEN=$(cat $AZURE_FEDERATED_TOKEN_FILE)

output=$(curl -s  --location --request GET "$AZURE_AUTHORITY_HOST/$AZURE_TENANT_ID/oauth2/v2.0/token" \
--form 'grant_type="client_credentials"' \
--form 'client_id="'$AZURE_CLIENT_ID'"' \
--form 'scope="https://ossrdbms-aad.database.windows.net/.default"' \
--form 'client_assertion_type="urn:ietf:params:oauth:client-assertion-type:jwt-bearer"' \
--form 'client_assertion="'$IDENTITY_TOKEN'"' )

export PGPASSWORD=$(echo $output | jq -r '.access_token')


psql -h $pg_host --user $aks_workload_app1_user_name $pg_database