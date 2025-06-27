namespace: ai
flow:
  name: clear_edge_cache_mydesktop1
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - username: administrator
            - password:
                value: "get_sp('admin_password')"
                sensitive: true
            - auth_type: basic
            - script: |
                # Forcefully stop the Microsoft Edge process to release file locks
                Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue

                # Define the path to the Edge cache directory using environment variables for reliability
                $edgeCachePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Edge\User Data\Default\Cache"

                # Check if the cache directory exists and clear it
                if (Test-Path $edgeCachePath) {
                    Write-Host "Edge cache directory found at $edgeCachePath. Clearing contents..."
                    Get-ChildItem -Path $edgeCachePath -Recurse | Remove-Item -Force -Recurse
                    Write-Host "Microsoft Edge cache has been cleared."
                } else {
                    Write-Host "Microsoft Edge cache directory not found. No action taken."
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
