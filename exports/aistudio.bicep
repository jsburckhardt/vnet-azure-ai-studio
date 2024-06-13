param workspaces_aistudio01_name string = 'aistudio01'
param storageAccounts_aistudiosa01_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-storage/providers/Microsoft.Storage/storageAccounts/aistudiosa01'
param vaults_aistudiokv01_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-kv/providers/Microsoft.KeyVault/vaults/aistudiokv01'
param components_aistudioai01_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-appinsights/providers/Microsoft.Insights/components/aistudioai01'
param accounts_aistudioais02_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-service/providers/Microsoft.CognitiveServices/accounts/aistudioais02'
param registries_aistudioacr01_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-aca/providers/Microsoft.ContainerRegistry/registries/aistudioacr01'

resource workspaces_aistudio01_name_resource 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: workspaces_aistudio01_name
  location: 'eastus'
  tags: {
    __SYSTEM__AzureOpenAI_aistudioais02_aoai: '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-service/providers/Microsoft.CognitiveServices/accounts/aistudioais02'
    __SYSTEM__AIServices_aistudioais02: '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-service/providers/Microsoft.CognitiveServices/accounts/aistudioais02'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Aistudio01'
    storageAccount: storageAccounts_aistudiosa01_externalid
    keyVault: vaults_aistudiokv01_externalid
    applicationInsights: components_aistudioai01_externalid
    hbiWorkspace: false
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
      outboundRules: {
        Connection_aistudioais02_aoai_account: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: accounts_aistudioais02_externalid
            subresourceTarget: 'account'
            sparkEnabled: false
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'UserDefined'
        }
        __SYS_PE_aistudio01_amlworkspace_309563cc: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: workspaces_aistudio01_name_resource.id
            subresourceTarget: 'amlworkspace'
            sparkEnabled: true
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'Required'
        }
        __SYS_PE_aistudiosa01_file_2422a0a4: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: storageAccounts_aistudiosa01_externalid
            subresourceTarget: 'file'
            sparkEnabled: true
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'Required'
        }
        __SYS_PE_aistudioacr01_registry_202923a7: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: registries_aistudioacr01_externalid
            subresourceTarget: 'registry'
            sparkEnabled: false
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'Required'
        }
        __SYS_PE_aistudiosa01_blob_2422a0a4: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: storageAccounts_aistudiosa01_externalid
            subresourceTarget: 'blob'
            sparkEnabled: true
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'Required'
        }
        __SYS_PE_aistudiokv01_vault_1ee64290: {
          type: 'PrivateEndpoint'
          destination: {
            serviceResourceId: vaults_aistudiokv01_externalid
            subresourceTarget: 'vault'
            sparkEnabled: false
            sparkStatus: 'Inactive'
          }
          status: 'Inactive'
          category: 'Required'
        }
      }
      status: {
        status: 'Inactive'
        sparkReady: false
      }
    }
    containerRegistry: registries_aistudioacr01_externalid
    publicNetworkAccess: 'Disabled'
    ipAllowlist: []
    workspaceHubConfig: {
      defaultWorkspaceResourceGroup: '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio'
    }
    enableDataIsolation: true
    systemDatastoresAuthMode: 'accesskey'
  }
}

resource workspaces_aistudio01_name_aistudioais02 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/aistudioais02'
  properties: {
    authType: 'ApiKey'
    category: 'AIServices'
    target: 'https://aistudioais02.openai.azure.com/'
    isSharedToAll: true
    sharedUserList: []
    metadata: {
      ApiType: 'Azure'
      ResourceId: accounts_aistudioais02_externalid
      ApiVersion: '2023-07-01-preview'
      DeploymentApiVersion: '2023-10-01-preview'
    }
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_aistudioais02_aoai 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/aistudioais02_aoai'
  properties: {
    authType: 'ApiKey'
    category: 'AzureOpenAI'
    target: 'https://aistudioais02.openai.azure.com/'
    isSharedToAll: true
    sharedUserList: []
    metadata: {
      ApiType: 'Azure'
      ResourceId: accounts_aistudioais02_externalid
      ApiVersion: '2023-07-01-preview'
      DeploymentApiVersion: '2023-10-01-preview'
    }
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_SYS_PE_workspaces_aistudio01_name_amlworkspace_309563cc 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/__SYS_PE_${workspaces_aistudio01_name}_amlworkspace_309563cc'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: workspaces_aistudio01_name_resource.id
      subresourceTarget: 'amlworkspace'
      sparkEnabled: true
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'Required'
  }
}

resource workspaces_aistudio01_name_SYS_PE_aistudioacr01_registry_202923a7 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/__SYS_PE_aistudioacr01_registry_202923a7'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: registries_aistudioacr01_externalid
      subresourceTarget: 'registry'
      sparkEnabled: false
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'Required'
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_SYS_PE_aistudiokv01_vault_1ee64290 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/__SYS_PE_aistudiokv01_vault_1ee64290'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: vaults_aistudiokv01_externalid
      subresourceTarget: 'vault'
      sparkEnabled: false
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'Required'
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_SYS_PE_aistudiosa01_blob_2422a0a4 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/__SYS_PE_aistudiosa01_blob_2422a0a4'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: storageAccounts_aistudiosa01_externalid
      subresourceTarget: 'blob'
      sparkEnabled: true
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'Required'
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_SYS_PE_aistudiosa01_file_2422a0a4 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/__SYS_PE_aistudiosa01_file_2422a0a4'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: storageAccounts_aistudiosa01_externalid
      subresourceTarget: 'file'
      sparkEnabled: true
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'Required'
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_Connection_aistudioais02_aoai_account 'Microsoft.MachineLearningServices/workspaces/outboundRules@2024-04-01-preview' = {
  name: '${workspaces_aistudio01_name}/Connection_aistudioais02_aoai_account'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: accounts_aistudioais02_externalid
      subresourceTarget: 'account'
      sparkEnabled: false
      sparkStatus: 'Inactive'
    }
    status: 'Inactive'
    category: 'UserDefined'
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}

resource workspaces_aistudio01_name_aistudioais02_aoai_Microsoft_Default 'Microsoft.MachineLearningServices/workspaces/connections/raiPolicies@2024-04-01-preview' = {
  parent: workspaces_aistudio01_name_aistudioais02_aoai
  name: 'Microsoft.Default'
  properties: {
    type: 'SystemManaged'
    mode: 'Blocking'
    contentFilters: [
      {
        name: 'Hate'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Hate'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Sexual'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Sexual'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Violence'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Violence'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
      {
        name: 'Selfharm'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
      {
        name: 'Selfharm'
        allowedContentLevel: 'Medium'
        blocking: true
        enabled: true
        source: 'Completion'
      }
    ]
  }
  dependsOn: [
    workspaces_aistudio01_name_resource
  ]
}
