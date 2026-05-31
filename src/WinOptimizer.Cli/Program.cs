using Spectre.Console;
using WinOptimizer.Cli.Features;

namespace WinOptimizer.Cli;

class Program
{
    static async Task Main(string[] args)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;

        while (true)
        {
            AnsiConsole.Clear();
            ShowHeader();

            var choice = AnsiConsole.Prompt(
                new SelectionPrompt<string>()
                    .Title("[bold yellow]Main Menu[/]")
                    .PageSize(12)
                    .HighlightStyle(new Style(foreground: Color.Cyan1))
                    .AddChoices(new[] {
                        "[1] System Health Check (Live Scan)",
                        "[2] System Information",
                        "[3] Disk Cleanup with Progress",
                        "[4] Startup Programs Manager",
                        "[5] Windows Services Manager (Coming soon)",
                        "[6] Exit"
                    }));

            switch (choice)
            {
                case "[1] System Health Check (Live Scan)":
                    await new HealthCheckFeature().RunAsync();
                    break;

                case "[2] System Information":
                    new SystemInfoFeature().Run();
                    break;

                case "[3] Disk Cleanup with Progress":
                    await new DiskCleanupFeature().RunAsync();
                    break;

                case "[4] Startup Programs Manager":
                    new StartupManagerFeature().Run();
                    break;

                case "[5] Windows Services Manager (Coming soon)":
                    AnsiConsole.MarkupLine("[yellow]This feature will be available soon.[/]");
                    break;

                case "[6] Exit":
                    AnsiConsole.MarkupLine("[bold green]Thank you for using WinOptimizer v3.0![/]");
                    return;
            }

            AnsiConsole.WriteLine();
            AnsiConsole.MarkupLine("[grey italic]Press any key to return to the main menu...[/]");
            Console.ReadKey(true);
        }
    }

    static void ShowHeader()
    {
        var rule = new Rule("[bold yellow]WinOptimizer v3.0[/]") { Style = Style.Parse("yellow") };
        AnsiConsole.Write(rule);

        AnsiConsole.MarkupLine("[grey]Modern CLI • Live Feedback • Clean Architecture[/]");
        AnsiConsole.WriteLine();
    }
}