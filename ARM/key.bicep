param vaults_kv_scepman_martin9_name string = 'kv-scepman-martin9'

resource vaults_kv_scepman_martin9_name_resource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaults_kv_scepman_martin9_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    createdby: 'Martin'
    SCEPmanVersion: '2.2.631'
    updatedTime: '20221026T0727'
  }
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
    accessPolicies: [
      {
        tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
        objectId: 'ac43446b-2bd9-4893-ac11-814bceb4be8f'
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
      }
      {
        tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
        objectId: '8fd7d728-52e2-416f-a629-9dfab2545715'
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
      }
      {
        tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
        objectId: '2d4f47d5-87ff-4092-9b9c-2ed588ca6abc'
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
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    vaultUri: 'https://${vaults_kv_scepman_martin9_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource vaults_kv_scepman_martin9_name_SCEPmanHTTPS 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: vaults_kv_scepman_martin9_name_resource
  name: 'SCEPmanHTTPS'
  location: 'westeurope'
  properties: {
    attributes: {
      enabled: true
      nbf: 1666656000
      exp: 1674518399
    }
  }
}

resource vaults_kv_scepman_martin9_name_SCEPman_Root_CA_V1 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: vaults_kv_scepman_martin9_name_resource
  name: 'SCEPman-Root-CA-V1'
  location: 'westeurope'
  properties: {
    attributes: {
      enabled: true
      nbf: 1666345843
      exp: 1981965643
    }
  }
}

resource Microsoft_KeyVault_vaults_secrets_vaults_kv_scepman_martin9_name_SCEPmanHTTPS 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: vaults_kv_scepman_martin9_name_resource
  name: 'SCEPmanHTTPS'
  location: 'westeurope'
  properties: {
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1666656000
      exp: 1674518399
    }
  }
}

resource Microsoft_KeyVault_vaults_secrets_vaults_kv_scepman_martin9_name_SCEPman_Root_CA_V1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: vaults_kv_scepman_martin9_name_resource
  name: 'SCEPman-Root-CA-V1'
  location: 'westeurope'
  properties: {
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1666345843
      exp: 1981965643
    }
  }
}