targetScope = 'managementGroup'
param policySetDefinitionName string
param displayName string = ''
param policySetDescription string = ''
param metadata object = {}
param policyDefinitions array
param policyDefinitionGroups array = []
param parameters object = {}
param location string = deployment().location
param managementGroupId string

var policySetDefinitionName_var = replace(policySetDefinitionName, ' ', '-')

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: policySetDefinitionName_var
  location: location
  properties: {
    policyType: 'Custom'
    displayName: (empty(displayName) ? null : displayName)
    description: (empty(policySetDescription) ? null : policySetDescription)
    metadata: (empty(metadata) ? null : metadata)
    parameters: (empty(parameters) ? null : parameters)
    policyDefinitions: policyDefinitions
    policyDefinitionGroups: (empty(policyDefinitionGroups) ? [] : policyDefinitionGroups)
  }
}

output policySetDefinitionName string = policySetDefinition.name
output policySetDefinitionId string = extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', managementGroupId), 'Microsoft.Authorization/policySetDefinitions', policySetDefinition.name)
