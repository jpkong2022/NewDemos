namespace: ai
flow:
  name: clear_edge_cache_user_jp_on_mydesktop
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
            - script: "$userProfile = 'jp'
$cachePath = \"C:\\Users\\$userProfile\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache\"
if (Test-Path $cachePath) {
    Write-Host \"Attempting to clear Edge cache for user '$userProfile' at path: $cachePath\"
    # Stop Edge process to release file locks
    Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force
    # Give it a moment to release handles
    Start-Sleep -Seconds 2
    try {
        Remove-Item -Path \"$cachePath\\*\" -Recurse -Force -ErrorAction Stop
        Write-Host \"Successfully cleared Edge cache for user '$userProfile'.\"
    } catch {
        Write-Error \"Failed to clear Edge cache for user '$userProfile'. Error: $_\"
        exit 1
    }
} else {
    Write-Error \"Edge cache path not found for user '$userProfile'. Path checked: $cachePath\"
    exit 1
}"
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
