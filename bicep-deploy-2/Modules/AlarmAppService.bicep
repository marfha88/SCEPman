param SCEPman_Health_check_alarm string
param AppServicid string
param SCEPman_ActionGroups_Id string

resource SCEPman_Health_check_alarm_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: SCEPman_Health_check_alarm
  location: 'global'
  properties: {
    severity: 0
    enabled: true
    scopes: [
      AppServicid
    ]
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          alertSensitivity: 'High'
          failingPeriods: {
            numberOfEvaluationPeriods: 4
            minFailingPeriodsToAlert: 4
          }
          name: 'Metric1'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'HealthCheckStatus'
          operator: 'GreaterOrLessThan'
          timeAggregation: 'Average'
          criterionType: 'DynamicThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Web/sites'
    targetResourceRegion: 'westeurope'
    actions: [
      {
        actionGroupId: SCEPman_ActionGroups_Id
        webHookProperties: {
        }
      }
    ]
  }
}


