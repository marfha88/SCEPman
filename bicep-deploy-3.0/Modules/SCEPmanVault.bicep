// Params
param location string
param keyVaultName string

param AppServicspid string

param tags object

@description('service principal ids that gets access to the keyvault')
param ids array = [
  AppServicspid
  'your objectid from Enterprise Application' // your objectid from Enterprise Application = add the service principle id that runs the Github Action.
  'objectid from App registration' // your objectid from App registration = add the service principle id that runs the Github Action.
  'github action spid' // Use your account or service principle for the github action
]

param MicrosoftAzureAppService string = '2d4f47d5-87ff-4092-9b9c-2ed588ca6abc' // IMPORTANT! This is the "Microsoft Azure App Service" Add it directly in the keyvault befor runing bicep Create!!!


@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
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

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'get'
  'list'
  'set'
  'delete'
  'recover'
  'backup'
  'restore'
]

@description('Specifies the permissions to certificates in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param certificatesPermissions array = [
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

param secretsPermissionsAzureAppService array = [
  'get'
]

param certificatesPermissionsAzureAppService array = [
  'get'
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
        certificates: certificatesPermissions
        keys: keysPermissions
        secrets: secretsPermissions     
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

resource keyVaultPoliciesAppservice 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: SCEPmanVault
  properties: {
    accessPolicies: [
      {
        objectId: MicrosoftAzureAppService
        tenantId: subscription().tenantId
        permissions: {
          certificates: certificatesPermissionsAzureAppService
          secrets: secretsPermissionsAzureAppService
        }        
      }
    ]
  }
}

output keyVaultURL string = SCEPmanVault.properties.vaultUri
output keyVaultId string = SCEPmanVault.id

