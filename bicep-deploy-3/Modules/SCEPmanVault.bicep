// Params
param location string
param keyVaultName string

param AppServicspid string


param tags object

@description('service principal ids that gets access to the keyvault')
param ids array = [
  AppServicspid
  '2d4f47d5-87ff-4092-9b9c-2ed588ca6abc' // IMPORTANT! This is the "Microsoft Azure App Service" Add it directly in the keyvault befor runing bicep Create!!!
  'ab12d451-c89f-41e4-9c70-6abe38f72fc9' // your objectid from Enterprise Application = add the service principle id that runs the Github Action.
  '57de4656-cc03-4872-826e-8fe5aa2f5f1b' // your objectid from App registration = add the service principle id that runs the Github Action.
  '8fd7d728-52e2-416f-a629-9dfab2545715' // This is my account
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
output keyVaultId string = SCEPmanVault.id

