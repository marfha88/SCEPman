# bicep-deploy1 and bicep-deploy2
Install-Module SCEPman -Scope CurrentUser -Force
Complete-SCEPmanInstallation -SCEPmanAppServiceName 'yourscepmanwebapp' -SearchAllSubscriptions 6>&1 # bicep-deploy1 and bicep-deploy2

# bicep-deploy3.0 and bicep-deploy3.1 
Install-Module SCEPman -Scope CurrentUser -Force
Complete-SCEPmanInstallation -SubscriptionId "yourscepmansubscription" -SCEPmanResourceGroup "yourscepmanrg" -SCEPmanAppServiceName "yourscepmanwebapp" -CertMasterAppServiceName "yourscepmanwebapp-cm" 6>&1 -DeploymentSlotName 'yourscepmanwebapp-pre-release'
Complete-SCEPmanInstallation -SubscriptionId "yourscepmansubscription" -SCEPmanResourceGroup "yourscepmanrg" -SCEPmanAppServiceName "yourscepmanwebapp-geo" -CertMasterAppServiceName "yourscepmanwebapp-cm" 6>&1 -DeploymentSlotName 'yourscepmanwebapp-geo-pre-release'
