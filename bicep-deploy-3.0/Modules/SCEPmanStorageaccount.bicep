@description('Name of the storage account')
param StorageAccountName string

@description('Location where the resources will be deployed')
param location string

@description('Tags to be assigned to the created resources')
param resourceTags object

@description('IDs of Principals that shall receive table contributor rights on the storage account')
param tableContributorPrincipals array

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: StorageAccountName
  location: location
  tags: resourceTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    isHnsEnabled: false
    isNfsV3Enabled: false
    minimumTlsVersion: 'TLS1_2'
    routingPreference: {
      publishInternetEndpoints: false
      publishMicrosoftEndpoints: false
      routingChoice: 'MicrosoftRouting'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource roleAssignment_sa_tableContributorPrincipals 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in tableContributorPrincipals: {
  scope: StorageAccount
  name: guid('roleAssignment-sa-${item}')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: item
  }
}]

output storageAccountTableUrl string = StorageAccount.properties.primaryEndpoints.table
