param SCEPman_Health_check_alarm2 string
param AppServicGeoid string
param SCEPman_ActionGroups_Id string

resource SCEPman_Health_check_alarm_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: SCEPman_Health_check_alarm2
  location: 'global'
  properties: {
    severity: 0
    enabled: true
    scopes: [
      AppServicGeoid
    ]
    evaluationFrequency: 'PT5M'
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
    actions: [
      {
        actionGroupId: SCEPman_ActionGroups_Id
      }
    ]
  }
}

