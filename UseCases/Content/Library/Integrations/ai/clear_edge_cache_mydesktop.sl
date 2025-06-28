namespace: ai
flow:
  name: clear_edge_cache_mydesktop
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "get_sp('admin_password')"
                sensitive: true
            - auth_type: basic
            - script: "
# Stop Microsoft Edge processes to release file locks
Stop-Process -Name \"msedge\" -Force -ErrorAction SilentlyContinue

# Define the path to the Edge cache directory for user 'jp'
$cachePath = \"C:\\Users\\jp\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache\"

# Check if the directory exists
if (Test-Path $cachePath) {
    # Remove the contents of the cache directory
    Write-Host \"Attempting to clear cache at: $cachePath\"
    Remove-Item -Path \"$cachePath\\*\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host \"Edge cache cleared for user jp.\"
} else {
    Write-Host \"Edge cache path for user jp not found: $cachePath\"
}
"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - script_output: '${return_result}'
          - script_error: '${stderr}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - script_output: '${script_output}'
    - script_error: '${script_error}'
  results:
    - SUCCESS
    - FAILURE
