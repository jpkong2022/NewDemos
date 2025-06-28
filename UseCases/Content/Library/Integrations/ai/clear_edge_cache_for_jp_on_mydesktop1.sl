namespace: ai
flow:
  name: clear_edge_cache_for_jp_on_mydesktop1
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "${get_sp('admin_password')}"
                sensitive: true
            - auth_type: basic
            - script: |
                $userName = 'jp'
                $edgeProfilePath = "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default"

                if (Test-Path $edgeProfilePath) {
                    # Attempt to stop Microsoft Edge processes to release file locks. This requires admin rights.
                    Write-Host "Attempting to stop Microsoft Edge processes..."
                    Get-Process -Name "msedge" -ErrorAction SilentlyContinue | Stop-Process -Force

                    # Wait a moment for processes to terminate
                    Start-Sleep -Seconds 3

                    # Define cache-related paths
                    $cachePaths = @(
                        Join-Path $edgeProfilePath "Cache",
                        Join-Path $edgeProfilePath "Code Cache",
                        Join-Path $edgeProfilePath "GPUCache",
                        Join-Path $edgeProfilePath "Service Worker\CacheStorage"
                    )

                    foreach ($path in $cachePaths) {
                        if (Test-Path $path) {
                            Write-Host "Clearing cache at: $path"
                            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                        } else {
                            Write-Host "Cache path not found, skipping: $path"
                        }
                    }
                    Write-Host "Microsoft Edge cache clearing process completed for user '$userName'."
                } else {
                    Write-Error "Microsoft Edge profile path for user '$userName' not found at '$edgeProfilePath'."
                    exit 1
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
