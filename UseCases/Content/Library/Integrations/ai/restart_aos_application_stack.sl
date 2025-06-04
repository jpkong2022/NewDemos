namespace: ai
flow:
  name: restart_aos_application_stack
  workflow:
    - restart_aos_db_server:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86  # postgreswin1 IP address
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV" # Password for postgreswin1
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'postgresql-x64-12'" # Postgres windows service name for AOS
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - db_restart_result: '${return_result}'
          - db_restart_error: '${stderr}'
        navigate:
          - SUCCESS: restart_aos_web_server
          - FAILURE: on_failure

    - restart_aos_web_server:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.54.247  # apachewin1 IP address
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8" # Password for apachewin1
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'AOS'" # Apache software windows service name for AOS
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - web_restart_result: '${return_result}'
          - web_restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure

  outputs:
    - db_restart_result: '${db_restart_result}'
    - db_restart_error: '${db_restart_error}'
    - web_restart_result: '${web_restart_result}'
    - web_restart_error: '${web_restart_error}'

  results:
    - SUCCESS
    - FAILURE
