# AWS SSO Login Script for Multiple Orgs
# Save as: Login-AWSSSO-MultiOrg.ps1

# --- CONFIGURATION ---
$orgs = @(
    @{ Name = "Org-A"; StartUrl = "https://orgA.awsapps.com/start"; Region = "us-east-1" },
    @{ Name = "Org-B"; StartUrl = "https://orgB.awsapps.com/start"; Region = "us-west-2" },
    @{ Name = "Org-C"; StartUrl = "https://orgC.awsapps.com/start"; Region = "eu-central-1" }
)

# --- Select Org ---
$orgChoice = $orgs | Out-GridView -Title "Select Organization" -PassThru
if (-not $orgChoice) { Write-Host "No org selected. Exiting."; exit }

$SSOStartUrl = $orgChoice.StartUrl
$SSORegion   = $orgChoice.Region

Write-Host "Logging into $($orgChoice.Name)..."

# Login
aws sso login --sso-start-url $SSOStartUrl --sso-region $SSORegion

# Fetch accounts
$accounts = aws sso list-accounts --region $SSORegion | ConvertFrom-Json
$accountChoice = $accounts.accountList | Out-GridView -Title "Select AWS Account" -PassThru

# Fetch roles
$roles = aws sso list-account-roles --account-id $accountChoice.accountId --region $SSORegion | ConvertFrom-Json
$roleChoice = $roles.roleList | Out-GridView -Title "Select Role for $($accountChoice.accountName)" -PassThru

# Get credentials
$creds = aws sso get-role-credentials --account-id $accountChoice.accountId --role-name $roleChoice.roleName --region $SSORegion | ConvertFrom-Json

# Export to env vars
$env:AWS_ACCESS_KEY_ID     = $creds.roleCredentials.accessKeyId
$env:AWS_SECRET_ACCESS_KEY = $creds.roleCredentials.secretAccessKey
$env:AWS_SESSION_TOKEN     = $creds.roleCredentials.sessionToken

Write-Host "`nLogged in to $($orgChoice.Name) → Account $($accountChoice.accountName) → Role $($roleChoice.roleName)"

