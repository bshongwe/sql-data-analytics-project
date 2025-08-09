@description('SQL Server name')
param sqlServerName string = 'sql-analytics-${uniqueString(resourceGroup().id)}'

@description('Database name')
param databaseName string = 'DataWarehouseAnalytics'

@description('Environment suffix (blue/green)')
param environmentSuffix string = 'blue'

@description('Storage account name')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('SQL Administrator login')
param sqlAdminLogin string

@secure()
@description('SQL Administrator password')
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: '${sqlServerName}-${environmentSuffix}'
  location: resourceGroup().location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: 'ag-sql-analytics'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: []
    frontendIPConfigurations: []
    frontendPorts: []
    backendAddressPools: [
      {
        name: 'pool-blue'
        properties: {
          backendAddresses: []
        }
      }
      {
        name: 'pool-green'
        properties: {
          backendAddresses: []
        }
      }
    ]
    httpListeners: []
    requestRoutingRules: []
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: resourceGroup().location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource csvContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'csv-container'
  properties: {
    publicAccess: 'None'
  }
}

output sqlServerName string = sqlServer.name
output databaseName string = sqlDatabase.name
output storageAccountName string = storageAccount.name