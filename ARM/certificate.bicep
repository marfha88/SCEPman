param subscriptionId string
param resourceGroup string
param certificateOrderName string
param distinguishedName string

@allowed([
  'StandardDomainValidatedSsl'
  'StandardDomainValidatedWildCardSsl'
])
param productType string = 'StandardDomainValidatedSsl'
param autoRenew bool

resource certificateOrder 'Microsoft.CertificateRegistration/certificateOrders@2022-03-01' = {
  name: certificateOrderName
  location: 'global'
  tags: {
  }
  properties: {
    autoRenew: autoRenew
    distinguishedName: distinguishedName
    validityInYears: 1
    productType: productType
  }
}