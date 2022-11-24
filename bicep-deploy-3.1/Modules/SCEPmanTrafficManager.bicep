param trafficManagerProfiles_name string
param tags object
param AppServiceName string
param AppServiceNameGeo string

param SCEPmanAppServicespid string
param location string
param locationne string
param SCEPmanAppServiceGeospid string

resource trafficManagerProfiles_resource 'Microsoft.Network/trafficManagerProfiles@2018-04-01' = {
  location: 'global'
  name: trafficManagerProfiles_name
  properties: {
    dnsConfig: {
      relativeName: trafficManagerProfiles_name
      ttl: 30
    }
    endpoints: [
      {
        name: 'as-scepman'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          endpointMonitorStatus: 'Online'
          targetResourceId: SCEPmanAppServicespid
          target: '${AppServiceName}.azurewebsites.net/' 
          weight: 1
          priority: 1
          endpointLocation: location
        }
      }
      {
        name: 'as-scepman-geo'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          endpointMonitorStatus: 'Online'
          targetResourceId: SCEPmanAppServiceGeospid
          target: '${AppServiceNameGeo}.azurewebsites.net/'
          weight: 1
          priority: 2
          endpointLocation: locationne
        }
      }
    ]
    monitorConfig: {
      intervalInSeconds: 10
      path: '/probe'
      port: 443
      profileMonitorStatus: 'Online'
      protocol: 'HTTPS'
      timeoutInSeconds: 5
      toleratedNumberOfFailures: 3
    }
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    trafficViewEnrollmentStatus: 'Disabled'
  }
  tags: tags
}
