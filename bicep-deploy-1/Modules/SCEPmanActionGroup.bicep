param SCEPman_actionGroups string

resource SCEPman_actionGroups_resource 'microsoft.insights/actionGroups@2021-09-01' = {
  name: SCEPman_actionGroups
  location: 'Global'
  properties: {
    groupShortName: 'SCEP Health'
    enabled: true
    emailReceivers: [
      {
        name: 'SCEPman email notification1_-EmailAction-'
        emailAddress: 'team-itplatform@innovationnorway.onmicrosoft.com' // Old insupport@innovationnorway.no
        useCommonAlertSchema: false
      }
      {
        name: 'SCEPman email notification2_-EmailAction-'
        emailAddress: 'inn.alerts@s2grupo.es'
        useCommonAlertSchema: false
      }
    ]
  }
}

output ActionId string = SCEPman_actionGroups_resource.id

