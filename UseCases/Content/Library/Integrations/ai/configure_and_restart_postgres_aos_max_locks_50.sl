namespace: ai
flow:
  name: configure_and_restart_postgres_aos_max_locks_50
  workflow:
    - modify_postgres_config_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV'
                sensitive: true
            - auth_type: basic
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # Path to postgresql.conf
                if (Test-Path $configFile) {
                    (Get-Content $configFile) -replace '^(#?)max_locks_per_transaction\s*=.*', 'max_locks_per_transaction = 50' | Set-Content $configFile
                    Write-Host "Configuration updated: max_locks_per_transaction set to 50 in $configFile"
                } else {
                    Write-Error "Configuration file not found at $configFile"
                    exit 1 # Exit  with error code if file not found
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - config_update_result_aos: '${return_result}'
          - config_update_error_aos: '${stderr}'
        navigate:
          - SUCCESS: restart_postgres_service_aos
          - FAILURE: on_failure
    - restart_postgres_service_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV'
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
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
