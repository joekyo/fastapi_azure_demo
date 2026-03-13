@description('Web app name')
param appName string = 'my-fastapi-app-prod'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App Service Plan SKU')
@allowed(['F1', 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v3', 'P2v3'])
param sku string = 'B1'

@description('Python runtime version')
param pythonVersion string = 'PYTHON|3.11'

@description('Startup command')
param startupCommand string = 'startup.sh'

// ── App Service Plan ──────────────────────────────────────
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'plan-${appName}'
  location: location
  kind: 'linux'
  sku: {
    name: sku
  }
  properties: {
    reserved: true // required for Linux
  }
}

// ── Web App ───────────────────────────────────────────────
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: pythonVersion
      appCommandLine: startupCommand
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
    }
    httpsOnly: true
  }
}

// ── Diagnostic Logs (filesystem) ─────────────────────────
resource webAppLogs 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Verbose'
      }
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInDays: 7
        retentionInMb: 35
      }
    }
  }
}
