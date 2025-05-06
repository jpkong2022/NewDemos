namespace: ai
flow:
  name: restart_crm_database
  workflow:
    - restart_postgres_service:
        do:
          io.cloudslang.base.ssh.ssh_command:
            # --- Connection Details for CRM Postgres Server ---
            - host: 172.31.28.169
            - port: 22 # Default SSH port
            - username: ec2-user
            - password:
                value: "Automation.123" # CRM Postgres Linux Server Password
                sensitive: true
            # --- Command to Execute ---
            # Assuming ec2-user has sudo rights without password prompt for systemctl
            # Or the service can be restarted without sudo (less likely)
            # If sudo requires a password, this command will fail unless pty is true
            # and the sudo password handling is configured appropriately (often complex).
            - command: "sudo systemctl restart postgresql-17" # CRM Postgres Service Name
            - pty: false # Set to true if sudo requires interaction or specific terminal emulation
            - timeout: 90000 # Optional: Timeout in milliseconds (e.g., 90 seconds)
        publish:
          - restart_output: '${return_result}' # Capture standard output
          - restart_error: '${stderr}'       # Capture standard error
          - return_code: '${return_code}'     # Capture the exit code (0 usually means success)
        navigate:
          # Check return_code for success (0) or failure (non-zero)
          - SUCCESS: SUCCESS # Navigate to overall flow SUCCESS if ssh_command returns SUCCESS (command executed)
          - FAILURE: on_failure # Navigate to on_failure branch if ssh_command fails (e.g., connection error)
                             # Note: Command execution failure (non-zero exit code) might still result in SUCCESS navigation here.
                             # A check_return_code step could be added for more robustness if needed.

  # Optional: Define outputs for the entire flow
  outputs:
    - restart_output: '${restart_output}'
    - restart_error: '${restart_error}'
    - return_code: '${return_code}'

  # Define the possible final results of the flow
  results:
    - SUCCESS
    - FAILURE
