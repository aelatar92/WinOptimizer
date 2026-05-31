using Spectre.Console;

namespace WinOptimizer.Cli.Features;

public class StartupManagerFeature
{
    public void Run()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold magenta]Startup Programs Manager[/]");
        AnsiConsole.Write(rule);

        // Simulated live loading
        AnsiConsole.Status()
            .Start("Scanning startup items...", ctx =>
            {
                ctx.Status("Reading registry...");
                Thread.Sleep(600);
                ctx.Status("Reading Task Scheduler...");
                Thread.Sleep(500);
                ctx.Status("Analyzing results...");
                Thread.Sleep(400);
            });

        // Display sample data in a table
        var table = new Table()
            .Border(TableBorder.Rounded)
            .Title("[yellow]Startup Items[/]")
            .AddColumn("Name")
            .AddColumn("Location")
            .AddColumn("Status");

        table.AddRow("OneDrive", "HKCU\\Run", "[green]Enabled[/]");
        table.AddRow("Discord", "HKCU\\Run", "[green]Enabled[/]");
        table.AddRow("Spotify", "HKCU\\Run", "[red]Disabled[/]");

        AnsiConsole.Write(table);

        AnsiConsole.MarkupLine("\n[grey]Note: This is a simulated view. Real implementation coming in next iterations.[/]");
    }
}