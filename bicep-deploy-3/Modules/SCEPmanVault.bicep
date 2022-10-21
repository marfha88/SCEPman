// Params
param location string
param keyVaultName string

param AppServicspid string


param tags object

@description('service principal ids that gets access to the keyvault')
param ids array = [
  AppServicspid
]

resource SCEPmanVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    accessPolicies: [for item in ids: {
      objectId: item
      tenantId: subscription().tenantId
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
    }]
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableSoftDelete: true
    enabledForDeployment: false
    enablePurgeProtection: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
  }
}

output keyVaultURL string = SCEPmanVault.properties.vaultUri
