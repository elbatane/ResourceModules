# DiskEncryptionSet `[Microsoft.Compute/diskEncryptionSets]`

This template deploys a Disk Encryption Set

## Resource types

| Resource Type | Api Version |
| :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2020-04-01-preview |
| `Microsoft.Compute/diskEncryptionSets` | 2020-12-01 |
| `Microsoft.KeyVault/vaults/accessPolicies` | 2019-09-01 |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered |
| `diskEncryptionSetName` | string |  |  | Required. The name of the disk encryption set that is being created. |
| `keyUrl` | string |  |  | Required. Key Url (with version) pointing to a key or secret in KeyVault. |
| `keyVaultId` | string |  |  | Required. Resource id of the KeyVault containing the key or secret. |
| `location` | string | `[resourceGroup().location]` |  | Optional. Resource location. |
| `roleAssignments` | array | `[]` |  | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `tags` | object | `{object}` |  | Optional. Tags of the Automation Account resource. |

### Parameter Usage: `roleAssignments`

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Desktop Virtualization User",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "Reader",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012" // object 1
            ]
        }
    ]
}
```

### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

```json
"tags": {
    "value": {
        "Environment": "Non-Prod",
        "Contact": "test.user@testcompany.com",
        "PurchaseOrder": "1234",
        "CostCenter": "7890",
        "ServiceName": "DeploymentValidation",
        "Role": "DeploymentValidation"
    }
}
```

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `diskEncryptionResourceGroup` | string | The resource group the disk encryption set was deployed into |
| `diskEncryptionSetName` | string | The name of the disk encryption set |
| `diskEncryptionSetResourceId` | string | The resourceId of the disk encryption set |
| `keyVaultName` | string | The name of the key vault with the disk encryption key |
| `principalId` | string | The principal Id of the disk encryption set |

## Template references

- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-04-01-preview/roleAssignments)
- [Diskencryptionsets](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/2020-12-01/diskEncryptionSets)
- [Vaults/Accesspolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2019-09-01/vaults/accessPolicies)
