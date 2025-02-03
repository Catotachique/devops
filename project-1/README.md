## Project-1

### Business Request
In this project, your company has recognized a gap in understanding its customer demographics—specifically, the gender distribution within the customer base and how it might influence product purchases. With a significant amount of customer data stored in an on-premises SQL database, key stakeholders have requested a comprehensive KPI dashboard.
This dashboard should provide insights into sales by gender and product category, showing total products sold, total sales revenue, and a clear gender split among customers. Additionally, they need the ability to filter this data by product category and gender, with a user-friendly interface for date-based queries.

### Solution Overview
To address this request, I'll build a robust data pipeline that:
- Extracts the on-premises data, loads it into Azure, and performs the necessary transformations to make the data more query-friendly. 
- The transformed data will then feed into a custom-built report that meets all the specified requirements. 
- The pipeline will be scheduled to run automatically every day, ensuring that stakeholders always have access to up-to-date and accurate data.

# Commands
### Commands Terraform
terraform init
terraform fmt
terraform plan
terraform apply -auto-approve

### Commands Azure
az login
az account show
az account set --subscription <subscription>
az account list --output table

### List Available Regions
az account list-locations --output table

### Check the Default Region 
az configure --list-defaults

# State locking
### Defining state locking
https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=terraform <br>
https://developer.hashicorp.com/terraform/language/state/locking <br>

### First steps to create the State locking
1 - Execute terraform init in the folder: project-1\environments\dev\state-locking\main.tf <br> 
2 - Execute terraform apply in the folder: project-1\environments\dev\state-locking\main.tf to create a storege account <br> 
3 - Execute terraform init in the folder: project-1\environments\dev\westeurope\main.tf <br> 
4 - Execute terraform apply in the folder: project-1\environments\dev\westeurope\main.tf to create the provider <br> 

# Architecture
We are proposing the same structure across all environments (dev/test/prod). A storage account does not create any cost if not used and hence there is no reason to change the setup in dev or pre-prod. In general, one should try to make the various environments as similar as possible. Otherwise, we will always end up with various kinds of problems once you move the code into higher environments. Always try to have an exact replica in lower environments. For cost reasons you might want to scale down some services, but that is not applicable to these storage accounts.

Data Lakes, Data Products and Data Integration Products will land in the Data Landing Zone into different resource groups within same subscription. Data Lakes have their own resource group. There are a couple of core resources in each landing zone to create a metadata driven ingestion framework (ADF, Azure SQL, Key Vault, SHIR), which are also landing in a few resource groups in the core landing zone setup.

Thye Azure internal solution experts are recommending to land the dev/test/prod instances of the landing zones in separate subscriptions. The data integration products should follow this pattern and can use the same respective subscriptions. The data products however often have to land their dev/test/prod instances into the prod landing zone as they have to access prod data in each of their environment. Development without prod data is often a problem and copying the data into the dev landing zone is not a recommended approach.

Copying prod data into a dev environment is something that most organizations won't do.
In general, our internal experts are proposing to use an in-place data access model. The data source will be read-only by data consumers and modifications cannot be made to the source. The teams can read the data, process the data and store their own results in their dedicated workspace file system, as required. In summary, the source cannot be overwritten and, hence, there is no risk of corrupting the data. But ultimately the decision to choose which data to be used for development testing will depends on the sensitivity/confidentiality of the data as well as organizations security requirements.

Data Products are then environments where cross-functional data teams can work on their data use cases. These use cases get their own resource group, subnet and space on the data lakes to implement their own solution. Inside that resource group they are free to create the services they require within the boundaries of Azure Policy. They are free to choose between Synapse, ADF, AML, etc. or they can use some of the shared Databricks instances that get deployed with each landing zone.

### Links
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/ <br>
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/well-architected-framework <br>
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/ <br>
https://github.com/Azure/data-management-zone <br>
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/data-landing-zone <br>
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/data-landing-zone#data-landing-zone-architecture <br>
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources <br>
https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/articles/analytics-start-here <br>
https://learn.microsoft.com/en-us/azure/architecture/example-scenario/analytics/enterprise-bi-synapse <br>
https://github.com/Azure/data-landing-zone/blob/main/docs/DataManagementAnalytics-Prerequisites.md#what-will-be-deployed <br>
https://www.youtube.com/watch?v=OeAXC7DJrfg <br>
https://www.youtube.com/watch?v=otyM9kzv4xQ <br>
https://medium.com/gamersclub/uma-breve-jornada-de-dados-level-5-f42a502a315f <br>

### Separate Data Lake Resources for Each Environment
Separate Azure Resources for Each Environment: <br>
The recommended best practice is to create separate Azure Data Lake Storage (ADLS) instances for each environment: Dev, Test, and Prod.
These can be in the same subscription or in different subscriptions, depending on how you organize your Azure environment.

Why Separate Resources? <br>
Isolation: It ensures that data, configurations, and access controls for each environment are entirely independent. Changes made in Dev or Test will not affect Prod.
Exact Replication of Folder Structure: Each environment can have the same folder structure, making it easier to maintain consistency and to move data between environments when promoting changes.
Clear Governance: Each resource can have its own security, monitoring, and cost management configurations.

If feasible: <br>
Use separate Azure Data Lake resources for Dev, Test, and Prod for better isolation, governance, and reliability. If constrained to a single resource:
Create a top-level folder for each environment and enforce strict policies to minimize the risks associated with sharing the same resource.

### Why Exact Folder Structure Matters Across Environments
Having the same folder structure across environments ensures consistency when promoting code, configurations, or processes.
For example: <br>
Dev Folder Structure: /dev/raw, /dev/processed, /dev/analytics
Prod Folder Structure: /prod/raw, /prod/processed, /prod/analytics

By maintaining this structure: <br>
Automation: Data pipelines and scripts built for one environment (e.g., Dev) can run seamlessly in another (e.g., Prod) with minimal changes.
Simpler Testing: You can test processes in Dev or Test under the same folder setup and confidently promote them to Prod.

### Resource Group Strategy
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources <br>
In Azure, resource groups (RGs) should be organized logically to ensure manageability, cost control, security, and scalability. Here's how to structure resource groups for a Data Lakehouse: <br>

Resource Group for Data Storage <br> 
Contains Azure Data Lake Storage Gen2, Blob Storage, and storage accounts. <br> 
Example name: rg-data-storage.<br> 

Resource Group for Data Ingestion <br> 
Contains Azure Data Factory, Event Hub, IoT Hub, or any ingestion services. <br> 
Example name: rg-data-ingestion. <br>

Resource Group for Data Processing <br>
Contains Azure Databricks, Azure Functions, or any compute resources for ETL/ELT processing. <br> 
Example name: rg-data-processing. <br>

Resource Group for Analytics and Reporting <br>
Contains Azure Synapse Analytics, Power BI workspaces, or Analysis Services. <br>
Example name: rg-data-analytics. <br>

Resource Group for Governance and Security <br>
Contains Azure Purview, Azure Key Vault, Azure AD role assignments, or audit-related resources. <br>
Example name: rg-data-governance. <br>

Resource Group for Monitoring and Orchestration <br>
Contains Azure Monitor, Log Analytics, Application Insights, and Azure Data Factory Pipelines. <br>
Example name: rg-monitoring-orchestration. <br>

### Why Separate Resource Groups? <br> 
Cost Management: Each resource group can be linked to a budget or cost analysis for tracking expenses.
Access Control: Use role-based access control (RBAC) to limit access to sensitive data and processes.
Lifecycle Management: Manage the lifecycle of related resources (e.g., deallocate or delete specific services when no longer needed).
Compliance: Grouping resources by purpose ensures that compliance policies can be applied effectively.
Scalability: Helps you scale and manage components independently as the architecture grows.

### When to Use Data Mesh or Data Fabric? <br> 
Use Data Mesh if: <br> 
Your organization has diverse domains that need autonomy over their data.
You want to enable faster, domain-specific decision-making.
You prioritize decentralization and team empowerment.

Use Data Fabric if: <br>
Your data is spread across many platforms, clouds, or environments.
You need real-time integration and a unified view of data.
You prioritize centralized governance and automation. <br> 
In some cases, both approaches can complement each other. For example, you could implement a data fabric for seamless integration and access across systems while adopting data mesh principles for decentralized ownership within specific domains.

### Final Architecture: <br> 
Resource Group Distribution: <br> 
| **Resource Group Name**         | **Services/Resources in the RG**                       |
|---------------------------------|--------------------------------------------------------|
| **rg-data-storage**             | Data Lake Gen2, Blob Storage, File Shares              |
| **rg-data-ingestion**           | Data Factory, Event Hub, IoT Hub                       |
| **rg-data-processing**          | Databricks, Synapse Pipelines, Functions, Batch        |
| **rg-data-analytics**           | Synapse Analytics, Power BI, Analysis Services         |
| **rg-data-governance**          | Purview, Key Vault, Azure Policy, Role Assignments     |
| **rg-monitoring-orchestration** | Monitor, Log Analytics, Alerts, Data Factory Pipelines |

### Logical Flow: <br> 
Data Ingestion → Data from sources is ingested into the Raw Zone in rg-data-storage. <br> 
Data Processing → Databricks or Synapse transforms data and moves it to Clean/Enriched Zones. <br> 
Analytics → Data in the enriched zone is consumed by Synapse Analytics or Power BI. <br> 
Governance → Azure Purview ensures data cataloging, lineage, and compliance. <br> 
Monitoring → All components are monitored for performance and cost. <br>

### Based on
project-1 is based in this video:
https://www.youtube.com/watch?v=ygJ11fzq_ik
