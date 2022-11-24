
// Location of resources
param location string

// Tags
param tags object

// appServicePlan
param appServicePlanName string
param skuName string
param skuCapacity int
param autoscalesettings_asp_scepman_name string


// appService
param AppServiceName string
param certificateMasterAppServiceName string
param storageAccountName string
param license string
param keyVaultName string 
param orgName string
param caKeyType string

// Site configuration
var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var ArtifactsLocationCertMaster = uri(artifactsRepositoryUrl, 'dist-certmaster/CertMaster-Artifacts.zip')
var TableStorageEndpoint = 'https://${storageAccountName}.table.${environment().suffixes.storage}/'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/'

// Application Insight
param InstrumentationKey string
param ConnectionString string

// Certificate
param thumbprint string
param SCEPman_certificates_Hostname string

//######################################################### Here Resource creation begin test #####################################################
@description('SCEPmanAppServicesplan is created here')
resource SCEPmanAppServicesplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  kind: 'app'
  location: location
  name: appServicePlanName
  sku: {
    capacity: skuCapacity
    name: skuName
  }
}

@description('Autoscale is created here')
resource autoscalesettings_asp_scepman 'microsoft.insights/autoscalesettings@2021-05-01-preview' = {
  location: location
  name: autoscalesettings_asp_scepman_name
  properties: {
    enabled: true
    name: autoscalesettings_asp_scepman_name
    notifications: []
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles: [
      {
        capacity: {
          default: '1'
          maximum: '10'
          minimum: '1'
        }
        name: 'Auto created scale condition'
        rules: [
          {
            metricTrigger: {
              dimensions: []
              dividePerInstance: true
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: SCEPmanAppServicesplan.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 70
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
            }
            scaleAction: {
              cooldown: 'PT15M'
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
            }
          }
          {
            metricTrigger: {
              dimensions: []
              dividePerInstance: true
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: SCEPmanAppServicesplan.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: 35
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT20M'
            }
            scaleAction: {
              cooldown: 'PT30M'
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
            }
          }
        ]
      }
    ]
    targetResourceUri: SCEPmanAppServicesplan.id
  }
}


@description('SCEPmanAppService is created here')
resource SCEPmanAppService 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: AppServiceName
  properties: {
    serverFarmId: SCEPmanAppServicesplan.id
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
    hostNameSslStates: [
      {
        name: SCEPman_certificates_Hostname
        sslState: 'SniEnabled'
        thumbprint: thumbprint
        hostType: 'Standard'
      }
    ]
    httpsOnly: true
  }  
  tags: tags
}

@description('Certificate binding')
resource scepmanin_hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: SCEPmanAppService
  name: SCEPman_certificates_Hostname
  properties: {
    siteName: AppServiceName
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

@description('Health proble for SCEPman webapp')
resource SCEPmanAppServicehealth 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: SCEPmanAppService
  properties: {
    healthCheckPath: '/probe'
  }
}

@description('App config')
resource SCEPmanAppServiceconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppService
  properties: {
    //'AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledForWebsiteHostname': '${AppServiceName}.azurewebsites.net' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityPermissionLevel': '2' // fil in after powershell script
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    //'AppConfig:BaseUrl': SCEPman_certificates_Hostname // change after adding the Certificate and the new DNS name
    //'AppConfig:CertificateStorage:TableStorageEndpoint': TableStorageEndpoint // fil in after powershell script
    'AppConfig:CertMaster:URL': '${certificateMasterAppServiceName}.azurewebsites.net' // fil in after powershell script
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:KeyType': caKeyType
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${subscription().tenantId}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman // Change to storage account when/if you use update stratedy 
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey // Application insight
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString // Application insight
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0' // Application insight
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0' // Application insight
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2' // Application insight
    'BackUp:AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // The same as 'AppConfig:AuthConfig:ApplicationId' and also Application insight
    DiagnosticServices_EXTENSION_VERSION: '~3' // Application insight
    InstrumentationEngine_EXTENSION_VERSION: '~1' // Application insight
    SnapshotDebugger_EXTENSION_VERSION: '~1' // Application insight
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled' // Application insight
    XDT_MicrosoftApplicationInsights_Java: '1' // Application insight
    XDT_MicrosoftApplicationInsights_Mode: 'recommended' // Application insight
    XDT_MicrosoftApplicationInsights_NodeJS: '1' // Application insight
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled' // Application insight
   }
}

@description('certificateMasterAppService is created here')
resource SCEPmanAppServiceCm 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: certificateMasterAppServiceName
  properties: {    
    serverFarmId: SCEPmanAppServicesplan.id
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
  }
  tags: tags
}

@description('App config Certifaicate Master')
resource SCEPmanAppServiceconfigCm 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceCm
  properties: {
    /*'AppConfig:AuthConfig:ApplicationId': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityPermissionLevel': '2' // fil in after powershell script
    'AppConfig:AuthConfig:SCEPmanAPIScope': 'info from portal' // fil in after powershell script */
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:SCEPman:URL': SCEPman_certificates_Hostname
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationCertMaster 
   }
}


// ############################## Deployment slots ############################## 
resource SCEPmanDeploymentSlots 'Microsoft.Web/sites/slots@2021-03-01' = {
  name: '${AppServiceName}-pre-release'
  location: location
  kind: 'app'
  parent: SCEPmanAppService
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: SCEPmanAppServicesplan.id
  }
  tags: tags
}

@description('App config Deployment slot')
resource SCEPmanAppServiceSlotCeconfig 'Microsoft.Web/sites/slots/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanDeploymentSlots
  properties: {
    //'AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledForWebsiteHostname': '${AppServiceName}-pre-release.azurewebsites.net' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityPermissionLevel': '2' // fil in after powershell script
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': SCEPman_certificates_Hostname // change after adding the Certificate and the new DNS name
    //'AppConfig:CertificateStorage:TableStorageEndpoint': TableStorageEndpoint // fil in after powershell script
    //'AppConfig:CertMaster:URL': '${certificateMasterAppServiceName}.azurewebsites.net' // fil in after powershell script
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:KeyType': caKeyType
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${subscription().tenantId}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman // If you use update stratedy change this value to your storage account nad your artifact.
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey // Application insight
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString // Application insight
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0' // Application insight
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0' // Application insight
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2' // Application insight
    // 'BackUp:AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // The same as 'AppConfig:AuthConfig:ApplicationId' and also Application insight
    DiagnosticServices_EXTENSION_VERSION: '~3' // Application insight
    InstrumentationEngine_EXTENSION_VERSION: '~1' // Application insight
    SnapshotDebugger_EXTENSION_VERSION: '~1' // Application insight
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled' // Application insight
    XDT_MicrosoftApplicationInsights_Java: '1' // Application insight
    XDT_MicrosoftApplicationInsights_Mode: 'recommended' // Application insight
    XDT_MicrosoftApplicationInsights_NodeJS: '1' // Application insight
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled' // Application insight
   }
}

@description('Outputs for serviceprincipals')
output SCEPmanAppServicespid string = SCEPmanAppService.identity.principalId
output SCEPmanAppServicid string = SCEPmanAppService.id
output SCEPmanAppServiceCmspid string = SCEPmanAppServiceCm.identity.principalId
output SCEPmanAppServiceDeploymentSlotspid string = SCEPmanDeploymentSlots.identity.principalId






