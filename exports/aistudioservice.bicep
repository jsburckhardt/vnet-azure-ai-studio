param accounts_aistudioais02_name string = 'aistudioais02'

resource accounts_aistudioais02_name_resource 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: accounts_aistudioais02_name
  location: 'eastus'
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    customSubDomainName: accounts_aistudioais02_name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
}

resource accounts_aistudioais02_name_Microsoft_Default 'Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview' = {
  parent: accounts_aistudioais02_name_resource
  name: 'Microsoft.Default'
  properties: {
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
}
