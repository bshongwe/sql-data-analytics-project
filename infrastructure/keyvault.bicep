@description('Key Vault name')
param keyVaultName string = 'kv-analytics-${uniqueString(resourceGroup().id)}'

@description('SQL Administrator password')
@secure()
param sqlAdminPassword string

@description('Storage account connection string')
@secure()
param storageConnectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource sqlPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'sql-admin-password'
  properties: {
    value: sqlAdminPassword
    contentType: 'text/plain'
    attributes: {
      exp: dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
    }
  }
}

resource storageSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'storage-connection-string'
  properties: {
    value: storageConnectionString
    contentType: 'text/plain'
    attributes: {
      exp: dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
    }
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id