param scepman_in_name string
param workspaceid string
param location string 

resource SCEPmanprimaryAppServiceAi 'microsoft.insights/components@2020-02-02' = {
  name: scepman_in_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtensionEnablementBlade'
    RetentionInDays: 90
    WorkspaceResourceId: workspaceid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output InstrumentationKey string = SCEPmanprimaryAppServiceAi.properties.InstrumentationKey
output ConnectionString string = SCEPmanprimaryAppServiceAi.properties.ConnectionString

