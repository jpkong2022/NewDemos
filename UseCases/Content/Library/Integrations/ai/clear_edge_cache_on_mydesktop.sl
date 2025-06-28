namespace: ai
flow:
  name: clear_edge_cache_on_mydesktop
  workflow:
    - clear_edge_browser_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                # Based on the provided topology, mydesktop and postgreswin1 share the same IP.
                # The password for postgreswin1 is retrieved via get_sp('admin_password').
                # This pattern is used here.
                value: "${get_sp('admin_password')}"
                sensitive: true
            - auth_type: basic
            - script: |
                $user = "jp"
                $cachePath = "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
                if (Test-Path $cachePath) {
                  Write-Host "Attempting to remove cache at $cachePath..."
                  Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                  if ($?) {
                    Write-Host "Successfully cleared Edge cache for user '$user'."
                  } else {
                    Write-Error "Failed to clear Edge cache for user '$user'."
                  }
                } else {
                  Write-Host "Cache path not found for user '$user': $cachePath. No action taken."
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
