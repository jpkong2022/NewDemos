namespace: ai
flow:
  name: restart_aos_servers
  workflow:
    - restart_aos_web_server:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.54.247
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: '31lGg&d%Dv-it.A8muSGzIH&ezg6Gz=8'
                sensitive: true
            - auth_type: basic
            - script: "Restart-Service -Name 'AOS'"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - aos_web_restart_result: '${return_result}'
          - aos_web_restart_error: '${stderr}'
        navigate:
          - SUCCESS: restart_aos_db_server
          - FAILURE: on_failure
    - restart_aos_db_server:
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
          - aos_db_restart_result: '${return_result}'
          - aos_db_restart_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - aos_web_restart_result: '${aos_web_restart_result}'
    - aos_web_restart_error: '${aos_web_restart_error}'
    - aos_db_restart_result: '${aos_db_restart_result}'
    - aos_db_restart_error: '${aos_db_restart_error}'
  results:
    - SUCCESS
    - FAILURE
