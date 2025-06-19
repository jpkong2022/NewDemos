namespace: ai
flow:
  name: clear_chrome_cache_aos_db_server
  workflow:
    - clear_chrome_cache_step:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # AOS Database Server (postgreswin1) IP
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: |
                # PowerShell script to clear Google Chrome cache for the current user
                Write-Host "Attempting to clear Google Chrome cache for the current user (administrator)..."

                $localAppData = $env:LOCALAPPDATA
                if (-not $localAppData -or $localAppData -eq "") {
                    Write-Error "LocalAppData environment variable not found or empty. Cannot determine Chrome path."
                    exit 1
                }

                $chromeUserDataPath = Join-Path $localAppData "Google\Chrome\User Data"

                if (-not (Test-Path $chromeUserDataPath)) {
                    Write-Host "Google Chrome User Data path not found: $chromeUserDataPath."
                    Write-Host "Chrome might not be installed or used by this user, or the path is incorrect."
                    Write-Host "No cache clearing performed."
                    exit 0 # Not an error, just nothing to do.
                }

                Write-Host "Targeting Chrome User Data Path: $chromeUserDataPath"

                Write-Host "Attempting to close Google Chrome processes to release file locks..."
                # Stop all chrome processes. Using -ErrorAction SilentlyContinue to prevent errors if no process is found.
                Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                # Wait a few seconds to ensure processes are closed before attempting to delete files.
                Start-Sleep -Seconds 3

                # Define cache-related paths to delete
                # Common paths for the Default profile. Other profiles are not targeted.
                $pathsToDelete = @(
                    Join-Path $chromeUserDataPath "Default\Cache",
                    Join-Path $chromeUserDataPath "Default\Code Cache",        # For JavaScript, WebAssembly etc.
                    Join-Path $chromeUserDataPath "Default\GPUCache",
                    Join-Path $chromeUserDataPath "Default\Application Cache", # Older, might still exist
                    Join-Path $chromeUserDataPath "ShaderCache",               # Often directly under User Data
                    Join-Path $chromeUserDataPath "Default\Storage\Cache",     # Cache Storage API
                    Join-Path $chromeUserDataPath "Default\Service Worker\CacheStorage", # Important for PWAs
                    Join-Path $chromeUserDataPath "Default\Media Cache"
                )

                $ErrorEncountered = $false
                $OverallStatusMessage = "Google Chrome Cache Clearing Report for current user:"

                foreach ($path in $pathsToDelete) {
                    if (Test-Path $path) {
                        Write-Host "Attempting to remove: $path"
                        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                        # Short pause and re-check to confirm deletion
                        Start-Sleep -Milliseconds 300 
                        if (Test-Path $path) {
                            Write-Warning "Failed to remove $path. It might be in use, permissions issue, or a junction point."
                            $OverallStatusMessage += "`n - FAILED to remove: $path"
                            $ErrorEncountered = $true
                        } else {
                            Write-Host "Successfully removed $path."
                            $OverallStatusMessage += "`n - Successfully removed: $path"
                        }
                    } else {
                        Write-Host "Path not found, skipping: $path"
                        $OverallStatusMessage += "`n - Not found (skipped): $path"
                    }
                }

                Write-Host "----------------------------------------------------"
                Write-Host $OverallStatusMessage
                Write-Host "----------------------------------------------------"

                if ($ErrorEncountered) {
                    Write-Warning "Google Chrome cache clearing completed with some issues. Please review the log above."
                    # To make the CloudSlang step fail if any part of the cache clearing fails, uncomment the next line:
                    # exit 1 
                } else {
                    Write-Host "Google Chrome cache clearing process completed successfully or no cache found to clear."
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - script_output: '${return_result}'
          - script_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - script_output: '${script_output}'
    - script_error: '${script_error}'
  results:
    - SUCCESS
    - FAILURE
