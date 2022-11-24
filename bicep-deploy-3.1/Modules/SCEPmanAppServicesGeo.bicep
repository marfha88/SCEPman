
// Location of resources
param locationne string

// Tags
param tags object

// appServicePlan
param appServicePlanNameGeo string
param skuName string
param skuCapacity int
param autoscalesettings_asp_scepman_name string


// appService
param AppServiceNameGeo string
param certificateMasterAppServiceName string
param storageAccountName string
param license string
param keyVaultName string 
param orgName string
param caKeyType string

// Site configuration
var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var TableStorageEndpoint = 'https://${storageAccountName}.table.${environment().suffixes.storage}/'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/'

// Application Insight
param InstrumentationKey string
param ConnectionString string

// Certificate
param thumbprint string
param SCEPman_certificates_Hostname string

//######################################################### Here Resource creation begin test #####################################################
@description('SCEPmanAppServiceGeosplan is created here')
resource SCEPmanAppServiceGeosplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  kind: 'app'
  location: locationne
  name: appServicePlanNameGeo
  sku: {
    capacity: skuCapacity
    name: skuName
  }
}

@description('Autoscale is created here')
resource autoscalesettings_asp_scepman 'microsoft.insights/autoscalesettings@2021-05-01-preview' = {
  location: locationne
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
              metricResourceUri: SCEPmanAppServiceGeosplan.id
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
              metricResourceUri: SCEPmanAppServiceGeosplan.id
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
    targetResourceUri: SCEPmanAppServiceGeosplan.id
  }
}


@description('SCEPmanAppServiceGeo is created here')
resource SCEPmanAppServiceGeo 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: locationne
  name: AppServiceNameGeo
  properties: {
    serverFarmId: SCEPmanAppServiceGeosplan.id
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
  parent: SCEPmanAppServiceGeo
  name: SCEPman_certificates_Hostname
  properties: {
    siteName: AppServiceNameGeo
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

@description('Health proble for SCEPman webapp')
resource SCEPmanAppServiceGeohealth 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: SCEPmanAppServiceGeo
  properties: {
    healthCheckPath: '/probe'
  }
}

@description('App config')
resource SCEPmanAppServiceGeoconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceGeo
  properties: {
    //'AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledForWebsiteHostname': '${AppServiceNameGeo}.azurewebsites.net' // fil in after powershell script
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
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman 
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

// ############################## Deployment slots ############################## 
resource SCEPmanDeploymentSlots 'Microsoft.Web/sites/slots@2021-03-01' = {
  name: '${AppServiceNameGeo}-pre-release'
  location: locationne
  kind: 'app'
  parent: SCEPmanAppServiceGeo
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: SCEPmanAppServiceGeosplan.id
  }
  tags: tags
}

@description('App config Deployment slot')
resource SCEPmanAppServiceSlotCeconfigGeo 'Microsoft.Web/sites/slots/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanDeploymentSlots
  properties: {
    //'AppConfig:AuthConfig:ApplicationId': 'SCEPman-api client id' // fil in after powershell script
    //'AppConfig:AuthConfig:ManagedIdentityEnabledForWebsiteHostname': '${AppServiceNameGeo}-${AppServiceNameGeo}-pre-release.azurewebsites.net' // fil in after powershell script
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
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman // If you use update stratedy change this value to your storage account nad your artifact.
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

@description('Outputs for serviceprincipals')
output SCEPmanAppServiceGeospid string = SCEPmanAppServiceGeo.identity.principalId
output SCEPmanAppServicid string = SCEPmanAppServiceGeo.id
output SCEPmanAppServiceDeploymentSlotspid string = SCEPmanDeploymentSlots.identity.principalId






