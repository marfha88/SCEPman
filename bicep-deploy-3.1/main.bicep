@description('Location for resources. For a manual deployment, we recommend the default value.')
param location string = resourceGroup().location
param locationne string = 'northeurope'

@description('Name of the Company or Organization used for the Certificate Subject')
param orgName string = 'Martin Company'

@description('Adds time to tags')
param utctime string = utcNow('yyyyMMddTHHmm')

@description('List of tags passed from main to modules')
param tags object = {
  deployment:  'bicep'
  createdby: 'company'
  SCEPmanVersion: '2.2.631'
  updatedTime: utctime
}

@description('Use a one line word with out a space')
param company string = 'company'

@description('Choose a globally unique name for your storage account. Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.')
param storageAccountName string = 'stgscepman${company}'

@description('License Key for SCEPman')
param license string = 'trial' // change to your license

@description('Specifies the name of the Azure Key Vault. The name of a Key Vault must be globally unique and contain only DNS-compatible characters (letters, numbers, and hyphens).')
param keyVaultName string = 'kv-scepman-${company}'

@description(' AppService')
param appServicePlanName string = 'asp-scepman-${company}'
param skuName string = 'S1'
param skuCapacity int = 1
param autoscalesettings_asp_scepman_name string = 'asp-scepman-Autoscale'


@description('The SCEPman  App Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param AppServiceName string = 'as-scepman-${company}'

@description('The App Service for the component SCEPman Certificate Master. As it is part of the default FQDN, it must be globally unique and contain only DNS-compatible characters.')
param certificateMasterAppServiceName string = 'as-scepman-${company}-cm'

@description('When generating the SCEPman CA certificate, which kind of key pair shall be created? RSA is a software-protected RSA key; RSA-HSM is HSM-protected.')
@allowed([
  'RSA'
  'RSA-HSM'
])
param caKeyType string = 'RSA-HSM'

@description('SCEPman Alarm and Action Group')
param SCEPman_actionGroups string = 'SCEPman-Health-probe'
param SCEPman_Health_check_alarm string = 'SCEPman-Health-check-alerting'

@description('Application Insight')
param SCEPman_ai_name string = 'ai-scepman'
// Use an exsisting log analytics workspace or create a new.
param workspace_id string = '/subscriptions/000/resourcegroups/defaultresourcegroup-weu/providers/microsoft.operationalinsights/workspaces/defaultworkspace-000-weu'

@description('SCEPman HTTPS certificates')
param SCEPman_certificates__name string = 'SCEPmanHTTPS'
param SCEPman_certificates_Hostname string = 'scepman.fahlbeck.no'
var SCEPman_certificates__nameGeo = '${SCEPman_certificates__name}Geo'

// Geo web app and app service plan
@description('Geo AppService')
param appServicePlanNameGeo string = 'asp-scepman-${company}-geo'
param autoscalesettings_asp_scepman_name_Geo string = 'asp-scepman-${company}-geo'
@description('The SCEPman App geo Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param AppServiceNameGeo string = 'as-scepman-${company}-geo'

@description('Traffic Manager profile')
param trafficManagerProfiles_name string = 'tm-scepman-${company}'

module SCEPmanTrafficManager 'Modules/SCEPmanTrafficManager.bicep' = {
  name: trafficManagerProfiles_name
  params: {
    AppServiceName: AppServiceName
    AppServiceNameGeo: AppServiceNameGeo
    location: location
    locationne: locationne
    SCEPmanAppServicespid: SCEPmanWebApp.outputs.SCEPmanAppServicid
    SCEPmanAppServiceGeospid: SCEPmanWebAppGeo.outputs.SCEPmanAppServicid    
    tags: tags
    trafficManagerProfiles_name: trafficManagerProfiles_name
  }
}

@description('Here Resource creation begin')
module SCEPmanWebApp 'Modules/SCEPmanAppServices.bicep' = {
  name: 'SCEPmanWebApp'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    AppServiceName: AppServiceName
    skuName: skuName
    skuCapacity: skuCapacity
    certificateMasterAppServiceName: certificateMasterAppServiceName
    storageAccountName: storageAccountName
    license: license
    keyVaultName: keyVaultName
    orgName: orgName
    tags: tags
    caKeyType: caKeyType
    autoscalesettings_asp_scepman_name: autoscalesettings_asp_scepman_name
    InstrumentationKey: SCEPmanAppServiceAi.outputs.InstrumentationKey
    ConnectionString: SCEPmanAppServiceAi.outputs.ConnectionString
    thumbprint: SCEPman_HTTPS_Certificate.outputs.thumbprint
    SCEPman_certificates_Hostname: SCEPman_certificates_Hostname
  }
}

@description('Here Resource creation begin')
module SCEPmanWebAppGeo 'Modules/SCEPmanAppServicesGeo.bicep' = {
  name: 'SCEPmanWebAppGeo'
  params: {
    AppServiceNameGeo: AppServiceNameGeo
    appServicePlanNameGeo: appServicePlanNameGeo
    autoscalesettings_asp_scepman_name: autoscalesettings_asp_scepman_name_Geo
    caKeyType: skuName
    certificateMasterAppServiceName: certificateMasterAppServiceName
    ConnectionString: SCEPmanAppServiceAi.outputs.ConnectionString
    InstrumentationKey: SCEPmanAppServiceAi.outputs.InstrumentationKey
    keyVaultName: keyVaultName
    license: license
    locationne: locationne
    orgName: orgName
    SCEPman_certificates_Hostname: SCEPman_certificates_Hostname
    skuCapacity: skuCapacity
    skuName: skuName
    storageAccountName: storageAccountName
    tags: tags
    thumbprint: SCEPman_HTTPS_CertificateGeo.outputs.thumbprint
  }
}

@description('Storage account for scepman')
module StorageAccount 'Modules/SCEPmanStorageaccount.bicep' = {
  name: storageAccountName
  params: {
    location: location
    resourceTags: tags
    StorageAccountName: storageAccountName
    tableContributorPrincipals: [
      SCEPmanWebApp.outputs.SCEPmanAppServicespid
      SCEPmanWebApp.outputs.SCEPmanAppServiceCmspid
      SCEPmanWebAppGeo.outputs.SCEPmanAppServiceGeospid
      SCEPmanWebApp.outputs.SCEPmanAppServiceDeploymentSlotspid
      SCEPmanWebAppGeo.outputs.SCEPmanAppServiceDeploymentSlotspid
    ]
  }
}

@description('Key Vault for scepman')
module SCEPmanVault 'Modules/SCEPmanVault.bicep' = {
  name: keyVaultName
  params: {
    keyVaultName: keyVaultName
    AppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServicespid
    AppServicGEOspid: SCEPmanWebAppGeo.outputs.SCEPmanAppServiceGeospid
    SCEPmanAppServiceDeploymentSlotspid: SCEPmanWebApp.outputs.SCEPmanAppServiceDeploymentSlotspid
    SCEPmanAppServiceGeoDeploymentSlotspid: SCEPmanWebAppGeo.outputs.SCEPmanAppServiceDeploymentSlotspid
    location: location
    tags: tags
  }
}

module SCEPmanActionGroup 'Modules/SCEPmanActionGroup.bicep' = {
  name: 'SCEPmanActionGroup'
  params: {
    SCEPman_actionGroups: SCEPman_actionGroups
  }
}

module AlarmPrimaryAppService 'Modules/AlarmAppService.bicep' = {
  name: SCEPman_Health_check_alarm
  params: {
    SCEPman_Health_check_alarm: SCEPman_Health_check_alarm
    SCEPman_ActionGroups_Id: SCEPmanActionGroup.outputs.ActionId
    AppServicid: SCEPmanWebApp.outputs.SCEPmanAppServicid
  }
}

module SCEPmanAppServiceAi 'Modules/SCEPmanAppServiceAi.bicep' = {
  name: SCEPman_ai_name
  params: {
    SCEPman_ai_name: SCEPman_ai_name
    workspaceid: workspace_id
    location: location
  }  
}

module SCEPman_HTTPS_Certificate 'Modules/SCEPmanCert.bicep' = {
  name: SCEPman_certificates__name
  params: {
    location: location
    SCEPman_certificates__name: SCEPman_certificates__name
    SCEPman_certificates_Hostname: SCEPman_certificates_Hostname
  }
}

module SCEPman_HTTPS_CertificateGeo 'Modules/SCEPmanCertGeo.bicep' = {
  name: SCEPman_certificates__nameGeo
  params: {
    locationne: locationne
    SCEPman_certificates__name: SCEPman_certificates__nameGeo
    SCEPman_certificates_Hostname: SCEPman_certificates_Hostname
  }
}
