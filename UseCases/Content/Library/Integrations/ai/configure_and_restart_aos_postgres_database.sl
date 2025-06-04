namespace: ai
flow:
  name: configure_and_restart_aos_postgres_database
  workflow:
    - modify_postgres_config_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: '172.31.26.86'  # AOS PostgreSQL IP address
            - port: '5985'
            - protocol: 'http'
            - username: 'administrator' # AOS PostgreSQL username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS PostgreSQL password
                sensitive: true
            - auth_type: 'basic'
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # Path for postgresql-x64-12
                $settingName = "max_locks_per_transaction"
                $settingValue = "10"
                $desiredLine = "$settingName = $settingValue"

                if (Test-Path $configFile) {
                    $content = Get-Content $configFile -Raw
                    $pattern = "^(#\s*)?$($settingName)\s*=.*" # Regex to find the line, commented or not

                    if ($content -match $pattern) {
                        # Setting exists, modify it by replacing the existing line
                        $newContent = $content -replace $pattern, $desiredLine
                    } else {
                        # Setting does not exist, add it to the end of the file
                        # Ensure there's a newline before adding, if file not empty and doesn't end with newline
                        if (($content.Length -gt 0) -and ($content[-1] -ne "`n") -and ($content[-1] -ne "`r")) {
                            $newContent = $content + "`r`n" + $desiredLine
                        } else {
                            $newContent = $content + $desiredLine
                        }
                    }
                    
                    try {
                        # Ensure content ends with a newline for POSIX compatibility / good practice
                        if (($newContent.Length -gt 0) -and ($newContent[-1] -ne "`n") -and ($newContent[-1] -ne "`r")) {
                             $newContent = $newContent + "`r`n"
                        } elseif (($newContent.Length -gt 1) -and ($newContent[-2] -eq "`r") -and ($newContent[-1] -ne "`n")) {
                             # Handles case where content ends with `\r` but not `\r\n`
                             $newContent = $newContent + "`n"
                        }

                        Set-Content -Path $configFile -Value $newContent -Encoding UTF8 -ErrorAction Stop
                        Write-Host "Configuration '$desiredLine' updated in $configFile"
                    } catch {
                        Write-Error "Failed to write to $configFile: $($_.Exception.Message)"
                        exit 1
                    }
                } else {
                    Write-Error "Configuration file not found at $configFile"
                    exit 1 # Exit with error code if file not found
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: 'allow_all'
        publish:
          - config_update_result_aos: '${return_result}'
          - config_update_error_aos: '${stderr}'
        navigate:
          - SUCCESS: restart_postgres_service_aos
          - FAILURE: on_failure

    - restart_postgres_service_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: '172.31.26.86'  # AOS PostgreSQL IP address
            - port: '5985'
            - protocol: 'http'
            - username: 'administrator' # AOS PostgreSQL username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS PostgreSQL password
                sensitive: true
            - auth_type: 'basic'
            - script: "Restart-Service -Name 'postgresql-x64-12'" # AOS PostgreSQL service name
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: 'allow_all'
        publish:
          - service_restart_result_aos: '${return_result}'
          - service_restart_error_aos: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure

  outputs:
    - config_update_result_aos: '${config_update_result_aos}'
    - config_update_error_aos: '${config_update_error_aos}'
    - service_restart_result_aos: '${service_restart_result_aos}'
    - service_restart_error_aos: '${service_restart_error_aos}'

  results:
    - SUCCESS
    - FAILURE
