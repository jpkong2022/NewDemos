namespace: ai
flow:
  name: restart_aos_database
  workflow:
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
          - restart_result: '${return_result}'
          - restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - restart_result: '${restart_result}'
    - restart_error: '${restart_error}'
  results:
    - SUCCESS
    - FAILURE
