@description('SQL Server name')
param sqlServerName string = 'sql-analytics-${uniqueString(resourceGroup().id)}'

@description('Database name')
param databaseName string = 'DataWarehouseAnalytics'

@description('Environment suffix (blue/green)')
param environmentSuffix string = 'blue'

@description('Storage account name')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Alert email addresses')
param alertEmailAddresses array = ['admin@yourdomain.com']

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
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'SQL Admins'
      sid: '00000000-0000-0000-0000-000000000000' // Replace with actual Azure AD group Object ID
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    retentionDays: 90
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    storageEndpoint: storageAccount.properties.primaryEndpoints.blob
    storageAccountAccessKey: storageAccount.listKeys().keys[0].value
  }
}

resource sqlServerSecurityAlertPolicy 'Microsoft.Sql/servers/securityAlertPolicies@2022-05-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    emailAddresses: alertEmailAddresses
    emailAccountAdmins: true
    retentionDays: 90
    disabledAlerts: []
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
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20220101S'
    }
    gatewayIPConfigurations: []
    frontendIPConfigurations: []
    frontendPorts: [
      {
        name: 'port-443'
        properties: {
          port: 443
        }
      }
    ]
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
    zoneRedundant: true
  }
}

resource sqlDatabaseAudit 'Microsoft.Sql/servers/databases/auditingSettings@2022-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    state: 'Enabled'
    retentionDays: 90
  }
}

resource sqlDatabaseSecurityAlertPolicy 'Microsoft.Sql/servers/databases/securityAlertPolicies@2022-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    state: 'Enabled'
    emailAddresses: alertEmailAddresses
    emailAccountAdmins: true
    retentionDays: 90
    disabledAlerts: []
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: take(toLower(replace(replace(replace('${storageAccountName}${environmentSuffix}', '-', ''), '_', ''), ' ', '')), 24)
  location: resourceGroup().location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
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