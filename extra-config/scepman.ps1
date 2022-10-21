Install-Module SCEPman -Scope CurrentUser -Force
Complete-SCEPmanInstallation -SCEPmanAppServiceName 'yourscepmanwebapp' -SearchAllSubscriptions 6>&1

##### If you have many subscription you need to target the subscriptions as SCEPman powershell module cant handle to many subscriptions ################
# Complete-SCEPmanInstallation -SubscriptionId "yourscepmansubscription" -SCEPmanResourceGroup "yourscepmanrg" -SCEPmanAppServiceName "yourscepmanwebapp" -CertMasterAppServiceName "yourscepmanwebapp-cm" 6>&1 -DeploymentSlotName 'yourscepmanwebapp-inpre-release'

# Complete-SCEPmanInstallation -SubscriptionId "yourscepmansubscription" -SCEPmanResourceGroup "yourscepmanrg" -SCEPmanAppServiceName "yourscepmanwebapp-geo" 6>&1 -DeploymentSlotName 'yourscepmanwebapp-geo-pre-release'

