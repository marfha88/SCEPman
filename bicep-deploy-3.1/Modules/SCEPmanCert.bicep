
param location string
param SCEPman_certificates__name string
param SCEPmanVaultId string = 'add this info so you in a later state can refernese this certificate' // if you dont add the resource id you can not referense thumprint
param certificatesecretname string = 'SCEPmanHTTPS/4ff85c50a728463b97082a907d0a3828' // you can find this info from the keyvault, the imported certificate and look at Current version.
param SCEPman_certificates_Hostname string

resource certificates_Scepman 'Microsoft.Web/certificates@2021-03-01' = {
  location: location
  name: SCEPman_certificates__name
  properties: {
    hostNames: [
      SCEPman_certificates_Hostname
    ]
    keyVaultId: SCEPmanVaultId
    keyVaultSecretName: certificatesecretname
  }
}

output thumbprint string = certificates_Scepman.properties.thumbprint
output Subject_Alternative_Name string = certificates_Scepman.properties.subjectName



