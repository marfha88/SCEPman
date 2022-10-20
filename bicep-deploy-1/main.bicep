@description('Location for resources. For a manual deployment, we recommend the default value.')
param location string = resourceGroup().location
param locationne string = 'northeurope'

@description('Tenant, Subscription and Resource Groups')
param tenant string = 'c39d49f7-9eed-4307-b032-bb28f3cf9d79'
param rgScepman string = 'scepman-prod'

@description('Name of the Company or Organization used for the Certificate Subject')
@minLength(2)
param orgName string = 'Martin Company'

@description('Adds time to tags')
param utctime string = utcNow('yyyyMMddTHHmm')

@description('List of tags passed from main to modules')
param tags object = {
  deployment:  'bicep'
  createdby: 'Martin'
  SCEPmanVersion: '2.1.522'
  updatedTime: utctime
}

// Storage Account
@description('Choose a globally unique name for your storage account. Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.')
param storageAccountName string = 'scepmaninsa'

@description('Module parameters for storage accounts')
param sku string = 'Standard_GRS'

// License
@description('License Key for SCEPman')
param license string = 'Trial' // change to your license

// Key vault parameters
@description('Specifies the name of the Azure Key Vault. The name of a Key Vault must be globally unique and contain only DNS-compatible characters (letters, numbers, and hyphens).')
param keyVaultName string = 'kv-scepman-in'

// primary Web app and app service plan
@description('Primary AppService')
param appServicePlanName string = 'asp-scepman-in'
param skuName string = 'S1'
param skuCapacity int = 1
param autoscalesettings_asp_scepman_name string = 'asp-scepman-in-Autoscale'

@description('The SCEPman primary App Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param primaryAppServiceName string = 'as-scepman-in'

// Geo web app and app service plan
@description('Geo AppService')
param appServicePlanNameGeo string = 'asp-scepman-in-geo'
param autoscalesettings_asp_scepman_name_geo string = 'asp-scepman-in-Autoscale-geo'

@description('The SCEPman App geo Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param AppServiceNameGeo string = 'as-scepman-in-geo'

@description('The App Service for the component SCEPman Certificate Master. As it is part of the default FQDN, it must be globally unique and contain only DNS-compatible characters.')
param certificateMasterAppServiceName string = 'as-scepman-in-cm'

@description('Traffic Manager profile')
param trafficManagerProfiles_name string = 'tm-scepman-in'

@description('Application Insight')
param scepman_in_name string = 'ai-scepman-in'
param workspaces_itp_log_pwe_la_id string = '/subscriptions/39a9d242-811d-4456-a8c1-ab0e5c36d2fa/resourceGroups/itp-log-pwe-rg/providers/microsoft.operationalinsights/workspaces/itp-log-pwe-la'

@description('SCEPman Alarm and Action Group')
param SCEPman_actionGroups string = 'SCEPman Health probe'
param SCEPman_Health_check_alarm1 string = 'SCEPman Health check alarm Primary'
// param SCEPman_metricAlerts1 string = 'SCEPman Metric Alarm Primary'
param SCEPman_Health_check_alarm2 string = 'SCEPman Health check alarm Geo'
// param SCEPman_metricAlerts2 string = 'SCEPman Metric Alarm Geo'

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
    thumbprint: Certificate.outputs.thumbprint
    InstrumentationKey: SCEPmanAppServiceAi.outputs.InstrumentationKey
    ConnectionString: SCEPmanAppServiceAi.outputs.ConnectionString
  }
}
/*
module SCEPmanWebAppGeo 'Modules/SCEPmanAppServicesGeo.bicep' = {
  name: 'SCEPmanWebAppgeo'
  params: {
    locationne: locationne
    appServicePlanNameGeo: appServicePlanNameGeo
    AppServiceNameGeo: AppServiceNameGeo
    skuName: skuName
    skuCapacity: skuCapacity
    tenant: tenant
    storageAccountName: storageAccountName
    license: license
    keyVaultName: keyVaultName  
    orgName: orgName
    tags: tags
    autoscalesettings_asp_scepman_name_geo: autoscalesettings_asp_scepman_name_geo
    thumbprint: CertificateGeo.outputs.thumbprint
    InstrumentationKey: SCEPmanAppServiceAi.outputs.InstrumentationKey
    ConnectionString: SCEPmanAppServiceAi.outputs.ConnectionString
  }
}

@description('Wildcard cert for Innovation Norway')
module Certificate 'Modules/SCEPmanWildCardCert.bicep' = {
  name: 'in-wildcard-2022'
  params: {
    location: location
  }
}

@description('Wildcard cert for Innovation Norway Geo')
module CertificateGeo 'Modules/SCEPmanWildCardCertGeo.bicep' = {
  name: 'in-wildcard-2022-Geo'
  params: {
    locationne: locationne
  }
}
*/
@description('Storage account for scepman')
module StorageAccount  = {
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
  }
}


module SCEPmanVault 'Modules/SCEPmanVault.bicep' = {
  name: 'SCEPmanVault'
  params: {
    tenant: tenant
    keyVaultName: keyVaultName
    primaryAppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServicespid
    primaryAppServicSlotspid: SCEPmanWebApp.outputs.SCEPmanAppServiceSlotspid
    AppServiceGeospid: SCEPmanWebAppGeo.outputs.SCEPmanAppServiceGeospid
    AppServiceGeoSlotsspid: SCEPmanWebAppGeo.outputs.SCEPmanAppServiceSlotGeospid
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
/*
module rbac3 'Modules/RBACAppServiceGeo.bicep' = {
  name: 'rbac-geoAppService'
  scope:resourceGroup(rgScepman)
  params: {
    AppServiceGeospid: SCEPmanWebAppGeo.outputs.SCEPmanAppServiceGeospid
    roleid: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor 
  }
}
*/
/*

module SCEPmanTrafficManager 'Modules/SCEPmanTrafficManager.bicep' = {
  name: trafficManagerProfiles_name
  params: {
    trafficManagerProfiles_name: trafficManagerProfiles_name
    tags: tags
    primaryAppServicid: SCEPmanWebApp.outputs.SCEPmanAppServicid
    AppServicGeoid: SCEPmanWebAppGeo.outputs.SCEPmanAppServicGeoid
    location: location
    locationne: locationne
  }
  dependsOn: [
    SCEPmanWebApp
  ]
}
*/
module SCEPmanAppServiceAi 'Modules/SCEPmanAppServiceAi.bicep' = {
  name: scepman_in_name
  params: {
    scepman_in_name: scepman_in_name
    workspaceid: workspaces_itp_log_pwe_la_id
    location: location
  }  
}

module SCEPmanActionGroup 'Modules/SCEPmanActionGroup.bicep' = {
  name: 'SCEPmanActionGroup'
  params: {
    SCEPman_actionGroups: SCEPman_actionGroups
  }
}

module AlarmPrimaryAppService 'Modules/AlarmPrimaryAppService.bicep' = {
  name: 'SCEPman_Health_check_alarm1'
  params: {
    SCEPman_Health_check_alarm1: SCEPman_Health_check_alarm1
    SCEPman_ActionGroups_Id: SCEPmanActionGroup.outputs.ActionId
    primaryAppServicid: SCEPmanWebApp.outputs.SCEPmanAppServicid
  }
}

/*
module AlarmGeoAppService 'Modules/AlarmGeoAppService.bicep' = {
  name: 'SCEPman_Health_check_alarm2'
  params: {
    SCEPman_Health_check_alarm2: SCEPman_Health_check_alarm2
    SCEPman_ActionGroups_Id: SCEPmanActionGroup.outputs.ActionId
    AppServicGeoid: SCEPmanWebAppGeo.outputs.SCEPmanAppServicGeoid

  }
}
*/
