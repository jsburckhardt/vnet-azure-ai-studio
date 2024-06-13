az network private-endpoint create \
    --resource-group aistudio-pep \
    --name aistudiows01pep \
    --subnet "/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio/subnets/peps" \
    --private-connection-resource-id "/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio/providers/Microsoft.MachineLearningServices/workspaces/aistudio01" \
    --group-id amlworkspace \
    --connection-name workspace \
    -l eastus



# Add privatelink.api.azureml.ms
az network private-dns zone create -g aistudio-vnet --name 'privatelink.api.azureml.ms'
az network private-dns link vnet create -g aistudio-vnet --zone-name 'privatelink.api.azureml.ms' --name linkzoneandvnet --virtual-network vnetaistudio --registration-enabled false
az network private-endpoint dns-zone-group create -g aistudio-vnet --endpoint-name aistudiows01pep --name myzonegroup --private-dns-zone 'privatelink.api.azureml.ms' --zone-name 'privatelink.api.azureml.ms'

# Add privatelink.notebooks.azure.net
az network private-dns zone create -g aistudio-vnet --name 'privatelink.notebooks.azure.net'

az network private-dns link vnet create -g aistudio-vnet --zone-name 'privatelink.notebooks.azure.net' --name <link-name> --virtual-network <vnet-name> --registration-enabled false

az network private-endpoint dns-zone-group add -g aistudio-vnet --endpoint-name aistudiows01pep --name myzonegroup --private-dns-zone 'privatelink.notebooks.azure.net' --zone-name 'privatelink.notebooks.azure.net'
