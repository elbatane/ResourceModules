# RecoveryServicesVaultsBackupPolicies `[Microsoft.RecoveryServices/vaults/backupPolicies]`

This module deploys a Backup Policy for a Recovery Services Vault

## Resource types

| Resource Type | Api Version |
| :-- | :-- |
| `Microsoft.RecoveryServices/vaults/backupPolicies` | 2021-08-01 |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `recoveryVaultName` | string | `` |  | Required. Name of the Azure Recovery Service Vault |
| `name` | string | `` |  | Required. Name of the Azure Recovery Service Vault Backup Policy |
| `backupPolicyProperties` | object | `{}` |  | Required. Configuration of the Azure Recovery Service Vault Backup Policy |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered |

### Parameter Usage: `backupPolicyProperties`

Object continaining the configuration for backup policies. It needs to be properly formatted and can be VM backup policies, SQL on VM backup policies or fileshare policies. The following example shows a VM backup policy.

```json
"backupPolicyProperties": {
  "value": {
        "backupManagementType": "AzureIaasVM",
        "instantRPDetails": {},
        "schedulePolicy": {
          "schedulePolicyType": "SimpleSchedulePolicy",
          "scheduleRunFrequency": "Daily",
          "scheduleRunTimes": [
            "2019-11-07T07:00:00Z"
          ],
          "scheduleWeeklyFrequency": 0
        },
        "retentionPolicy": {
          "retentionPolicyType": "LongTermRetentionPolicy",
          "dailySchedule": {
            "retentionTimes": [
              "2019-11-07T07:00:00Z"
            ],
            "retentionDuration": {
              "count": 180,
              "durationType": "Days"
            }
          },
          "weeklySchedule": {
            "daysOfTheWeek": [
              "Sunday"
            ],
            "retentionTimes": [
              "2019-11-07T07:00:00Z"
            ],
            "retentionDuration": {
              "count": 12,
              "durationType": "Weeks"
            }
          },
          "monthlySchedule": {
            "retentionScheduleFormatType": "Weekly",
            "retentionScheduleWeekly": {
              "daysOfTheWeek": [
                "Sunday"
              ],
              "weeksOfTheMonth": [
                "First"
              ]
            },
            "retentionTimes": [
              "2019-11-07T07:00:00Z"
            ],
            "retentionDuration": {
              "count": 60,
              "durationType": "Months"
            }
          },
          "yearlySchedule": {
            "retentionScheduleFormatType": "Weekly",
            "monthsOfYear": [
              "January"
            ],
            "retentionScheduleWeekly": {
              "daysOfTheWeek": [
                "Sunday"
              ],
              "weeksOfTheMonth": [
                "First"
              ]
            },
            "retentionTimes": [
              "2019-11-07T07:00:00Z"
            ],
            "retentionDuration": {
              "count": 10,
              "durationType": "Years"
            }
          }
        },
        "instantRpRetentionRangeInDays": 2,
        "timeZone": "UTC",
        "protectedItemsCount": 0
    }
}
```


## Outputs

| Output Name | Type |
| :-- | :-- |
| `backupPolicyName` | string |
| `backupPolicyId` | string |
| `backupPolicyResourceGroup` | string |

## Template references

- [Vaults/Backuppolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.RecoveryServices/2019-06-15/vaults/backupPolicies)
