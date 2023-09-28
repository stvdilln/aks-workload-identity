import os
import time
import psycopg2 as pg
from datetime import datetime

from azure.keyvault.secrets import SecretClient
from token_credential import MyClientAssertionCredential

def main():
    # get environment variables to authenticate to the key vault
    azure_client_id = os.getenv('AZURE_CLIENT_ID', '')
    if not azure_client_id:
        raise Exception('AZURE_CLIENT_ID environment variable is not set: add label azure.workload.identity/use: "true"   to your pod spec')
    
    azure_tenant_id = os.getenv('AZURE_TENANT_ID', '')
    if not azure_tenant_id: 
        raise Exception('AZURE_TENANT_ID environment variable is not set')
    
    azure_authority_host = os.getenv('AZURE_AUTHORITY_HOST', '')
    if not azure_authority_host:
        raise Exception('AZURE_AUTHORITY_HOST environment variable is not set')
    
    azure_federated_token_file = os.getenv('AZURE_FEDERATED_TOKEN_FILE', '')
    if not azure_federated_token_file:
        raise Exception('AZURE_FEDERATED_TOKEN_FILE environment variable is not set')
    
    database = os.getenv('pg_database', 'test-db')
    host     = os.getenv('pg_host', '')
    if not host:
        raise Exception('pg_host environment variable is not set')
    
    db_user  = os.getenv('aks_workload_app1_user_name', '')  
    if not db_user:
        raise Exception('aks_workload_app1_user_name environment variable is not set (foo@domain.com)')
    
    keyvault_url = os.getenv('key_vault_uri', '')
    if not keyvault_url:
        raise Exception('key_vault_uri environment variable is not set (https://{vault-name}.vault.azure.net/)')
    secret_name = os.getenv('key_vault_secret_name', 'big-secret')
    
    # create a token credential object, which has a get_token method that returns a token
    token_credential = MyClientAssertionCredential(azure_client_id, azure_tenant_id, azure_authority_host, azure_federated_token_file)
    access_token = token_credential.get_token('https://graph.microsoft.com/.default').token
    #print('TOKEN {}'.format(access_token))

    # create a secret client with the token credential
    keyvault = SecretClient(vault_url=keyvault_url, credential=token_credential)
    secret = keyvault.get_secret(secret_name)
    print('successfully got secret, secret={}'.format(secret.value))

    # Now connect to Postgres DB 
    password = access_token = token_credential.get_token('https://ossrdbms-aad.database.windows.net/.default').token 

    print('database={}'.format(database))
    print('host={}'.format(host))
    print('db_user={}'.format(db_user))


    conn_string = "host={0} user={1} sslmode=prefer dbname={2} password={3}".format(host,db_user,database password)
    #print(conn_string)
    conn = pg.connect(conn_string)
    #print(conn)

    cursor = conn.cursor()
    test_data = 'Hello World at {0}'.format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    print(test_data); 

    cursor.execute("INSERT INTO my_table (test) VALUES (%s);", (test_data,))
    conn.commit()
    cursor.close()
    conn.close()


if __name__ == '__main__':
    main()

