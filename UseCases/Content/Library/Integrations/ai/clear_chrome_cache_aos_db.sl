namespace: ai
flow:
  name: clear_chrome_cache_aos_db
  workflow:
    - clear_browser_cache_step:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.26.86"  # AOS Postgres Windows Server IP
            - port: '5985'
            - protocol: http
            - username: "administrator"
            - password:
                value: "*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV" # Password for AOS Postgres Windows Server
                sensitive: true
            - auth_type: basic
            - script: |
                # Attempt to close Chrome processes to release file locks
                Write-Host "Attempting to stop Chrome processes..."
                Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5 # Give some time for processes to terminate

                # Define Chrome cache directories for the 'administrator' user
                $userProfile = "C:\Users\administrator" # Explicitly using administrator profile
                $chromeBasePath = Join-Path $userProfile "AppData\Local\Google\Chrome\User Data\Default"

                $cacheDir = Join-Path $chromeBasePath "Cache"
                $codeCacheDir = Join-Path $chromeBasePath "Code Cache"
                $gpuCacheDir = Join-Path $chromeBasePath "GPUCache"
                $mediaCacheDir = Join-Path $chromeBasePath "Media Cache"
                # Service Worker cache can also be significant
                $serviceWorkerCacheDir = Join-Path $chromeBasePath "Service Worker\CacheStorage" 

                $dirsToClear = @(
                    $cacheDir, 
                    $codeCacheDir, 
                    $gpuCacheDir, 
                    $mediaCacheDir,
                    $serviceWorkerCacheDir
                )

                $errorsOccurred = $false
                $summary = "Chrome Cache Cleaning Report for user 'administrator':`n"
                $summary += "----------------------------------------------------`n"

                foreach ($dir in $dirsToClear) {
                    if (Test-Path $dir) {
                        $summary += "Targeting: $dir`n"
                        try {
                            # Get child items and remove them.
                            Get-ChildItem -Path $dir -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Stop
                            
                            # Verify if directory is empty
                            if ((Get-ChildItem -Path $dir -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                                $summary += "  Status: Successfully cleared or was already empty.`n"
                            } else {
                                $summary += "  Status: Cleared some items, but directory is not empty. Some files might be locked or inaccessible.`n"
                            }
                        } catch {
                            $summary += "  Status: ERROR - $($_.Exception.Message)`n"
                            $errorsOccurred = $true
                        }
                    } else {
                        $summary += "Targeting: $dir`n  Status: Directory not found.`n"
                    }
                    $summary += "`n" # Add a blank line for readability between directory reports
                }

                $summary += "----------------------------------------------------`n"
                if ($errorsOccurred) {
                    $summary += "Overall Result: Chrome cache clearing process completed with one or more errors."
                    # The full summary goes to stdout (return_result)
                    Write-Host $summary 
                    exit 1
                } else {
                    $summary += "Overall Result: Chrome cache clearing process completed successfully for all targeted directories."
                    Write-Host $summary
                    exit 0
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - script_output: '${return_result}' # Contains the full summary from Write-Host
          - script_error: '${stderr}'         # Contains any messages written to error stream by PowerShell
          - script_exit_code: '${return_code}' # Script's exit code (0 for success, 1 for failure as per script logic)
        navigate:
          - SUCCESS: SUCCESS # CloudSlang operation executed successfully (connected and ran script)
          - FAILURE: on_failure # CloudSlang operation failed (e.g., connection issue, auth failure)

  outputs:
    - operation_summary: '${script_output}'
    - operation_errors: '${script_error}' 
    - script_final_status: '${script_exit_code}' # Exit code from the PowerShell script (0 or 1)

  results:
    - SUCCESS
    - FAILURE
