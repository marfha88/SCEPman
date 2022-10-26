
param location string
param SCEPman_certificates__name string
param SCEPmanVaultId string = '/subscriptions/347c07c5-65f2-47dc-bb87-f3456120269a/resourceGroups/scepman-prod/providers/Microsoft.KeyVault/vaults/kv-scepman-martin9' // if you dont add the resource id you can not referense thumprint
param certificatesecretname string = 'SCEPmanHTTPS/4ff85c50a728463b97082a907d0a3828' // you can find this info from the keyvault, the imported certificate and look at Current version.


resource certificates_Scepman 'Microsoft.Web/certificates@2021-03-01' = {
  location: location
  name: SCEPman_certificates__name
  properties: {
    hostNames: [
      'scepman.fahlbeck.no'
    ]
    keyVaultId: SCEPmanVaultId
    keyVaultSecretName: certificatesecretname
  }
}

output thumbprint string = certificates_Scepman.properties.thumbprint
output Subject_Alternative_Name string = certificates_Scepman.properties.subjectName



