namespace: ai
flow:
  name: clear_edge_cache_aos_db_server
  workflow:
    - clear_edge_cache_on_postgreswin1:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.26.86"
            - port: '5985'
            - protocol: "http"
            - username: "administrator"
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV'
                sensitive: true
            - auth_type: "basic"
            - script: |
                # Stop Microsoft Edge processes to release file locks
                Write-Host "Attempting to stop Microsoft Edge processes..."
                Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
                Write-Host "Microsoft Edge processes stop attempt completed."

                $userProfile = $env:USERPROFILE
                $edgeUserDataBasePath = Join-Path -Path $userProfile -ChildPath "AppData\Local\Microsoft\Edge\User Data"

                if (-not (Test-Path $edgeUserDataBasePath)) {
                    Write-Host "Microsoft Edge user data path not found: $edgeUserDataBasePath. Assuming Edge is not installed or has no user data for $env:USERNAME."
                    exit 0 # Successfully did nothing, this is not an error state for this script's purpose.
                }

                $defaultProfilePath = Join-Path -Path $edgeUserDataBasePath -ChildPath "Default"

                if (-not (Test-Path $defaultProfilePath)) {
                    Write-Warning "Microsoft Edge Default profile path not found: $defaultProfilePath. Cache not cleared for Default profile."
                    # Exiting 0 as the script's goal is to clear cache IF it exists. Missing profile is not a script failure.
                    exit 0 
                }

                Write-Host "Targeting Edge profile: $defaultProfilePath for user $env:USERNAME"

                # Define cache items (directories/files) to be cleared
                $cacheItemsToClear = @(
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Cache\*"; Type = "Content" },
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Code Cache\*"; Type = "Content" },
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "GPUCache\*"; Type = "Content" },
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Application Cache\*"; Type = "Content" }, # Older cache type
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Service Worker\CacheStorage\*"; Type = "Content" },
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "IndexedDB\*"; Type = "Content" }, 
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Local Storage\*"; Type = "Content" }, 
                    @{ PathExpression = Join-Path -Path $defaultProfilePath -ChildPath "Media Cache\*"; Type = "Content" }
                    # Note: History, Cookies, Bookmarks etc. are intentionally not part of this "cache clearing" script.
                )

                $itemsEffectivelyRemoved = $false
                $errorsEncountered = $false
                $errorMessages = [System.Collections.Generic.List[string]]::new()

                foreach ($itemToClear in $cacheItemsToClear) {
                    $itemPath = $itemToClear.PathExpression
                    # Check if the parent directory exists before trying to get children
                    $parentDir = Split-Path -Path $itemPath
                    if (Test-Path $parentDir) {
                        Write-Host "Attempting to clear items matching: $itemPath"
                        try {
                            # Get items matching the expression (e.g., contents of a Cache directory)
                            $foundItems = Get-ChildItem -Path $itemPath -Recurse -Force -ErrorAction SilentlyContinue
                            if ($foundItems) {
                                $foundItems | Remove-Item -Recurse -Force -ErrorAction Stop
                                Write-Host "Successfully cleared items matching: $itemPath"
                                $itemsEffectivelyRemoved = $true
                            } else {
                                Write-Host "No items found matching $itemPath to clear."
                            }
                        } catch {
                            $errMsg = "Could not clear items matching $itemPath. Error: $($_.Exception.Message)"
                            Write-Warning $errMsg
                            $errorMessages.Add($errMsg)
                            $errorsEncountered = $true
                        }
                    } else {
                        Write-Host "Parent directory not found for $itemPath, skipping."
                    }
                }

                if ($errorsEncountered) {
                    Write-Error "Microsoft Edge cache clearing process for user $env:USERNAME encountered errors."
                    Write-Error ("Errors: " + ($errorMessages -join [environment]::NewLine))
                    exit 1 # Indicate failure
                }

                if ($itemsEffectivelyRemoved) {
                    Write-Host "Microsoft Edge cache clearing process completed for user $env:USERNAME. Some cache items were removed."
                } else {
                    Write-Host "Microsoft Edge cache clearing process completed for user $env:USERNAME. No existing cache items found/removed based on defined paths."
                }
                exit 0 # Indicate success
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: "allow_all"
        publish:
          - script_output: '${return_result}' # Stdout from the script
          - script_error: '${stderr}'       # Stderr from the script
          - return_code: '${return_code}'   # Exit code of the script
        navigate:
          - SUCCESS: SUCCESS # Navigates here if powershell_script operation is successful (typically script exit code 0)
          - FAILURE: on_failure # Navigates here if powershell_script operation fails (e.g. connection issue, or script exit code non-zero)
  outputs:
    - script_output: '${script_output}'
    - script_error: '${script_error}'
    - script_return_code: '${return_code}'
  results:
    - SUCCESS
    - FAILURE
