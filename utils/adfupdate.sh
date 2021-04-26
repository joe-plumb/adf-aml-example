#!/bin/bash

# checkout adf-update branch
git checkout -b adf-objects-update

# update local adf files 
## update key vault linked service defintion
akv_baseUrl=$(terraform -chdir=.cloud/dev/ output -json | jq '.akv_baseUrl.value')
jq --argjson v0 "$akv_baseUrl" '.typeProperties.baseUrl = $v0' utils/templates/AzureKeyVault1-template.json >| adf/linkedService/AzureKeyVault1.json

## update aml linked service definition
appId=$(terraform -chdir=.cloud/dev/ output -json | jq '.appId.value')
mlWorkspaceName=$(terraform -chdir=.cloud/dev/ output -json | jq '.mlWorkspaceName.value')
resourceGroupName=$(terraform -chdir=.cloud/dev/ output -json | jq '.resourceGroupName.value')
subscriptionId=$(terraform -chdir=.cloud/dev/ output -json | jq '.subscriptionId.value')
tenant=$(terraform -chdir=.cloud/dev/ output -json | jq '.tenant.value')
jq --argjson v1 "$appId" \
--argjson v2 "$mlWorkspaceName" \
--argjson v3 "$resourceGroupName" \
--argjson v4 "$subscriptionId" \
--argjson v5 "$tenant" \
'.properties.typeProperties.appId = $v1 | .properties.typeProperties.mlWorkspaceName = $v2 | .properties.typeProperties.resourceGroupName = $v3 | .properties.typeProperties.subscriptionId = $v4 | .properties.typeProperties.tenant = $v5' utils/templates/AzureMLService1-template.json >| adf/linkedService/AzureMLService1.json

## update adf
adfName=$(terraform -chdir=.cloud/dev/ output -json | jq '.adf_name.value')
location=$(terraform -chdir=.cloud/dev/ output -json | jq '.location.value')
env=$(terraform -chdir=.cloud/dev/ output -json | jq '.env.value')
jq --argjson v1 "$adfName" \
--argjson v2 "$env" \
--argjson v3 "$location" \
'.name = $v1 | .properties.globalParameters.environment.value = $v2 | .location = $v3 ' utils/templates/template.json >| adf/factory/${adfName//\"}-test.json

rm adf/factory/template.json
rm adf/linkedService/AzureKeyVault1-template.json
rm adf/linkedService/AzureMLService1-template.json

# commit and push changes to branch
git add adf/
git commit -m "automated adf files updates"
git push -u origin adf-objects-update

echo "Changes made to local files and pushed to remote repository on branch 'adf-objects-update'"
echo "Navigate to your repo and merge the changes to the main branch."