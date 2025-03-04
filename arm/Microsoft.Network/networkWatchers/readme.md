# Network Watcher `[Microsoft.Network/networkWatchers]`

This template deploys Network Watcher.

## Resource types

| Resource Type | Api Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | 2016-09-01 |
| `Microsoft.Authorization/roleAssignments` | 2020-04-01-preview |
| `Microsoft.Network/networkWatchers` | 2021-02-01 |
| `Microsoft.Network/networkWatchers/connectionMonitors` | 2021-03-01 |
| `Microsoft.Network/networkWatchers/flowLogs` | 2021-03-01 |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `connectionMonitors` | _[connectionMonitors](connectionMonitors/readme.md)_ array | `[]` |  | Optional. Array that contains the Connection Monitors |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered |
| `flowLogs` | _[flowLogs](flowLogs/readme.md)_ array | `[]` |  | Optional. Array that contains the Flow Logs |
| `location` | string | `[resourceGroup().location]` |  | Optional. Location for all resources. |
| `lock` | string | `NotSpecified` | `[CanNotDelete, NotSpecified, ReadOnly]` | Optional. Specify the type of lock. |
| `name` | string | `[format('NetworkWatcher_{0}', parameters('location'))]` |  | Required. Name of the Network Watcher resource (hidden) |
| `roleAssignments` | array | `[]` |  | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `tags` | object | `{object}` |  | Optional. Tags of the resource. |

### Parameter Usage: `monitors`

Montiors specifies the Connection monitors in an array in the following structure.

Important note: the parameter ``name`` must include the ``resource name`` AND ``resource group`` inside brackets (). e.g ``"name": "myVm01(my-rg-01)"``. This parameter is under ``monitors/value/endpoints/name`` and ``monitors/value/testGroups/name``. See example below for full structure.

```json
"monitors": {
    "value": [
        {
            "connectionMonitorName": "my-connection-monitor01",
            "workspaceResourceId": {
                "value": "[variables('workspaceId')]"
            },
            "endpoints": [
                {
                    "name": "endpoint01",
                    "resourceId": "/subscriptions/111111-222222-33333-4444-5555555/resourceGroups/my-rg-01/providers/Microsoft.Compute/virtualMachines/myVm01"
                },
                {
                    "name": "myonpremvm.contoso.com",
                    "address": "10.10.10.10"
                }
            ],
            "testConfigurations": [
                {
                    "name": "ICMP",
                    "testFrequencySec": 60,
                    "protocol": "Icmp",
                    "icmpConfiguration": {
                        "disableTraceRoute": false
                    },
                    "successThreshold": {
                        "checksFailedPercent": 1,
                        "roundTripTimeMs": 70
                    }
                }
            ],
            "testGroups": [
                {
                    "name": "myTestGroup01",
                    "disable": false,
                    "testConfigurations": [
                        "ICMP"
                    ],
                    "sources": [
                        "myVm01(my-rg-01)"
                    ],
                    "destinations": [
                        "myonpremvm.contoso.com"
                    ]
                }
            ]
        }
    ]
}
```

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
| `networkWatcherName` | string | The name of the deployed network watcher |
| `networkWatcherResourceGroup` | string | The resource group the network watcher was deployed into |
| `networkWatcherResourceId` | string | The resourceId of the deployed network watcher |

## Template references

- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2016-09-01/locks)
- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-04-01-preview/roleAssignments)
- [Networkwatchers](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-02-01/networkWatchers)
- [Networkwatchers/Connectionmonitors](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-03-01/networkWatchers/connectionMonitors)
- [Networkwatchers/Flowlogs](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-03-01/networkWatchers/flowLogs)
