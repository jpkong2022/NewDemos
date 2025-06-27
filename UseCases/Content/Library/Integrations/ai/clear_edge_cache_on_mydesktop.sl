namespace: ai
flow:
  name: clear_edge_cache_on_mydesktop
  workflow:
    - clear_edge_cache:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.26.86
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "${get_sp('admin_password')}"
                sensitive: true
            - auth_type: basic
            - script: "
# Stop Edge processes to release file locks to prevent errors
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue

# Path to the Edge User Data folder for the current user
$edgeUserDataPath = \"$env:LOCALAPPDATA\\Microsoft\\Edge\\User Data\\Default\"

# Array of cache-related folders to clear
$cacheFolders = @(
    \"$edgeUserDataPath\\Cache\",
    \"$edgeUserDataPath\\Code Cache\",
    \"$edgeUserDataPath\\GPUCache\"
)

# Iterate over the folders and remove them if they exist
foreach ($folder in $cacheFolders) {
    if (Test-Path $folder) {
        Write-Host \"Removing directory: $folder\"
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host \"Directory not found, skipping: $folder\"
    }
}
Write-Host \"Edge browser cache clearing process completed.\"
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
