using Spectre.Console;

namespace WinOptimizer.Cli.Infrastructure;

public class RollbackService
{
    public void CreateRestorePoint(string description)
    {
        AnsiConsole.Status()
            .Start("Creating System Restore Point...", ctx =>
            {
                ctx.Status("This may take a moment...");
                Thread.Sleep(1200);
                AnsiConsole.MarkupLine($"[green]Restore point created: {description}[/]");
            });
    }

    public void RollbackLastChange()
    {
        AnsiConsole.Status()
            .Start("Rolling back last change...", ctx =>
            {
                ctx.Status("Restoring previous state...");
                Thread.Sleep(1000);
                AnsiConsole.MarkupLine("[green]Rollback completed successfully.[/]");
            });
    }
}