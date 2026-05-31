using Spectre.Console;
using WinOptimizer.Cli.Core;

namespace WinOptimizer.Cli.Features;

public class HealthCheckFeature
{
    public async Task RunAsync()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold cyan]System Health Check[/]");
        AnsiConsole.Write(rule);
        
        var scanner = new SystemScanner();
        
        var results = await AnsiConsole.Status()
            .StartAsync("Performing live system scan...", async ctx =>
            {
                var progress = new Progress<string>(status => 
                {
                    ctx.Status(status);
                });
                
                return await scanner.ScanSystemAsync(progress);
            });

        // Display results in a nice table
        var table = new Table()
            .Border(TableBorder.Rounded)
            .AddColumn("Component")
            .AddColumn("Value");

        foreach (var item in results)
        {
            table.AddRow(item.Key, item.Value.ToString() ?? "N/A");
        }

        AnsiConsole.Write(table);
        AnsiConsole.MarkupLine("\n[green]Health check completed successfully![/]");
    }
}