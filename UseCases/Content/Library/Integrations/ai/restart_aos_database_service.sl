namespace: ai
flow:
  name: restart_aos_database_service
  workflow:
    - restart_aos_db_windows_service:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86 # AOS PostgreSQL server IP
            - port: '5985'         # Default WinRM HTTP port
            - protocol: http       # Default WinRM protocol
            - username: administrator # AOS PostgreSQL server username
            - password:
                value: '*9SG4-YBv&ANu%F?5%BlQszZ=ZX703nV' # AOS PostgreSQL server password
                sensitive: true
            - auth_type: basic     # Authentication type
            - script: "Restart-Service -Name 'postgresql-x64-12'" # AOS PostgreSQL service name
            - trust_all_roots: 'true' # Set to false in production unless necessary and understood
            - x_509_hostname_verifier: allow_all # Set to strict in production
        publish:
          - service_restart_output: '${return_result}' # Output of the PowerShell script
          - service_restart_error: '${stderr}'        # Any error output from the script
        navigate:
          - SUCCESS: SUCCESS # On successful execution, go to the flow's SUCCESS result
          - FAILURE: on_failure # On failure, trigger the on_failure handling (maps to flow's FAILURE)
  outputs:
    - service_restart_output: '${service_restart_output}'
    - service_restart_error: '${service_restart_error}'
  results:
    - SUCCESS # Define a SUCCESS result for the flow
    - FAILURE # Define a FAILURE result for the flow
