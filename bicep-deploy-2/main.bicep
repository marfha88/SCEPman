@description('Location for all resources. For a manual deployment, we recommend the default value.')
param location string = resourceGroup().location

@description('Tenant, Subscription and Resource Groups')
param tenant string = '89c966d0-fc62-4a30-b104-cfcba0b97b07'
param rgScepman string = 'core-scepman-prod'

@description('Name of the Company or Organization used for the Certificate Subject')
@minLength(2)
param orgName string = 'Innovation Norway'

@description('Adds time to tags')
param utctime string = utcNow('yyyyMMddTHHmm')

@description('List of tags passed from main to modules')
param tags object = {
  contributor: 'contributor'
  costcenter:  '173'
  environment: 'prod'
  owner:       'Azure Core'
  deployment:  'bicep'
  system:      'system'
  createdby: 'martin.fahlbeck@innovasjonnorge.no'
  timetolive: 'Indefinately'
  workinghours: '24/7'
  datecreated: '27.04.2021'
  lastreview:  utctime
}

// Storage Account
@description('Choose a globally unique name for your storage account. Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.')
param storageAccountName string = 'scepmanmfsa'

@description('Module parameters for storage accounts')
param sku string = 'Standard_GRS'

// License
@description('License Key for SCEPman')
param license string = 'trial'

// Key vault parameters
@description('Specifies the name of the Azure Key Vault. The name of a Key Vault must be globally unique and contain only DNS-compatible characters (letters, numbers, and hyphens).')
param keyVaultName string = 'kv-scepman-inmf'

// Web app and app service plan
@description('AppServiceName')
param appServicePlanName string = 'asp-scepman-inmf'
param skuName string = 'S1'
param skuCapacity int = 1
param autoscalesettings_asp_scepman_name string = 'asp-scepman-in-Autoscale'

@description('The SCEPman App Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param primaryAppServiceName string = 'as-scepman-inmf'

@description('The App Service for the component SCEPman Certificate Master. As it is part of the default FQDN, it must be globally unique and contain only DNS-compatible characters.')
param certificateMasterAppServiceName string = 'as-scepman-in-cmmf'

// Here Resource creation begin test
module SCEPmanWebApp 'Modules/SCEPmanAppServices.bicep' = {
  name: 'SCEPmanWebApp'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    primaryAppServiceName: primaryAppServiceName
    skuName: skuName
    skuCapacity: skuCapacity
    certificateMasterAppServiceName: certificateMasterAppServiceName
    tenant: tenant
    storageAccountName: storageAccountName
    license: license
    keyVaultName: keyVaultName  
    orgName: orgName
    tags: tags
    autoscalesettings_asp_scepman_name: autoscalesettings_asp_scepman_name  
  }
}

// test
@description('Storage account for scepman')
module StorageAccount 'br/CoreModules:storageaccount:0.2' = {
  name: 'SCEPmanStorageAccount'
  params: {
    storageAccountName: storageAccountName
    sku: sku
    resourceGroupLocation: location
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Enabled'
    tags: tags
    allowBlobPublicAccess: true
    networkFWDefaultAction: 'Allow'
    Env: 'nmf'
    PrefixFunction: 'pma'
    PrefixTeamName: 'sce'
  }
}


module SCEPmanVault 'Modules/SCEPmanVault.bicep' = {
  name: 'SCEPmanVault'
  params: {
    tenant: tenant
    keyVaultName: keyVaultName
    primaryAppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServicespid
    location: location
    tags: tags
  }
}

module rbac1 'Modules/RBACprimaryAppService.bicep' = {
  name: 'rbac-primaryAppService'
  scope:resourceGroup(rgScepman)
  params: {
    primaryAppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServicespid
    roleid: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor 
  }
}

module rbac2 'Modules/RBACprimaryAppServiceCm.bicep' = {
  name: 'rbac-primaryAppServiceCm'
  scope:resourceGroup(rgScepman)
  params: {
    primaryAppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServiceCmspid
    roleid: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor 
  }
}



