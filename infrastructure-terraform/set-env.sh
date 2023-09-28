# This file shouild be sourced and not executed
# This file is used to create the env.sh file that is used to set the environment variables
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please Source this script 'source ./01-create-env-sh' and don't run it."
    exit 1
fi

export TF_VAR_pg_admin_user_principal_name=$(az ad signed-in-user show | jq -r '.userPrincipalName')