param primaryAppServicspid string
// param workspaceResourceId string
param roleid string

@description('This is the built-in Storage Table Data Contributor role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-table-data-contributor')
resource roledefid 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleid
}

@description('Role assignment for Storage Table Data Contributor on Resource Group')
resource roleAssignment1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, primaryAppServicspid, roledefid.id)
  properties: {
    roleDefinitionId: roledefid.id
    principalId: primaryAppServicspid
    principalType: 'ServicePrincipal'
  }
}
