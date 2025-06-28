namespace: ai
flow:
  name: clear_edge_cache_jp_on_mydesktop1
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
                $userName = 'jp'
                $edgeCachePath = "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
                
                if (Test-Path -Path $edgeCachePath) {
                    try {
                        Remove-Item -Path "$edgeCachePath\*" -Recurse -Force -ErrorAction Stop
                        Write-Host "Successfully cleared Edge browser cache for user '$userName'."
                    } catch {
                        Write-Error "An error occurred while clearing the cache for user '$userName'. Error: $_"
                        exit 1
                    }
                } else {
                    Write-Host "Cache path for user '$userName' not found at '$edgeCachePath'. No action taken."
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
