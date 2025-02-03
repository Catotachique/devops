# Data engineering Projects
Projects related to Data engineering.

### Errors
The error message indicates that you're trying to push a file (terraform-provider-azurerm_v4.16.0_x5.exe) that exceeds GitHub's 100 MB file size limit. Here’s how you can resolve this issue:
git filter-branch -f --index-filter 'git rm --cached -r --ignore-unmatch .terraform/'
