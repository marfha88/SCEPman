
param location string
param certificates_IN_Wildcard_2022_name string = 'in-wildcard-2022'
param vaults_hub_prod_shared_kv_externalid string = '/subscriptions/0563c2c3-2a39-4c80-bbaa-93196e049cd2/resourceGroups/hub-prod-shared-resources/providers/Microsoft.KeyVault/vaults/hub-prod-shared-kv'
param certificatesecretname string = 'IN-Wildcard-2022/bbbf374fe6784070bd1532556cbb077b'


resource certificates_IN_Wildcard_2022 'Microsoft.Web/certificates@2021-03-01' = {
  location: location
  name: certificates_IN_Wildcard_2022_name
  properties: {
    hostNames: [
      '*.innovasjonnorge.no'
      'innovasjonnorge.no'
    ]
    keyVaultId: vaults_hub_prod_shared_kv_externalid
    keyVaultSecretName: certificatesecretname
  }
}

output thumbprint string = certificates_IN_Wildcard_2022.properties.thumbprint


