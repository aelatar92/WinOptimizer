@{
    RootModule        = 'WinOptimizer.psm1'
    ModuleVersion     = '2.2.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'  # Generate new GUID later
    Author            = 'Abdelrahman Mohamed Elatar'
    CompanyName       = 'Personal Project'
    Copyright         = '(c) 2026 Abdelrahman Elatar. All rights reserved.'
    Description       = 'WinOptimizer - Advanced Windows Maintenance & Optimization Toolkit. Interactive menu with smart diagnostics, rollback, and profiles.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Start-WinOptimizer',
        'Get-WinOptSystemProfile',
        'Get-WinOptHealthScore',
        'Invoke-WinOptCleanup',
        'New-WinOptRestorePoint'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData = @{
        PSData = @{
            Tags         = @('Windows', 'Optimization', 'Maintenance', 'Diagnostics', 'Cleanup')
            LicenseUri   = 'https://github.com/aelatar92/WinOptimizer/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/aelatar92/WinOptimizer'
            ReleaseNotes = 'https://github.com/aelatar92/WinOptimizer/blob/main/CHANGELOG.md'
        }
    }
}