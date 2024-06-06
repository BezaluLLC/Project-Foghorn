Get-DynamicVersionsFromGitHubUrl `
    -GitHubReleasesUrl "$Git_Repo/releases" `
    -VersionsPattern ('(?<Uri>'+$Git_Repo+'/releases/download/v(?<Version>[\d\.]+)/(?<FileName>rewst_agent_config.win.exe))')

    # v(?<Version>[\d\.]+)/(?<FileName>rewst_agent_config.win.exe)
