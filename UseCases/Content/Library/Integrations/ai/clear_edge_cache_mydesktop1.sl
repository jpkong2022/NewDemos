namespace: ai
flow:
  name: clear_edge_cache_mydesktop1
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8"
                sensitive: true
            - auth_type: basic
            - script: |
                # Stop Microsoft Edge processes to release file locks
                Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue

                # Path to the Edge cache directory for user 'jp'
                $cachePath = "C:\Users\jp\AppData\Local\Microsoft\Edge\User Data\Default\Cache"

                if (Test-Path $cachePath) {
                    Write-Host "Edge cache directory for user 'jp' found. Clearing contents..."
                    # Get all child items (files and folders) in the cache directory and remove them
                    Get-ChildItem -Path $cachePath -Recurse | Remove-Item -Force -Recurse
                    Write-Host "Successfully cleared Edge cache for user 'jp'."
                } else {
                    Write-Error "Edge cache directory not found for user 'jp' at path: $cachePath"
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
