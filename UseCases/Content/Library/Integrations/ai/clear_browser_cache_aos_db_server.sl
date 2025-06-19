namespace: ai
flow:
  name: clear_browser_cache_aos_db_server
  workflow:
    - clear_browser_cache_on_postgreswin1:
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
            - script: |
                # Script to clear browser cache for common browsers on Windows
                # Note: For best results, browsers should be closed. This script does not force close them.

                Write-Host "Starting browser cache clearing process..."

                # Get all user profiles, excluding system/default ones
                $userProfiles = Get-ChildItem "C:\Users" -Directory | Where-Object { $_.Name -ne "Public" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" -and (Test-Path "$($_.FullName)\AppData\Local") }

                if ($userProfiles.Count -eq 0) {
                    Write-Warning "No user profiles found in C:\Users to process (excluding Public, Default, Default User)."
                }

                foreach ($userProfile in $userProfiles) {
                    $userName = $userProfile.Name
                    Write-Host "Processing user: $userName"

                    # --- Microsoft Edge (Chromium-based) Cache ---
                    $edgeCachePaths = @(
                        "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default\Cache",
                        "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache",
                        "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default\GPUCache",
                        "C:\Users\$userName\AppData\Local\Microsoft\Edge\User Data\Default\Application Cache"
                    )
                    foreach ($edgeCachePath in $edgeCachePaths) {
                        if (Test-Path $edgeCachePath) {
                            Write-Host "Attempting to clear Edge cache for '$userName' at '$edgeCachePath'"
                            try {
                                Get-ChildItem -Path $edgeCachePath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Host "Successfully cleared Edge cache directory: $edgeCachePath"
                            } catch {
                                Write-Warning "Could not fully clear Edge cache for '$userName' at '$edgeCachePath': $($_.Exception.Message)"
                            }
                        } else {
                            #Write-Host "Edge cache path not found for '$userName': $edgeCachePath"
                        }
                    }

                    # --- Google Chrome Cache ---
                    $chromeCachePaths = @(
                        "C:\Users\$userName\AppData\Local\Google\Chrome\User Data\Default\Cache",
                        "C:\Users\$userName\AppData\Local\Google\Chrome\User Data\Default\Code Cache",
                        "C:\Users\$userName\AppData\Local\Google\Chrome\User Data\Default\GPUCache",
                        "C:\Users\$userName\AppData\Local\Google\Chrome\User Data\Default\Application Cache"
                    )
                    foreach ($chromeCachePath in $chromeCachePaths) {
                        if (Test-Path $chromeCachePath) {
                            Write-Host "Attempting to clear Chrome cache for '$userName' at '$chromeCachePath'"
                            try {
                                Get-ChildItem -Path $chromeCachePath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Host "Successfully cleared Chrome cache directory: $chromeCachePath"
                            } catch {
                                Write-Warning "Could not fully clear Chrome cache for '$userName' at '$chromeCachePath': $($_.Exception.Message)"
                            }
                        } else {
                            #Write-Host "Chrome cache path not found for '$userName': $chromeCachePath"
                        }
                    }

                    # --- Mozilla Firefox Cache ---
                    $firefoxProfilesPath = "C:\Users\$userName\AppData\Local\Mozilla\Firefox\Profiles"
                    if (Test-Path $firefoxProfilesPath) {
                        Get-ChildItem $firefoxProfilesPath -Directory | ForEach-Object {
                            $profilePath = $_.FullName
                            $firefoxCachePaths = @(
                                Join-Path $profilePath "cache2",
                                Join-Path $profilePath "startupCache",
                                Join-Path $profilePath "OfflineCache"
                            )
                            Write-Host "Processing Firefox profile '$($_.Name)' for user '$userName'"
                            foreach ($firefoxCachePath in $firefoxCachePaths) {
                                if (Test-Path $firefoxCachePath) {
                                    Write-Host "Attempting to clear Firefox cache for '$userName' (profile '$($_.Name)') at '$firefoxCachePath'"
                                    try {
                                        Get-ChildItem -Path $firefoxCachePath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                        Write-Host "Successfully cleared Firefox cache directory: $firefoxCachePath"
                                    } catch {
                                        Write-Warning "Could not fully clear Firefox cache for '$userName' (profile '$($_.Name)') at '$firefoxCachePath': $($_.Exception.Message)"
                                    }
                                } else {
                                    #Write-Host "Firefox cache path not found for '$userName' (profile '$($_.Name)'): $firefoxCachePath"
                                }
                            }
                        }
                    } else {
                        #Write-Host "Firefox profiles path not found for '$userName': $firefoxProfilesPath"
                    }

                    # --- Internet Explorer Cache ---
                    # Note: Clearing IE cache thoroughly can be complex. This targets common folders.
                    $ieCachePaths = @(
                        "C:\Users\$userName\AppData\Local\Microsoft\Windows\INetCache", # IE 10+
                        "C:\Users\$userName\AppData\Local\Microsoft\Windows\Temporary Internet Files" # Older IE
                    )
                    foreach ($ieCachePath in $ieCachePaths) {
                        if (Test-Path $ieCachePath) {
                            Write-Host "Attempting to clear Internet Explorer cache for '$userName' at '$ieCachePath'"
                            try {
                                # For INetCache, the content is often in subfolders like 'IE'
                                if ($ieCachePath -like "*INetCache*") {
                                    $ieSubfolders = Get-ChildItem -Path $ieCachePath -Directory -ErrorAction SilentlyContinue
                                    if ($ieSubfolders) {
                                        $ieSubfolders | ForEach-Object {
                                            Write-Host "  Clearing subfolder: $($_.FullName)"
                                            Get-ChildItem -Path $_.FullName -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                        }
                                    } else {
                                         Get-ChildItem -Path $ieCachePath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                    }
                                } else {
                                     Get-ChildItem -Path $ieCachePath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                                }
                                Write-Host "Cleared Internet Explorer cache directory: $ieCachePath"
                            } catch {
                                Write-Warning "Could not fully clear Internet Explorer cache for '$userName' at '$ieCachePath': $($_.Exception.Message)"
                            }
                        } else {
                           #Write-Host "Internet Explorer cache path not found for '$userName': $ieCachePath"
                        }
                    }
                    # Attempt to clear cookies as well, though these are often protected if browser is running
                    $ieCookiePath = "C:\Users\$userName\AppData\Roaming\Microsoft\Windows\Cookies" # Older, use with caution
                    $ieCookiePathModern = "C:\Users\$userName\AppData\Local\Microsoft\Windows\INetCookies" # IE 10+
                    if (Test-Path $ieCookiePathModern) {
                        Write-Host "Attempting to clear IE modern cookies for '$userName' at '$ieCookiePathModern'"
                        try {
                            Get-ChildItem -Path $ieCookiePathModern -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "Cleared IE modern cookies for '$userName'."
                        } catch {
                            Write-Warning "Could not clear IE modern cookies for '$userName': $($_.Exception.Message)"
                        }
                    }
                }
                Write-Host "Browser cache clearing process completed. Check warnings for any issues."
                # A more forceful method for IE, if needed, but can be disruptive:
                # RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2 # Clears Temporary Internet Files
                # RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 # Clears Cookies
                # RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1 # Clears History
                # RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 # Clears All
                # However, running executables with complex arguments directly like this can be tricky in remote PS.
                # Sticking to file deletion is generally safer for unattended scripts.
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
