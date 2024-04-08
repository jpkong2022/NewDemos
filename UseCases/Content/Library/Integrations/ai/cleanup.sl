namespace:ai
  name: cleanup
  description: "Clean up the /tmp directory on a Linux server"
  inputs:
    - name: host
      type: String
      description: "The IP address or hostname of the Linux server"
      required: true
    - name: username
      type: String
      description: "SSH username to connect to the Linux server"
      required: true
    - name: password
      type: SecureString
      description: "SSH password"
      required: true

  steps:
    - name: ssh_cleanup
      description: "Run SSH command to clean up /tmp directory"
      type: remote
      action: ssh.runCommand
      inputs:
        host: ${host}
        port: 22
        username: ${username}
        password: ${password}
        command: "sudo rm -rf /tmp/*"

  results:
    - name: success
      description: "Cleanup of /tmp directory completed successfully"
    - name: failure
      description: "Failed to cleanup /tmp directory"
