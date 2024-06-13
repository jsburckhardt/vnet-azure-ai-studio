param nameAI string = 'aistudioai01'
param type string = 'web'
param regionId string = 'eastus'
param tagsArray object = {}
param requestSource string = 'IbizaAIExtension'
param nameLA string = 'aistudiola01'
param sku string = 'pergb2018'

resource appinsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: nameAI
  location: regionI
  kind: 'web'
  tags: tagsArray
  properties: {
    Application_Type: type
    Flow_Type: 'Redfield'
    Request_Source: requestSource
    WorkspaceResourceId: newWorkspaceTemplate.id
  }
}

resource newWorkspaceTemplate 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: nameLA
  location: regionId
  tags: tagsArray
  properties: {
    sku: {
      name: sku
    }
  }
}
