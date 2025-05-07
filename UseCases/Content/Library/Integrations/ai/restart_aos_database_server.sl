namespace: ai
flow:
  name: restart_aos_database_server
  workflow:
    - restart_aos_postgres_service:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # IP address of postgreswin1 (AOS Postgres server)
            - port: '5985'
            - protocol: http
            - username: administrator # Username for postgreswin1
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'" # Postgres service name on AOS postgreswin1
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - service_restart_result: '${return_result}'
          - service_restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - service_restart_result: '${service_restart_result}'
    - service_restart_error: '${service_restart_error}'
  results:
    - SUCCESS
    - FAILURE
