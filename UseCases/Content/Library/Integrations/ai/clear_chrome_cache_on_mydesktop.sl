namespace: ai
flow:
  name: clear_chrome_cache_on_mydesktop
  workflow:
    - clear_chrome_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                # Per the topology info, the administrator password for the AOS windows server is used here
                value: '31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8'
                sensitive: true
            - auth_type: basic
            - script: |-
                # Stop Chrome processes to release file locks
                Write-Host "Attempting to stop Chrome processes..."
                Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue

                # Path to the main Chrome cache directory for the 'administrator' user
                $cachePath = "C:\Users\administrator\AppData\Local\Google\Chrome\User Data\Default\Cache"

                if (Test-Path $cachePath) {
                    Write-Host "Found cache directory. Removing: $cachePath"
                    Remove-Item -Path $cachePath -Recurse -Force
                    Write-Host "Chrome cache directory has been removed."
                } else {
                    Write-Host "Chrome cache directory not found at $cachePath. No action taken."
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
