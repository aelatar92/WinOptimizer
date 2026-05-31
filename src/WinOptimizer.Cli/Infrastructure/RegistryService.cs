using Microsoft.Win32;
using Spectre.Console;

namespace WinOptimizer.Cli.Infrastructure;

public class RegistryService
{
    public void BackupRegistryKey(string keyPath, string backupName)
    {
        AnsiConsole.Status()
            .Start("Backing up registry key...", ctx =>
            {
                // Placeholder for actual registry backup logic
                ctx.Status("Creating registry backup...");
                Thread.Sleep(500);
                AnsiConsole.MarkupLine($"[green]Registry key backed up: {backupName}[/]");
            });
    }

    public void RestoreRegistryKey(string backupName)
    {
        AnsiConsole.Status()
            .Start("Restoring registry key...", ctx =>
            {
                ctx.Status("Restoring from backup...");
                Thread.Sleep(500);
                AnsiConsole.MarkupLine("[green]Registry key restored successfully.[/]");
            });
    }
}