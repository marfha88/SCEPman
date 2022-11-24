param SCEPman_actionGroups string

resource SCEPman_actionGroups_resource 'microsoft.insights/actionGroups@2021-09-01' = {
  name: SCEPman_actionGroups
  location: 'Global'
  properties: {
    groupShortName: 'SCEPman Heal' // Can not be longer then 12 characters
    enabled: true
    emailReceivers: [
      {
        name: 'SCEPman email notification_-EmailAction-'
        emailAddress: 'test@test.com' // Change this when scepmman is in prod.
        useCommonAlertSchema: false
      }
    ]
  }
}

output ActionId string = SCEPman_actionGroups_resource.id

