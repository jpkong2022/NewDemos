namespace: ai
flow:
  name: clear_edge_cache_jp_on_mydesktop
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
                $cachePath = "C:\Users\jp\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
                if (Test-Path $cachePath) {
                    Write-Host "Clearing Edge cache for user 'jp' at path: $cachePath"
                    Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                    if ($?) {
                        Write-Host "Successfully cleared Edge cache for user 'jp'."
                    } else {
                        Write-Error "Failed to clear some items in Edge cache for user 'jp'."
                    }
                } else {
                    Write-Host "Cache path for user 'jp' not found. Nothing to clear."
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
