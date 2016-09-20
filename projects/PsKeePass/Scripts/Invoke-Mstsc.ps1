#christian.hoekstra.blogspot.com
function Invoke-Mstsc
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$ComputerName,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[PSCredential] $Credential
	)
	
	begin
	{
		# Set internal variables
		$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
		$Process = New-Object System.Diagnostics.Process
		[string]$ComputerCmdkey = $null
		
		# Remove port, for Windows Credential Manager
		if ($ComputerName.Contains(':'))
		{
			$ComputerCmdkey = ($ComputerName -split ':')[0]
		}
		else
		{
			$ComputerCmdkey = $ComputerName
		}
	}
	
	Process
	{
		# Store credential in Windows
		$ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
		$ProcessInfo.Arguments = "/generic:TERMSRV/$ComputerCmdkey /user:$($Credential.UserName) /pass:$($credential.GetNetworkCredential().Password)"
		$ProcessInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
		$Process.StartInfo = $ProcessInfo
		[void]$Process.Start()
		
		# Invoke MSTSC
		$ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
		$ProcessInfo.Arguments = "$MstscArguments /v:$ComputerName"
		$ProcessInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
		$Process.StartInfo = $ProcessInfo
		[void]$Process.Start()
	}
	
	End
	{
		# To avoid credentials removed before session can complete, sleep
		Start-Sleep -Seconds 10

		# Remove credential from Windows Credential Manager
		$ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
		$ProcessInfo.Arguments = "/delete:TERMSRV/$ComputerCmdkey"
		$ProcessInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
		$Process.StartInfo = $ProcessInfo
		[void]$Process.Start()
	}
}