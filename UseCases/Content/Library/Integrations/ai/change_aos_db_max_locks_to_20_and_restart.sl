namespace: ai
flow:
  name: change_aos_db_max_locks_to_20_and_restart
  workflow:
    - modify_aos_postgres_config:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # AOS Postgres IP
            - port: '5985'
            - protocol: http
            - username: administrator  # AOS Postgres username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV'  # AOS Postgres password
                sensitive: true
            - auth_type: basic
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # AOS Postgres config file path
                if (Test-Path $configFile) {
                    (Get-Content $configFile) -replace '^(#?)max_locks_per_transaction\s*=.*', 'max_locks_per_transaction = 20' | Set-Content $configFile
                    Write-Host "Configuration updated: max_locks_per_transaction set to 20 in $configFile"
                } else {
                    Write-Error "Configuration file not found at $configFile"
                    exit 1 # Exit with error code if file not found
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - config_update_result: '${return_result}'
          - config_update_error: '${stderr}'
        navigate:
          - SUCCESS: restart_aos_postgres_service
          - FAILURE: on_failure
    - restart_aos_postgres_service:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # AOS Postgres IP
            - port: '5985'
            - protocol: http
            - username: administrator  # AOS Postgres username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV'  # AOS Postgres password
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'"  # AOS Postgres service name
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - service_restart_result: '${return_result}'
          - service_restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - config_update_result: '${config_update_result}'
    - config_update_error: '${config_update_error}'
    - service_restart_result: '${service_restart_result}'
    - service_restart_error: '${service_restart_error}'
  results:
    - SUCCESS
    - FAILURE
