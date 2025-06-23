namespace: ai
flow:
  name: clear_chrome_cache_oas_db_server
  workflow:
    - clear_chrome_data_step:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.26.86"  # AOS Postgres Windows Server IP (postgreswin1)
            - port: '5985'
            - protocol: http
            - username: "administrator"
            - password:
                value: "*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV" # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: |
                # Script to clear Chrome browser cache and data for the current user

                Write-Host "Starting Chrome cache and data clearing process for user $($env:USERNAME)."

                # Attempt to stop Chrome processes
                Write-Host "Attempting to stop Chrome processes..."
                $chromeProcesses = Get-Process chrome -ErrorAction SilentlyContinue
                if ($chromeProcesses) {
                    Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
                    # Check if processes were actually stopped
                    if (Get-Process chrome -ErrorAction SilentlyContinue) {
                        Write-Warning "Failed to stop all Chrome processes. Cache clearing might be incomplete."
                        Start-Sleep -Seconds 2 # Wait a bit anyway
                    } else {
                        Write-Host "Chrome processes stopped."
                        Start-Sleep -Seconds 2 # Give a moment for file locks to release
                    }
                } else {
                    Write-Host "Chrome is not running or no processes found."
                }

                # Define the base path for Chrome user data
                # $env:LOCALAPPDATA typically resolves to C:\Users\<username>\AppData\Local
                $chromeUserDataPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Google\Chrome\User Data"

                # Check if the main Chrome User Data path exists
                if (-not (Test-Path $chromeUserDataPath)) {
                    Write-Warning "Chrome User Data path not found: $chromeUserDataPath. Chrome might not be installed or used by this user."
                    # Exiting with 0 as there's nothing to clear if Chrome isn't set up this way.
                    # CloudSlang will see this as success, which is reasonable.
                    exit 0 
                }

                # Define items to remove. These are relative to $chromeUserDataPath.
                # This list targets the 'Default' profile.
                # It includes common cache directories and browsing data files.
                $itemsToRemoveRelative = @(
                    "Default\Cache",                # Main cache directory
                    "Default\Code Cache",           # JavaScript cache, etc. directory
                    "Default\GPUCache",             # GPU shader cache directory
                    "Default\Media Cache",          # Media cache directory
                    "Default\Application Cache",    # Application cache directory
                    "ShaderCache",                  # General shader cache directory (directly under User Data)
                    "Default\Service Worker\CacheStorage", # Service Worker caches directory
                    "Default\Local Storage",        # Local Storage directory (contains .log and .ldb files)
                    "Default\Session Storage",      # Session Storage directory
                    "Default\IndexedDB",            # IndexedDB directory (databases created by websites)
                    "Default\Cookies",              # Cookies file
                    "Default\Cookies-journal",      # Cookies journal file
                    "Default\History",              # History file
                    "Default\History-journal",      # History journal file
                    "Default\Favicons",             # Favicons file
                    "Default\Favicons-journal",     # Favicons journal file
                    "Default\Visited Links",        # Visited Links file (more common in older Chrome versions)
                    "Default\Web Data",             # Web Data file (site search keywords, some autofill)
                    "Default\Web Data-journal"      # Web Data journal file
                )

                $allOperationsSuccessful = $true
                Write-Host "Targeting items within Chrome profile path: $($chromeUserDataPath)\Default"

                foreach ($relativeItemPath in $itemsToRemoveRelative) {
                    $fullItemPath = Join-Path -Path $chromeUserDataPath -ChildPath $relativeItemPath
                    
                    if (Test-Path $fullItemPath) {
                        Write-Host "Attempting to remove: $fullItemPath"
                        try {
                            # Remove-Item can remove both files and directories.
                            # -Recurse is needed for non-empty directories.
                            # -Force helps with hidden or read-only items.
                            Remove-Item -Path $fullItemPath -Recurse -Force -ErrorAction Stop
                            Write-Host "Successfully removed: $fullItemPath"
                        } catch {
                            Write-Warning "Failed to remove $fullItemPath. Error: $($_.Exception.Message)"
                            $allOperationsSuccessful = $false
                        }
                    } else {
                        Write-Host "Path not found, skipping: $fullItemPath"
                    }
                }

                if ($allOperationsSuccessful) {
                    Write-Host "Chrome cache and data clearing process completed successfully for user $($env:USERNAME)."
                } else {
                    Write-Warning "Chrome cache and data clearing process completed for user $($env:USERNAME) with some issues. Please review warnings above."
                    # Optionally, exit with a non-zero code if partial failure should indicate overall failure
                    # exit 1 
                }

                # Note: Chrome will recreate necessary directories and files on its next launch.
            - trust_all_roots: 'true'   # Common for self-signed certs in test/dev environments
            - x_509_hostname_verifier: allow_all # Common for test/dev environments
        publish:
          - script_output: '${return_result}' # Captures the standard output of the PowerShell script
          - script_error: '${stderr}'        # Captures the standard error stream of the PowerShell script
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - script_output: '${script_output}'
    - script_error: '${script_error}'
  results:
    - SUCCESS
    - FAILURE
