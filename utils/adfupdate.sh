#!/bin/bash

# checkout adf-update branch
git checkout -b adf-objects-update

# update local adf files 
## update key vault linked service defintion
akv_baseUrl=$(tf -chdir=.cloud/dev/ output -json | jq '.akv_baseUrl.value')
jq --argjson v0 "$akv_baseUrl" '.typeProperties.baseUrl = $v0' adf/linkedService/AzureKeyVault1.json | tee adf/linkedService/AzureKeyVault1.json

## update aml linked service definition
appId=$(tf -chdir=.cloud/dev/ output -json | jq '.appId.value')
mlWorkspaceName=$(tf -chdir=.cloud/dev/ output -json | jq '.mlWorkspaceName.value')
resourceGroupName=$(tf -chdir=.cloud/dev/ output -json | jq '.resourceGroupName.value')
subscriptionId=$(tf -chdir=.cloud/dev/ output -json | jq '.subscriptionId.value')
tenant=$(tf -chdir=.cloud/dev/ output -json | jq '.tenant.value')
jq --argjson v1 "$appId" \
--argjson v2 "$mlWorkspaceName" \
--argjson v3 "$resourceGroupName" \
--argjson v4 "$subscriptionId" \
--argjson v5 "$tenant" \
'.properties.typeProperties.appId = $v1 | .properties.typeProperties.mlWorkspaceName = $v2 | .properties.typeProperties.resourceGroupName = $v3 | .properties.typeProperties.subscriptionId = $v4 | .properties.typeProperties.tenant = $v5' adf/linkedService/AzureMLService1.json | tee adf/linkedService/AzureMLService1.json

## update adf
adfName=$(tf -chdir=.cloud/dev/ output -json | jq '.adf_name.value')
location=$(tf -chdir=.cloud/dev/ output -json | jq '.location.value')
env=$(tf -chdir=.cloud/dev/ output -json | jq '.env.value')
jq --argjson v1 "$adfName" \
--argjson v2 "$env" \
--argjson v3 "$location" \
'.name = $v1 | .properties.globalParameters.environment.value = $v2 | .location = $v3 ' adf/factory/template.json | tee adf/factory/${adfName//\"}.json

rm adf/factory/template.json

# commit and push changes to branch
git add .
git commit "automated adf files updates"
git push -u origin adf-objects-update

echo "Changes made to local files and pushed to remote repository on branch 'adf-objects-update'"
echo "Navigate to your repo and merge the changes to the main branch."