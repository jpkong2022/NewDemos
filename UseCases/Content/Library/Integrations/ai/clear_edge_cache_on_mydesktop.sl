namespace: ai
flow:
  name: clear_edge_cache_on_mydesktop
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8'
                sensitive: true
            - auth_type: basic
            - script: |
                # Stop any running Microsoft Edge processes to release file locks
                Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
                
                # Path to the default Edge profile cache
                $edgeCachePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
                
                # Check if the cache directory exists and then remove it
                if (Test-Path $edgeCachePath) {
                    Write-Host "Found Edge cache at $edgeCachePath. Clearing..."
                    Remove-Item -Path $edgeCachePath -Recurse -Force
                    Write-Host "Edge browser cache cleared successfully."
                } else {
                    Write-Host "Edge cache directory not found at $edgeCachePath. No action taken."
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
