# Automation Account Modules `[Microsoft.Automation/automationAccounts/modules]`

This module deploys an Azure Automation Account Module.

## Resource Types

| Resource Type | Api Version |
| :-- | :-- |
| `Microsoft.Automation/automationAccounts/modules` | 2020-01-13-preview |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `automationAccountName` | string |  |  | Required. Name of the parent Automation Account. |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered. |
| `location` | string | `[resourceGroup().location]` |  | Optional. Location for all resources. |
| `name` | string |  |  | Required. Name of the Automation Account module. |
| `tags` | object | `{object}` |  | Optional. Tags of the Automation Account resource. |
| `uri` | string |  |  | Required. Module package uri, e.g. https://www.powershellgallery.com/api/v2/package. |
| `version` | string | `latest` |  | Optional. Module version or specify latest to get the latest version. |

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `moduleName` | string | The name of the deployed module |
| `moduleResourceGroup` | string | The resource group of the deployed module |
| `moduleResourceId` | string | The id of the deployed module |

## Template references

- [Automationaccounts/Modules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Automation/2020-01-13-preview/automationAccounts/modules)
