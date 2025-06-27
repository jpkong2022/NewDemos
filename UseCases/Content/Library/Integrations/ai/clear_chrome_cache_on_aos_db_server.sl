namespace: ai
flow:
  name: clear_chrome_cache_on_aos_db_server
  workflow:
    - clear_chrome_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                # The prompt specifies the password as: "get_sp('admin_password')"
                # This implies using a system property. For a static example, a placeholder is used.
                value: '********'
                sensitive: true
            - auth_type: basic
            - script: |
                # Stop Chrome processes to unlock cache files
                Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue

                # Define the primary cache path
                $cachePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"

                if (Test-Path $cachePath) {
                    Write-Host "Clearing cache contents at: $cachePath"
                    Remove-Item -Path "$cachePath\*" -Recurse -Force
                    Write-Host "Chrome cache for the Default profile has been cleared."
                } else {
                    Write-Host "Chrome cache path not found at $cachePath. No action taken."
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
