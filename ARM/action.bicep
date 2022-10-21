param SCEPman_actionGroups string = 'SCEPman Health probe'

resource SCEPman_actionGroups_resource 'microsoft.insights/actionGroups@2022-06-01' = {
  name: SCEPman_actionGroups
  location: 'Global'
  properties: {
    groupShortName: 'SCEPman Heal'
    enabled: true
    emailReceivers: [
      {
        name: 'SCEPman email notification_-EmailAction-'
        emailAddress: 'test@test.com'
        useCommonAlertSchema: false
      }
    ]
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}
