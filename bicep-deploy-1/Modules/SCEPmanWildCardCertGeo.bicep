
param locationne string 
param certificates_IN_Wildcard_2022_name_Geo string = 'in-wildcard-2022-Geo'
param vaults_hub_prod_shared_kv_externalid string = '/subscriptions/0563c2c3-2a39-4c80-bbaa-93196e049cd2/resourceGroups/hub-prod-shared-resources/providers/Microsoft.KeyVault/vaults/hub-prod-shared-kv'
param certificatesecretname string = 'IN-Wildcard-2022/bbbf374fe6784070bd1532556cbb077b'


resource certificates_IN_Wildcard_2022_Geo 'Microsoft.Web/certificates@2021-02-01' = {
  name: certificates_IN_Wildcard_2022_name_Geo
  location: locationne
  properties: {
    hostNames: [
      '*.innovasjonnorge.no'
      'innovasjonnorge.no'
    ]
    keyVaultId: vaults_hub_prod_shared_kv_externalid
    keyVaultSecretName: certificatesecretname
  }
}

output thumbprint string = certificates_IN_Wildcard_2022_Geo.properties.thumbprint


