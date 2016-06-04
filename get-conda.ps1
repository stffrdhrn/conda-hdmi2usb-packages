param(
[string]$CONDA_PATH
)
function CheckLastExitCode {
	param ([int[]]$SuccessCodes = @(0), [scriptblock]$CleanupScript=$null)

	if ($SuccessCodes -notcontains $LastExitCode) {
		if ($CleanupScript) {
			"Executing cleanup script: $CleanupScript"
			&$CleanupScript
		}
		$msg = @"
EXE RETURNED EXIT CODE $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
		throw $msg
	}
}

echo "conda path $CONDA_PATH"

$ARCH = (Get-WmiObject Win32_OperatingSystem -computername localhost).OSArchitecture
if ($ARCH -eq "64-bit") {
	echo "Running on 64-bit Windows.."
	$CONDA_URL = "https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe"
} elseif ($ARCH -eq "32-bit") {
	echo "Running on 32-bit Windows.."
	$CONDA_URL = "https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86.exe"
} else {
	echo "Unknown arch $ARCH"
	exit 1
}

if ((Test-Path "$CONDA_PATH") -eq 0) {
	echo "Downloading $CONDA_URL"
	#(New-Object Net.WebClient).DownloadFile("$CONDA_URL", ".\Miniconda3-latest.exe")
	Start-FileDownload "$CONDA_URL" -FileName ".\Miniconda3-latest.exe"
	dir "."
	if ((Test-Path ".\Miniconda3-latest.exe") -eq 0) {
		Write-Host "Failed to download Miniconda3-latest.exe from $CONDA_URL"
		Exit 1
	}
	Start-Process .\Miniconda3-latest.exe -ArgumentList /S,/NoRegistry=1,/D="$CONDA_PATH" -NoNewWindow -Wait
	echo "Installed conda to $CONDA_PATH"
	dir "$CONDA_PATH"
	dir "$CONDA_PATH\Scripts\"
	if ((Test-Path "$CONDA_PATH") -eq 0) {
		Write-Host "Failed to install conda to $CONDA_PATH"
		Exit 1
	}
}

$env:Path = $env:Path + ";$CONDA_PATH\Scripts\"
echo "Path is now $env:Path"

echo "Conda info"
conda info -a
CheckLastExitCode

echo "Updating conda"
conda update -y conda
CheckLastExitCode

echo "Installing conda-build"
conda install -y conda-build
CheckLastExitCode

echo "Installing anaconda-client"
conda install -y anaconda-client
CheckLastExitCode
