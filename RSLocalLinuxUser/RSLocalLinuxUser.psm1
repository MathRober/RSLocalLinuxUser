function New-LocalLinuxUser{
    [cmdletbinding()]
    param 
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(1,32)]
        [ValidateScript({
            if ($_ -cmatch '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$')
            {
                return $true
            }
            else 
            {
                throw 'The user account does not match default Linux rules'
            }
        })]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$AccountExpiresString,

        [parameter()]
        [securestring]$Password
    )


    if ($AccountExpiresString)
    {
        try 
        {
            $thisDate = [datetime]::Parse($AccountExpiresString)
            $ThisDateString = $thisDate.ToString('yyyy-MM-dd')
        }
        catch 
        {
            throw 'The AccountExpiresString is not a valid date'
        }
    }

    if ($Description)
    {
        $StartProcess_Data = @{
            FilePath = '/usr/sbin/useradd'
            ArgumentList = "$Name --comment $Description --expiredate $ThisDateString"
        }

    }
    else 
    {
        $StartProcess_Data = @{
            FilePath = '/usr/sbin/useradd'
            ArgumentList = "$Name  --expiredate $ThisDateString"
        }
    }
    Start-Process  @StartProcess_Data
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error -Message ('Error creating {0}, ExitCode {1}' -f $Name, $LASTEXITCODE)
        Exit
    }
    #$SecurePassword = ConvertTo-SecureString $PlainPassword
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $StartProcess_Data = @{
        FilePath = '/usr/sbin/usermod'
        ArgumentList = "--password $UnsecurePassword $Name"
    }
    Start-Process  @StartProcess_Data
 
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error -Message ('Error setting password for {0}; ExitCode {1}' -f $Name, $LASTEXITCODE)
        Exit
    }
    Write-Output "Usuario creado correctamente."
}
#$pass = Read-Host -AsSecure  "Contraseña:"
#New-LocalLinuxUser -Password $pass -AccountExpiresString '2020-01-01' -Name usuario6

function Get-LocalLinuxUser {
    [CmdletBinding()]
    Param(
        [bool]$System = $false
    )
    begin{ 
        $File = '/etc/passwd'
        if (!(Test-Path $File))
        {
            throw (New-Object Exception -ArgumentList "The file $File doesn't exist")
        }
        else {
            $Users = Get-Content $File
        }
    }
    process{
        foreach($user in $Users)
        {
            
            $userarray = $user -split (":")
            $obj = [PSCustomObject][ordered]@{
                Username = $userarray[0]
                Password = $userarray[1]
                UserID   =[int]$userarray[2]
                GroupID = [int]$userarray[3]
                UserIDInfo = $userarray[4]
                HomeDir   = $userarray[5]
                Shell     = $userarray[6]

            }

            if($obj.UserID -lt 1000 -and $System -eq $true ) { $obj }
            if($obj.UserID -ge 1000  ) { $obj }
        }
        
    }

}

#Get-LocalLinuxUser -System $false | ft *
#Get-LocalLinuxUser -System $true | select Username, HomeDir

function Remove-LocalLinuxUser{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(1,32)]
        [ValidateScript({
            if ($_ -cmatch '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$')
            {
                return $true
            }
            else 
            {
                throw 'The user account does not match default Linux rules'
            }
        })]
        [string]$Name,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
        [bool]$RemoveHome
    )
    if ($RemoveHome)
    {
        /usr/sbin/deluser  $Name --remove-home
    }
    else 
    {
        /usr/sbin/deluser  $Name
    }
     
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error -Message ('Error deletingcreating {0}, ExitCode {1}' -f $Name, $LASTEXITCODE)
        Exit
    }
    else{
        Write-OutPut "Delete lines in /etc/sudoers for this user"
    }
}

#view /etc/sudoers  a ver si hay alguna entrada para el usuario

function Reset-LocalLinuxUserPassword {

    passwd user
}