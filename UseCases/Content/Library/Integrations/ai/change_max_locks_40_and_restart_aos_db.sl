namespace: ai
flow:
  name: change_max_locks_40_and_restart_aos_db
  workflow:
    - modify_postgres_config_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # AOS PostgreSQL server IP (postgreswin1)
            - port: '5985'
            - protocol: http
            - username: administrator # AOS PostgreSQL server username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS PostgreSQL server password
                sensitive: true
            - auth_type: basic
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # AOS PostgreSQL config file path
                if (Test-Path $configFile) {
                    (Get-Content $configFile) -replace '^(#?)max_locks_per_transaction\s*=.*', 'max_locks_per_transaction = 40' | Set-Content $configFile
                    Write-Host "Configuration updated: max_locks_per_transaction set to 40 in $configFile"
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
          - SUCCESS: restart_postgres_service_aos
          - FAILURE: on_failure
    - restart_postgres_service_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # AOS PostgreSQL server IP (postgreswin1)
            - port: '5985'
            - protocol: http
            - username: administrator # AOS PostgreSQL server username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS PostgreSQL server password
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'" # AOS PostgreSQL service name
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
