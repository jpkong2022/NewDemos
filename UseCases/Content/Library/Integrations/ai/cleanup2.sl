namespace: ai
flow:
 name: cleanup2
  inputs:
  - token
  - host
  - sshUsername
  - sshPassword
 workflow:
 - ssh_command:
    do:
      io.cloudslang.base.ssh.ssh_command:
        - host: '${host}'
        - command: "rm -rf /tmp/*"
        - username: '${sshUsername}'
        - password:
            value: '${sshPassword}'
            sensitive: true
    publish:
      - result: '${return_result}'
     navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
 outputs:
  - json: '${json}'
 results:
  - FAILURE
  - SUCCESS]