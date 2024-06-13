param name string
param location string
param sku string
param tags object

resource name_resource 'Microsoft.OperationalInsights/workspaces@2017-03-15-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
  }
}
