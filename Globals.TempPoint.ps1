#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}
#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory




function Format-TimeSpan
{
	process
	{
		"{0:00} День {1:00}:{2:00}:{3:00}" -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds
	}
}


function Update-DataGridView
{
	<#
	.SYNOPSIS
		This functions helps you load items into a DataGridView.

	.DESCRIPTION
		Use this function to dynamically load items into the DataGridView control.

	.PARAMETER  DataGridView
		The DataGridView control you want to add items to.

	.PARAMETER  Item
		The object or objects you wish to load into the DataGridView's items collection.
	
	.PARAMETER  DataMember
		Sets the name of the list or table in the data source for which the DataGridView is displaying data.

	.PARAMETER AutoSizeColumns
	    Resizes DataGridView control's columns after loading the items.
	#>
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		$Item,
		[Parameter(Mandatory = $false)]
		[string]$DataMember,
		[System.Windows.Forms.DataGridViewAutoSizeColumnMode]$AutoSizeColumns = 'None'
	)
	$DataGridView.SuspendLayout()
	$DataGridView.DataMember = $DataMember
	
	if ($Item -is [System.Data.DataSet] -and $Item.Tables.Count -gt 0)
	{
		$DataGridView.DataSource = $Item.Tables[0]
	}
	elseif ($Item -is [System.ComponentModel.IListSource]`
		-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView])
	{
		$DataGridView.DataSource = $Item
	}
	else
	{
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}
		else
		{
			$array.Add($Item)
		}
		$DataGridView.DataSource = $array
	}
	
	if ($AutoSizeColumns -ne 'None')
	{
		$DataGridView.AutoResizeColumns($AutoSizeColumns)
	}
	
	$DataGridView.ResumeLayout()
}

function ConvertTo-DataTable
{
	<#
		.SYNOPSIS
			Converts objects into a DataTable.
	
		.DESCRIPTION
			Converts objects into a DataTable, which are used for DataBinding.
	
		.PARAMETER  InputObject
			The input to convert into a DataTable.
	
		.PARAMETER  Table
			The DataTable you wish to load the input into.
	
		.PARAMETER RetainColumns
			This switch tells the function to keep the DataTable's existing columns.
		
		.PARAMETER FilterWMIProperties
			This switch removes WMI properties that start with an underline.
	
		.EXAMPLE
			$DataTable = ConvertTo-DataTable -InputObject (Get-Process)
	#>
	[OutputType([System.Data.DataTable])]
	param (
		[ValidateNotNull()]
		$InputObject,
		[ValidateNotNull()]
		[System.Data.DataTable]$Table,
		[switch]$RetainColumns,
		[switch]$FilterWMIProperties)
	
	if ($null -eq $Table)
	{
		$Table = New-Object System.Data.DataTable
	}
	
	if ($InputObject -is [System.Data.DataTable])
	{
		$Table = $InputObject
	}
	elseif ($InputObject -is [System.Data.DataSet] -and $InputObject.Tables.Count -gt 0)
	{
		$Table = $InputObject.Tables[0]
	}
	else
	{
		if (-not $RetainColumns -or $Table.Columns.Count -eq 0)
		{
			#Clear out the Table Contents
			$Table.Clear()
			
			if ($null -eq $InputObject) { return } #Empty Data
			
			$object = $null
			#find the first non null value
			foreach ($item in $InputObject)
			{
				if ($null -ne $item)
				{
					$object = $item
					break
				}
			}
			
			if ($null -eq $object) { return } #All null then empty
			
			#Get all the properties in order to create the columns
			foreach ($prop in $object.PSObject.Get_Properties())
			{
				if (-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__')) #filter out WMI properties
				{
					#Get the type from the Definition string
					$type = $null
					
					if ($null -ne $prop.Value)
					{
						try { $type = $prop.Value.GetType() }
						catch { Out-Null }
					}
					
					if ($null -ne $type) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
					{
						[void]$table.Columns.Add($prop.Name, $type)
					}
					else #Type info not found
					{
						[void]$table.Columns.Add($prop.Name)
					}
				}
			}
			
			if ($object -is [System.Data.DataRow])
			{
				foreach ($item in $InputObject)
				{
					$Table.Rows.Add($item)
				}
				return @( ,$Table)
			}
		}
		else
		{
			$Table.Rows.Clear()
		}
		
		foreach ($item in $InputObject)
		{
			$row = $table.NewRow()
			
			if ($item)
			{
				foreach ($prop in $item.PSObject.Get_Properties())
				{
					if ($table.Columns.Contains($prop.Name))
					{
						$row.Item($prop.Name) = $prop.Value
					}
				}
			}
			[void]$table.Rows.Add($row)
		}
	}
	
	return @( ,$Table)
}

function Test-Credential
{
<#
	.SYNOPSIS
		Проверяет учетные данные на удаленной машине.

	.DESCRIPTION
		данная функия выводит на экран сообщение что не верны учетные данные для локального админа станции.

	.PARAMETER  $compNAMEorIP
		принимет название компа или IP

	.PARAMETER  $Credentials
		принимаеть те учетные данные которые проверяем.
    .Example
       $result = Test-Credential -compNAMEorIP compName -Credential CompNAMEofIP\accountAdmin Password

    !!!!Work in Domain NetWork!!!
	#>
	
	param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[string]$compNAMEorIP,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]$credentials
	)
	
	$TestPath = "\\" + $compNAMEorIP + "\C$"
	try
	{
		
		New-PSDrive -Name remoteDrive -PSProvider FileSystem -Root $TestPath -Credential $credentials -ErrorAction Stop
		return $true
	}
	catch [System.ComponentModel.Win32Exception]
	{
		return $false
	}
	Remove-PSDrive -Name remoteDrive
}

function Create-Credential
{
<#
	.SYNOPSIS
		Создает тип PSCredential из поступающих переменных.

	.DESCRIPTION
		Создает удобный Credential для логирования на удаленных машинах.

	.PARAMETER  $compNAMEorIP
		принимет название компа или IP

	.PARAMETER  $UserName
		принимаеть имя учетной записи.
    .PARAMETER  $Password
		принимаеть зашифрованый пароль учетной записи.
    .EXAMPLE
		$cred = Create-Credential -compNAMEorIP "192.168.1.1" -UserName "admin" -Password **********
	#>
	[OutputType([System.Management.Automation.PSCredential])]
	param (
		
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[string]$compNAMEorIP,
		[Parameter(Mandatory = $true)]
		[string]$UserName,
		[Parameter(Mandatory = $true)]
		[System.Security.SecureString]$Password
	)
	
	
	$user = $compNAMEorIP + "\" + $UserName
	$credRemove = New-Object –TypeName System.Management.Automation.PSCredential($user, $Password)
	
	return  $credRemove
	
}
function Test-TcpPort
{
<#
	.SYNOPSIS
		Проверяет доступен ли комп по сети.

	.DESCRIPTION
		проверяет доступность по определенному порту.

	.PARAMETER  $IPadress
		принимет IP

	.PARAMETER  $Port
		Проверяймый порт.
    .EXAMPLE
    Test-TcpPort "192.168.1.51"
    Test-TcpPort "192.168.1.51" 3389
	#>
	
	param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[string]$IPadress,
		[ValidateNotNull()]
		[string]$Port = 135
	)
	try
	{
		$TcpClient = New-Object Net.Sockets.TcpClient
		$TcpClient.Connect($IPadress, $Port)
		return $true
	}
	catch [System.Management.Automation.MethodInvocationException]
	{
		return $false
	}
}
<#
53	TCP/UDP	DNS
88	TCP	Kerberos
123	UDP	NTP
135	TCP	RPC
137	UDP	NetBIOS Name Services (NBNS). Translate names to IPs.
139	TCP	NetBIOS Session Services (NBSS). Establish sessions.
389	TCP/UDP	LDAP
445	TCP	SMB
464	TCP	Kerberos Password
593	TCP	RPC over HTTPS
636	TCP	LDAPS
3268	TCP	Global Catalog
3269	TCP	Global Catalog
3389    TCP RDP
5722	TCP	RPC (DFSR)
5785	TCP	WinRM
9389	TCP	Active Directory Web Services
#>
function Format-TimeSpan
{
	process
	{
		"{0:00} d {1:00} h {2:00} m " -f $_.Days, $_.Hours, $_.Minutes
	}
}
function Out-Object
{
	param (
		[System.Collections.Hashtable[]]$hashData
	)
	$order = @()
	$result = @{ }
	$hashData | ForEach-Object {
	$order += ($_.Keys -as [Array])[0]
	$result += $_
	}
	New-Object PSObject -Property $result | Select-Object $order
}