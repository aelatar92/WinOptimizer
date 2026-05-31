using Spectre.Console;
using WinOptimizer.Cli.Core;
using WinOptimizer.Cli.Models;

namespace WinOptimizer.Cli.Features;

public class HealthCheckFeature
{
    public async Task RunAsync()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold cyan]System Health Check (Live)[/]").RuleStyle(Style.Parse("cyan"));
        AnsiConsole.Write(rule);

        var scanner = new SystemScanner();
        SystemHealthReport report = new();

        await AnsiConsole.Status()
            .StartAsync("Performing comprehensive system scan...", async ctx =>
            {
                var progress = new Progress<string>(status => ctx.Status(status));
                var scanResults = await scanner.ScanSystemAsync(progress);

                // Populate report
                report.HealthScore = CalculateHealthScore(scanResults);
                report.CpuStatus = $"Cores: {Environment.ProcessorCount}";
                report.MemoryStatus = $"Used: {scanResults.GetValueOrDefault("RAM_Used_MB", 0)} MB";
                report.DiskStatus = $"Free: {scanResults.GetValueOrDefault("C_Free_GB", 0)} GB on C:\";

                if (report.HealthScore < 70)
                    report.Recommendations.Add("Consider running Disk Cleanup");
                if (report.HealthScore < 50)
                    report.Recommendations.Add("High memory usage detected - check startup programs");
            });

        // Display beautiful report
        DisplayHealthReport(report);
    }

    private int CalculateHealthScore(Dictionary<string, object> results)
    {
        // Simple scoring logic (can be expanded)
        int score = 100;

        if (results.TryGetValue("C_Free_GB", out var freeGb) && freeGb is double free && free < 20)
            score -= 25;

        return Math.Max(score, 0);
    }

    private void DisplayHealthReport(SystemHealthReport report)
    {
        var table = new Table()
            .Border(TableBorder.Rounded)
            .Title($"[bold]Health Score: {report.HealthScore}/100[/]")
            .AddColumn("Metric")
            .AddColumn("Status");

        table.AddRow("CPU", report.CpuStatus);
        table.AddRow("Memory", report.MemoryStatus);
        table.AddRow("Disk C:\", report.DiskStatus);

        AnsiConsole.Write(table);

        if (report.Recommendations.Any())
        {
            AnsiConsole.WriteLine();
            AnsiConsole.MarkupLine("[yellow]Recommendations:[/]");
            foreach (var rec in report.Recommendations)
            {
                AnsiConsole.MarkupLine($"  • {rec}");
            }
        }

        AnsiConsole.MarkupLine("\n[green]Scan completed successfully.[/]");
    }
}