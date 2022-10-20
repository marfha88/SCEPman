// Storage Account Parameters
/*
@minLength(3)
@maxLength(5)
@description('Abbreviation of Team Name which is responsible for the deployment of this storage account (same paramater as in resource group)')
param PrefixTeamName string

@minLength(3)
@maxLength(5)
@description('Abbreviation of the solution or function which should be part of the storage account name (same paramater as in resource group)')
param PrefixFunction string

*/

@description('Location for the storageAccount')
param resourceGroupLocation string = (resourceGroup().location)

@description('List of tags passed from input')
param tags object

@minLength(3)
@maxLength(24)
@description('Name of the storage account to create')
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Which sku should be used depends on what type of availabailty is needed and what cost it genereates. The deafult is the cheapest.')
param sku string = 'Standard_LRS'

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
@description('What type of storage it is')
param kind string = 'StorageV2'

param defaultToOAuthAuthentication bool = true
param allowBlobPublicAccess bool = false
param allowCrossTenantReplication bool = false
param allowSharedKeyAccess bool = false
param minimumTlsVersion string = 'TLS1_2'
param networkAclsBypass string = 'AzureServices'
param networkFWDefaultAction string = 'Deny'
param publicNetworkAccess string = 'Enabled'

resource symbolicname 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: resourceGroupLocation
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    //defaultToOAuthAuthentication: defaultToOAuthAuthentication
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: false
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkFWDefaultAction
    }
    //publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
  }
}
