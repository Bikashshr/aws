# AWS SSO Login Script with Predefined Orgs/Accounts/Roles
# Save as: Login-AWSSSO-Quick.ps1

# --- CONFIGURATION ---
$profiles = @(
    @{
        Name      = "Dev-OrgA"
        StartUrl  = "https://orgA.awsapps.com/start"
        Region    = "us-east-1"
        AccountId = "111111111111"
        RoleName  = "DevOpsAdmin"
    },
    @{
        Name      = "Prod-OrgB"
        StartUrl  = "https://orgB.awsapps.com/start"
        Region    = "us-west-2"
        AccountId = "222222222222"
        RoleName  = "ProdReadOnly"
    },
    @{
        Name      = "Shared-OrgC"
        StartUrl  = "https://orgC.awsapps.com/start"
        Region    = "eu-central-1"
        AccountId = "333333333333"
        RoleName  = "NetworkAdmin"
    }
)

# --- Select Profile ---
$profileChoice = $profiles | Out-GridView -Title "Select Profile" -PassThru
if (-not $profileChoice) { Write-Host "No profile selected. Exiting."; exit }

$SSOStartUrl = $profileChoice.StartUrl
$SSORegion   = $profileChoice.Region
$AccountId   = $profileChoice.AccountId
$RoleName    = $profileChoice.RoleName

Write-Host "Logging into $($profileChoice.Name)..."

# Login (will only open browser if token is expired)
aws sso login --sso-start-url $SSOStartUrl --sso-region $SSORegion

# Get credentials
$creds = aws sso get-role-credentials `
    --account-id $AccountId `
    --role-name $RoleName `
    --region $SSORegion | ConvertFrom-Json

# Export credentials into current PowerShell session
$env:AWS_ACCESS_KEY_ID     = $creds.roleCredentials.accessKeyId
$env:AWS_SECRET_ACCESS_KEY = $creds.roleCredentials.secretAccessKey
$env:AWS_SESSION_TOKEN     = $creds.roleCredentials.sessionToken

Write-Host "`n✅ Logged in as $($RoleName) in account $($AccountId) ($($profileChoice.Name))"

