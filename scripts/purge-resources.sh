#!/bin/bash

# Check if user is logged in and wants to continue
# Echo notification working on subs
subscription=$(az account show --query "name" -o tsv)
echo "Working on subscription $subscription"

# Delete all Key Vaults
echo "the following Key Vaults will be deleted:"
az keyvault list-deleted --query "[].name" -o tsv
read -p "Do you want to continue? (y/n): " choice
if [[ $choice == "n" ]]; then
    exit 0
fi

deleted_keyvaults=$(az keyvault list-deleted --query "[].name" -o tsv)
if [[ -z "$deleted_keyvaults" ]]; then
    echo "No deleted Key Vaults found."
else
    echo "Purging the following Key Vaults:"
    echo "$deleted_keyvaults"
    for keyvault in $deleted_keyvaults
    do
        az keyvault purge --name "$keyvault" --no-wait
    done
fi


# Purge deleted cognitive services
echo "the following Cognitive Services will be deleted:"
az cognitiveservices account list-deleted --query "[].{name:name, location:location, id:id}" -o table
read -p "Do you want to continue? (y/n): " choice
if [[ $choice == "n" ]]; then
    exit 0
fi

items=$(az cognitiveservices account list-deleted --query "[].{name:name, location:location, id:id}" -o json)
count=$(echo "$items" | jq '. | length')

if [[ $count -eq 0 ]]; then
    echo "No deleted Cognitive Services found."
    exit 0
else
    for i in $(seq 0 $(($count - 1)))
    do
        # get the item
        objec=$(echo "$items" | jq ".[$i]")
        # echo $objec
        name=$(echo "$objec" | jq -r '.name')
        location=$(echo "$objec" | jq -r '.location')
        id=$(echo "$objec" | jq -r '.id')
        resource_group=$(echo "$id" | cut -d'/' -f9)
        echo deleting "$name" in "$location" in "$resource_group"
        az cognitiveservices account purge --name "$name" --location "$location" --resource-group "$resource_group" --verbose
        # az resource delete --ids /subscriptions/{subscriptionId}/providers/Microsoft.CognitiveServices/locations/{location}/resourceGroups/{resourceGroup}/deletedAccounts/{resourceName}
    done
fi
