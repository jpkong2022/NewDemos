namespace: ai
flow:
  name: stop_aos_database_server
  workflow:
    - stop_aos_postgres_service:
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
            - script: "Stop-Service -Name 'postgresql-x64-12'"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - stop_service_result: '${return_result}'
          - stop_service_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - stop_service_result: '${stop_service_result}'
    - stop_service_error: '${stop_service_error}'
  results:
    - SUCCESS
    - FAILURE
