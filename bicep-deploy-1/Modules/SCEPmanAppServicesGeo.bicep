
// Location of resources
param locationne string

// Tags
param tags object

// appServicePlan
param appServicePlanNameGeo string
param skuName string
param skuCapacity int
param autoscalesettings_asp_scepman_name_geo string

// appService
param AppServiceNameGeo string
param tenant string
param storageAccountName string
param license string
param keyVaultName string 
param orgName string

// Site configuration
var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var TableStorageEndpoint = 'https://${storageAccountName}.table.${environment().suffixes.storage}'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'

// Certificate
param thumbprint string

// Application Insight
param InstrumentationKey string
param ConnectionString string

//######################################################### Here Resource creation begin test #####################################################
@description('SCEPmanAppServicesplan is created here')
resource SCEPmanAppServicesplanGeo 'Microsoft.Web/serverfarms@2021-03-01' = {
  kind: 'app'
  location: locationne
  name: appServicePlanNameGeo
  sku: {
    capacity: skuCapacity
    name: skuName
  }
}

@description('Autoscale is created here')
resource autoscalesettings_asp_scepman_Geo 'microsoft.insights/autoscalesettings@2021-05-01-preview' = {
  location: locationne
  name: autoscalesettings_asp_scepman_name_geo
  properties: {
    enabled: true
    name: autoscalesettings_asp_scepman_name_geo
    notifications: []
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles: [
      {
        capacity: {
          default: '2'
          maximum: '10'
          minimum: '2'
        }
        name: 'Auto created scale condition'
        rules: [
          {
            metricTrigger: {
              dimensions: []
              dividePerInstance: true
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: SCEPmanAppServicesplanGeo.id
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
              metricResourceUri: SCEPmanAppServicesplanGeo.id
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
    targetResourceUri: SCEPmanAppServicesplanGeo.id
  }
}


@description('AppServiceGeo is created here')
resource SCEPmanAppServiceGeo 'Microsoft.Web/sites@2021-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: locationne
  name: AppServiceNameGeo
  properties: {
    serverFarmId: SCEPmanAppServicesplanGeo.id
    enabled: true    
    customDomainVerificationId: 'BCF8C29E756BCF6CFD26CFA7C1B77BA277F90F8BA71E5EB690CA56BCBBC95E68'
    clientCertMode: 'Required'
    hostNameSslStates: [
      {
        name: 'scepman.innovasjonnorge.no'
        sslState: 'SniEnabled'
        thumbprint: thumbprint
        hostType: 'Standard'
      }
    ]           
  }  
  tags: tags
}

@description('Certificate binding')
resource scepmanin_hostNameBindingGeo 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: SCEPmanAppServiceGeo
  name: 'scepman.innovasjonnorge.no'
  properties: {
    siteName: AppServiceNameGeo
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

@description('App config')
resource SCEPmanAppServiceconfigGeo 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceGeo
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': 'https://scepman.innovasjonnorge.no/'
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${tenant}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/scepman-artifacts/Artifacts.zip'
    'AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1653549498'
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: '~1'
    SnapshotDebugger_EXTENSION_VERSION: '~1'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    XDT_MicrosoftApplicationInsights_Java: '1'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_NodeJS: '1'
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
   }
}

@description('Health proble for SCEPman webapp')
resource SCEPmanAppServicehealthGeo 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: SCEPmanAppServiceGeo
  properties: {
    healthCheckPath: '/probe'
  }
}

//                                             Deployment slots
resource SCEPmanDeploymentSlotsGeo 'Microsoft.Web/sites/slots@2021-03-01' = {
  name: '${AppServiceNameGeo}-pre-release'
  location: locationne
  kind: 'app'
  parent: SCEPmanAppServiceGeo
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: SCEPmanAppServicesplanGeo.id
  }
  tags: tags
}

@description('App config Deployment slot')
resource SCEPmanAppServiceSlotConfigGeo 'Microsoft.Web/sites/slots/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanDeploymentSlotsGeo
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': 'https://scepman.innovasjonnorge.no/' 
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${tenant}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman //'https://scepmaninsa.blob.core.windows.net/scepman-artifacts/Artifacts.zip'
    'AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1653655135'
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    'BackUp:AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: '~1'
    SnapshotDebugger_EXTENSION_VERSION: '~1'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    XDT_MicrosoftApplicationInsights_Java: '1'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_NodeJS: '1'
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
   }
}


@description('Outputs for serviceprincipals')
output SCEPmanAppServiceGeospid string = SCEPmanAppServiceGeo.identity.principalId
output SCEPmanAppServicGeoid string = SCEPmanAppServiceGeo.id
output SCEPmanAppServiceSlotGeospid string = SCEPmanDeploymentSlotsGeo.identity.principalId



