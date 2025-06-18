namespace: ai
flow:
  name: manage_aos_application_restart_and_config
  workflow:
    - modify_aos_postgres_config:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.26.86"  # AOS PostgreSQL server: postgreswin1
            - port: '5985'
            - protocol: http
            - username: "administrator"
            - password:
                value: "*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV" # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: |
                $configFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf" # AOS Postgres data directory
                if (Test-Path $configFile) {
                    (Get-Content $configFile) -replace '^(#?)max_locks_per_transaction\s*=.*', 'max_locks_per_transaction = 50' | Set-Content $configFile
                    Write-Host "Configuration updated: max_locks_per_transaction set to 50 in $configFile"
                } else {
                    Write-Error "Configuration file not found at $configFile"
                    exit 1 # Exit with error code if file not found
                }
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - db_config_update_result: '${return_result}'
          - db_config_update_error: '${stderr}'
        navigate:
          - SUCCESS: restart_aos_postgres_service
          - FAILURE: on_failure

    - restart_aos_postgres_service:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.26.86"  # AOS PostgreSQL server: postgreswin1
            - port: '5985'
            - protocol: http
            - username: "administrator"
            - password:
                value: "*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV" # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: |
                Restart-Service -Name 'postgresql-x64-12' # AOS Postgres windows service name
                Write-Host "Service 'postgresql-x64-12' restart initiated."
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - db_service_restart_result: '${return_result}'
          - db_service_restart_error: '${stderr}'
        navigate:
          - SUCCESS: restart_aos_web_server
          - FAILURE: on_failure

    - restart_aos_web_server:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "172.31.54.247"  # AOS Apache web server: apachewin1
            - port: '5985'
            - protocol: http
            - username: "administrator"
            - password:
                value: "31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8" # Password for apachewin1
                sensitive: true
            - auth_type: basic
            - script: |
                Restart-Service -Name 'AOS' # AOS Apache software windows service name
                Write-Host "Service 'AOS' restart initiated."
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - web_service_restart_result: '${return_result}'
          - web_service_restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure

  outputs:
    - db_config_update_result: '${db_config_update_result}'
    - db_config_update_error: '${db_config_update_error}'
    - db_service_restart_result: '${db_service_restart_result}'
    - db_service_restart_error: '${db_service_restart_error}'
    - web_service_restart_result: '${web_service_restart_result}'
    - web_service_restart_error: '${web_service_restart_error}'

  results:
    - SUCCESS
    - FAILURE
