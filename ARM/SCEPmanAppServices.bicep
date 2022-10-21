
@description('Name of the App Service Plan to be created')
param AppServicePlanName string

@description('Name of App Service to be created')
param appServiceName string

@description('Name of second App Service to be created')
param appServiceName2 string

@description('Resource Group')
param location string

@description('Tags to be assigned to the created resources')
param resourceTags object

resource AppServicePlan 'Microsoft.Web/serverfarms@2021-02-01'{
  name: AppServicePlanName
  location: location
  tags: resourceTags
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  properties: {
    name: AppServicePlanName
    workerSize: 1
    numberOfWorkers: 1
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AppServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: false
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
  }
}

resource appService2 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName2
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AppServicePlan.id
    httpsOnly: true
    alwaysOn: true
    use32BitWorkerProcess: false
    ftpsState: 'Disabled'
    clientAffinityEnabled: true
  }
}


output scepmanPrincipalID string = appService.identity.principalId
output certmasterPrincipalID string = appService2.identity.principalId

