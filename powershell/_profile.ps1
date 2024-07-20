# Settings
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$global:ProgressPreference = 'SilentlyContinue'

# Modules
Import-Module posh-git
$GitPromptSettings.DefaultPromptBeforeSuffix=[Environment]::NewLine
Import-Module psyml

# Functions
function git-mm {
  param([Parameter(Position=0,Mandatory=$false)]$branch="master")
  git pull
  $current = "$(git branch --show-current)"
  if ($current -ne $branch) {
    git checkout $branch
    git pull
    git checkout $current
    git merge $branch
  }
}

# Filters
filter to-b64 {param([switch]$secure)
	if ($secure) {
		$_ | to-secstr -base64
	} else {
		[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_))
	}
}

filter from-b64 {param([switch]$secure)
	if ($secure) {
		$_ | from-secstr -base64
	} else {
		[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))
	}
}

filter to-secstr {param([switch]$base64)
	$_ | ConvertTo-SecureString -AsPlainText -Force | % {
		if ($base64) { $_ | ConvertFrom-SecureString | to-b64 } else { $_ }
	}
}

filter from-secstr {param([switch]$base64)
	if ($base64) {
		$_ | from-b64 | ConvertTo-SecureString | % {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
	} else {
		$_ 
	}
}

# Aliases
New-Alias -Name python3 -Value python -Force
New-Alias -Name ctj -Value ConvertTo-Json -Force
New-Alias -Name cfj -Value ConvertFrom-Json -Force
New-Alias -Name cty -Value ConvertTo-Yaml -Force
New-Alias -Name cfy -Value ConvertFrom-Yaml -Force
New-Alias -Name kc -Value kubectl -Force
New-Alias -Name to-base64 -Value to-b64 -Force
New-Alias -Name from-base64 -Value from-b64 -Force

# Home dir
cd $env:USERPROFILE
$MY_SECRET="$($env:USERNAME):$($env:TOKEN | from-b64 -s)"
