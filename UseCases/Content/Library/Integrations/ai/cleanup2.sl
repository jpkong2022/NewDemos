namespace: ai

inputs:
  - host
  - username
  - password

flow:
  name: cleanup2
  workflow:
    - ssh_command:
        command: "rm -rf /tmp/*"
        host: "${host}"
        username: "${username}"
        password: "${password}"
   navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  results:
    - FAILURE
    - SUCCESS
