# Testing Design

This section gives you an overview of the design principals the testing follows.

---

### _Navigation_

- [Approach](#approach)
- [Static code validation](#static-code-validation)
  - [Additional resources](#additional-resources)
- [API version validation](#api-version-validation)
- [Template validation](#template-validation)
- [Deployment validation](#deployment-validation)
  - [Module dependencies](#module-dependencies)
    - [Resources deployed by the dependency workflow](#resources-deployed-by-the-dependency-workflow)
    - [Required secrets and keys](#required-secrets-and-keys)

---

## Approach

To ensure a baseline module code quality across all the modules, modules are validated before publishing them.

All tests are executed as part of the individual module pipelines, run each time any module code was altered, and ensure that only modules that pass each test successfully are published. If a test fails, it tells you in the pipeline log exactly what went wrong and in most cases gives you recommendations what to do to resolve the problem.

The general idea is that you should fail as early as possible to allow for minimal wasted time and a fast response time.

> ***Note:*** Both the Template Validation and Template Deployment tests are only as good as their parameter files. Hence you should make sure that you test at least a minimum set of parameters and a maximum set of parameters. Furthermore it makes sense to have different parameter files for different scenarios to test each variant.

Tests falls into four categories:

- Static code validation
- API version validation
- Template Validation with parameter file(s)
- Template Deployment with parameter file(s)

## Static code validation

All Module Unit tests are performed with the help of [Pester](https://github.com/pester/Pester) and are required to have consistent, clean and syntactically correct tests to ensure that our modules are configured correctly, documentation is up to date, and modules don't turn stale.

The following activities are run executing the `arm/.global/global.module.tests.ps1` script.

- **File & folder tests** validate that the module folder structure is set up in the intended way. e.g.:
  - reame.md must exists
  - template file (either deploy.json or deploy.bicep) exists
  - compliance with file naming convention
- **Deployment template tests** check the template's structure and elements for errors as well as consistency matters. e.g.
  - template file (or the built bicep template) converts from JSON and has all expected properties
  - variable names are camelCase
  - the minimum set of outputs are returned
- **Module (readme.md) documentation** contains all required sections. e.g.:
  - is not empty
  - contains all the mandatory sections
  - describes all the parameters
- **Parameter Files**. e.g.:
  - at least one `*parameters.json` should exist
  - files should be valid JSON

### Additional resources

- [Pester Wiki](https://github.com/pester/Pester/wiki)
- [Pester on GitHub](https://github.com/pester/Pester)
- [Pester Setup and Commands](https://pester.dev/docs/commands/Setup)

## API version validation

In this phase, the workflow will verify if the module is one of the latest 5 (non-preview) API version using the `arm/.global/global.module.tests.ps1` script.

## Template validation

The template validation tests execute a dry-run with each parameter file provided & configured for a module. For example, if you have two parameter files for a module, one with the minimum set of parameters, one with the maximum, the tests will run an `Test-AzDeployment` (_- the command may vary based on the template schema_) with each of the two parameter files to see if the template would be able to be deployed with them. This test could fail either because the template is invalid, or because any of the parameter files is configured incorrectly.

## Deployment validation

If all other tests passed, the deployment tests are the ultimate module validation. Using the available & configured parameter files for a module, each is deployed to Azure (in parallel) and verifies if the deployment works end to end.

Most of the resources are deleted by default after their deployment, to keep costs down and to be able to retest resource modules from scratch in the next run. However, the removal step can be skipped in case further investigation on the deployed resource is needed. For further details, please refer to the (.\PipelinesUsage.md) section.

This happens using the `.github/actions/templates/validateModuleDeploy/scripts/Test-TemplateWithParameterFile.ps1` script.

> **Note**<br>
Currently the list of the parameter file used to test the module is hardcoded in the module specific workflow, as the **parameterFilePaths** in the _job_deploy_module_ and _job_tests_module_deploy_validate_ jobs.

### Module dependencies

In order to successfully deploy and test all modules in your desired environment some modules have to have resources deployed beforehand.

> **Note**<br>
If we speak from **modules** in this context we mean the **services** which get created from these modules.

#### Resources deployed by the dependency workflow

Together with the resource modules pipelines, we are providing a dependency pipeline (GitHub workflow: `.github\workflows\platform.dependencies.yml`), leveraging resource parameters from the `utilities\dependencies` subfolder.

The resources deployed by the dependency workflow need to be in place before testing all the modules. Some of them (e.g. [storage account], [key vault] and [event hub namespace]) require a globally unique resource name. Before running the dependency workflow, it is required to update those values and their corresponding references in the resource modules parameters.

Since also dependency resources are in turn subject to dependencies with each other, resources are deployed in the following grouped order.

**First level resources**

  1. Resource Groups: Leveraged by all modules. Multiple instances are deployed:
     - 'validation-rg': The resource group to which resources are deployed by default during the test deployment phase. This same resource group is also the one hosting the dependencies.
     - 'artifacts-rg': The resource group to which templates are published during the publishing phase.

**Second level resources**: This group of resources has a dependency only on the resource group which will host them. Resources in this group can be deployed in parallel.

  1. User assigned identity: This resource is leveraged as a test identity by all resources supporting RBAC.
  2. Log analytics workspace: This resource is leveraged by all resources supporting diagnostic settings on LAW.
  3. Storage account: This resource is leveraged by all resources supporting diagnostic settings on a storage account.
      >**Note**: This resource has a global scope name.
  4. Event hub namespace: This resource is leveraged by the [event hub] resource.
      >**Note**: This resource has a global scope name.
  5. Route table: This resource is leveraged by the virtual network subnet dedicated to test [SQL managed instance].
  6. Network watcher: This resource is leveraged by the [NSG flow logs] resource.
  7. Shared image gallery: This resource is leveraged by the [shared image definition] and [image template] resources.
  8. Action group: This resource is leveraged by [activity log alert] and [metric alert] resources.
  9. Application security group: This resource is leveraged by the [network security group] resource.
  10. Application service plan: This resource is leveraged by the [function app] and [web app] resources.
  11. Azure Container Registry: This resource is leveraged as the private bicep registry to publish modules to.

**Third level resources**: This group of resources has a dependency on one or more resources in the group above. Resources in this group can be deployed in parallel.

  1. Event hub: This resource is depending on the [event hub namespace] deployed above and leveraged by all resources supporting diagnostic settings on an event hub.
  2. Role assignment: This resource assigns the '_Contributor_' role on the subscription to the [user assigned identity] deployed as part of the group above. This is needed by the [image template] deployment.
  3. Shared image definition: This resource is depending on the [shared image gallery] deployed above and leveraged by the [image template] resource.

**Fourth level resources**: All resources in this group support monitoring. Hence they have a dependency on the [storage account], [log analytics workspace] and [event hub] deployed in the groups above. Resources in this group can be deployed in parallel.

  1. Key vault: This resource is leveraged by all resources requiring access to a key vault key, secret and/or certificate, i.e. [application gateway], [azure NetApp file], [azure SQL server], [disk encryption set], [machine learning service], [private endpoint], [SQL managed instance], [virtual machine], [virtual machine scale set], [virtual network gateway connection].
      >**Note**: This resource has a global scope name.
  2. Network Security Groups: This resource is leveraged by different virtual network subnets. Multiple instances are deployed:
      - '_adp-sxx-az-nsg-x-apgw_': NSG with required network security rules to be leveraged by the [application gateway] subnet.
      - '_adp-sxx-az-nsg-x-ase_': NSG with required network security rules to be leveraged by the [app service environment] subnet.
      - '_adp-sxx-az-nsg-x-bastion_': NSG with required network security rules to be leveraged by the [bastion host] subnet.
      - '_adp-sxx-az-nsg-x-sqlmi_': NSG with required network security rules to be leveraged by the [sql managed instance] subnet.
      - '_adp-sxx-az-nsg-x-001_': default NSG leveraged by all other subnets.
  3. Public IP addresses: Multiple instances are deployed:
      - '_adp-sxx-az-pip-x-apgw_': Leveraged by the [application gateway] resource.
      - '_adp-sxx-az-pip-x-bas_': Leveraged by the [bastion host] resource.
      - '_adp-sxx-az-pip-x-lb_': Leveraged by the [load balancer] resource.
  4. API management: This resource is leveraged by all [API management services].
      >**Note**: This resource has a global scope name.
  5. Application insight: This resource is leveraged by the [machine learning service] resource.
  6. AVD host pool: This resource is leveraged by the [AVD application group] resource.
  7. Recovery services vault: This resource is leveraged by the [virtual machine] resource when backup is enabled.

**Fifth level resources**: This group of resources has a dependency on one or more resources in the groups above. Resources in this group can be deployed in parallel.

  1. Virtual Networks: This resource is depending on the route table and network security groups deployed above. Multiple instances are deployed:
      - '_adp-sxx-az-vnet-x-peer01_': Leveraged by the [virtual network peering] resource.
      - '_adp-sxx-az-vnet-x-peer02_': Leveraged by the [virtual network peering] resource.
      - '_adp-sxx-az-vnet-x-azfw_': Leveraged by the [azure firewall] resource.
      - '_adp-sxx-az-vnet-x-aks_': Leveraged by the [azure kubernetes service] resource.
      - '_adp-sxx-az-vnet-x-sqlmi_': Leveraged by the [sql managed instance] resource.
      - '_adp-sxx-az-vnet-x-001_': Hosting multiple subnets to be leveraged by [virtual machine], [virtual machine scale set], [service bus], [azure NetApp files], [azure bastion], [private endpoints], [app service environment] and [application gateway] resources.
  2. AVD application group: This resource is leveraged by the [AVD workspace] resource.

**Sixth level resources**: This group of resources has a dependency on one or more resources in the groups above.

  1. Virtual Machine: This resource is depending on the [virtual networks] and [key vault] deployed above. This resource is leveraged by the [automanage] resource.
  2. Private DNS zone: This resource is depending on the [virtual networks] deployed above. This resource is leveraged by the [private endpoint] resource.

#### Required secrets and keys

The following secrets, keys and certificates need to be created in the key vault deployed by the dependency workflow.

1. Key vault secrets:
   - _administratorLogin_: For [azure SQL server] and [SQL managed instance].
   - _administratorLoginPassword_: For [azure SQL server] and [SQL managed instance].
   - _vpnSharedKey_: For [virtual network gateway connection].
   - _adminUserName_: For [virtual machine].
   - _adminPassword_: For [virtual machine].
1. Key vault keys:
   - _keyEncryptionKey_: For [disk encryption set].
   - _keyEncryptionKeySqlMi_: For [SQL managed instance].
1. Key vault certificate:
   - _applicationGatewaySslCertificate_: For [application gateway].
