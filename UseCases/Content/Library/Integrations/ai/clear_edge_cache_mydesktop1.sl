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
                value: "get_sp('admin_password')"
                sensitive: true
            - auth_type: basic
            - script: |
                $userProfile = "jp"
                $cachePaths = @(
                    "C:\Users\$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache",
                    "C:\Users\$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache",
                    "C:\Users\$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\GPUCache"
                )
                
                foreach ($path in $cachePaths) {
                    if (Test-Path $path) {
                        Write-Host "Clearing cache at: $path"
                        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "Successfully cleared: $path"
                    } else {
                        Write-Host "Cache path not found, skipping: $path"
                    }
                }
                Write-Host "Edge cache clearing process completed for user $userProfile."
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - clear_cache_output: '${return_result}'
          - clear_cache_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - clear_cache_output: '${clear_cache_output}'
    - clear_cache_error: '${clear_cache_error}'
  results:
    - SUCCESS
    - FAILURE
