namespace: ai
flow:
  name: configure_aos_postgres_max_locks_20_and_restart
  workflow:
    - modify_postgres_config_aos:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86 # AOS postgreswin1 IP
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS postgreswin1 password
                sensitive: true
            - auth_type: basic
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # Path for PostgreSQL 12
                if (Test-Path $configFile) {
                    (Get-Content $configFile) -replace '^(#?)max_locks_per_transaction\s*=.*', 'max_locks_per_transaction = 20' | Set-Content -Path $configFile -Force
                    Write-Host "Configuration updated in $configFile: max_locks_per_transaction set to 20."
                } else {
                    Write-Error "Configuration file not found at $configFile"
                    exit 1 # Exit with error code if file not found
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
            - host: 172.31.26.86 # AOS postgreswin1 IP
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS postgreswin1 password
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'" # AOS Postgres service name
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
