@description('Specifies the name of the key vault.')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('IDs of SCEPman app service principal, whom will be assigned permissions to the KV')
param permittedPrincipalId string

@description('Resource Group')
param location string

@description('Tags to be assigned to the created resources')
param resourceTags object

var keys = [
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
var secrets = [
  'get'
  'list'
  'set'
  'delete'
  'recover'
  'backup'
  'restore'
]
var certificates = [
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

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  tags: resourceTags
  properties: {
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    enabledForDiskEncryption: false
    sku: {
      name: 'premium'
      family: 'A'
    }
    accessPolicies: [
      {
        objectId: permittedPrincipalId
        tenantId: subscription().tenantId
        permissions: {
          keys: keys
          secrets: secrets
          certificates: certificates
        }
      }
    ]
  }
}

output keyVaultURL string = keyVault.properties.vaultUri
