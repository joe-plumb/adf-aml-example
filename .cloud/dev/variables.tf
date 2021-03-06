variable "default_tags" { 
    type = map 
    default = {
      WorkloadName = "EnterpriseAzureML",
      DataClassification = "General",
      Criticality = "High",
      BusinessUnit = "DataScience",
      OpsCommitment = "Baseline only",
      OpsTeam = "Cloud operations"
  }
}

variable "env" {
    type = string
    default = "dev"
}

variable "region" {
    type = string
    default = "westeurope"
}

variable "regionshort" {
    type = string
    default = "weu"
}
