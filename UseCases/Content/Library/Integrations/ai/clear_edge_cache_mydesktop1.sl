namespace: ai
flow:
  name: clear_edge_cache_mydesktop1
  workflow:
    - clear_edge_cache_for_user_jp:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "get_sp('admin_password')"
            - auth_type: basic
            - script: |
                $user = "jp"
                $edgeCachePath = "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
                if (Test-Path $edgeCachePath) {
                    Write-Host "Found Edge cache for user '$user'. Path: $edgeCachePath. Clearing cache..."
                    Remove-Item -Path "$edgeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "Edge cache clearing process completed for user '$user'."
                } else {
                    Write-Error "Edge cache path not found for user '$user'. Path does not exist: $edgeCachePath"
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
