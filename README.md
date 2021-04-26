# Azure Data Factory, Azure Machine Learning, and Terraform Example

## TODO: Architecture diagram

## Prerequistes
- Azure Subscription
- `az` cli and `terraform` cli
- Python environment with `azureml` sdk

## Steps
- Deploy infrastructure with Terraform 
    - fork then clone this repo to your environment
    - edit the `main.tf` to point to your cloned github repo for ADF development
    - in the root dir run:
        ```
        tf -chdir=.cloud/dev/ init
        tf -chdir=.cloud/dev/ plan
        tf -chdir=.cloud/dev/ apply
        ```
    - Update adf artefacts by running `chmod u+x utils/adfupdate.sh %% ./utils/adfupdate.sh`
    - Once updated, merge the changes into your `main` branch via PR
- Deploy AML pipeline (interactive):
    - Navigate to your ml workspace and download the `config.json` from the portal - [more details here](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-configure-environment#workspace)
    - Open `notebooks/PipelineParameters.ipynb` and run through the cells. This will create and publish a pipeline into your AzureML workspace
    - Navigate to Azure Data Factory and open the *AMLPipeline* in the Author tab.
        - Update the Settings of the AzureML pipeline execution step to point to the published `Machine Learning Pipeline ID` (this will auto-populate from the dropdown)
    - Save the changes, and test the integration by clicking *Debug*.

## TODO
- Automated deployment of AML pipeline via Azure DevOps
