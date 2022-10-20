// Params
param location string
param keyVaultName string
param tenant string
param primaryAppServicspid string
param tags object

resource SCEPmanVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  location: location
  name: keyVaultName
  properties: {
    accessPolicies: [
      {
        objectId: primaryAppServicspid
        permissions: {
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'unwrapKey'
            'verify'
            'sign'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
        tenantId: tenant
      }
    ]
    enableSoftDelete: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant
//    vaultUri: 'https://${keyVaultName}.vault.azure.net/'
  }
  tags: tags
}

// output keyVaultURL string = SCEPmanVault.properties.vaultUri
