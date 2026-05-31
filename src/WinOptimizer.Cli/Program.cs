using Spectre.Console;
using WinOptimizer.Cli.Features;

namespace WinOptimizer.Cli;

class Program
{
    static async Task Main(string[] args)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        AnsiConsole.Clear();

        ShowHeader();

        while (true)
        {
            var choice = AnsiConsole.Prompt(
                new SelectionPrompt<string>()
                    .Title("[bold yellow]What would you like to do?[/]")
                    .PageSize(10)
                    .AddChoices(new[] {
                        "1. System Health Check (Live)",
                        "2. System Information",
                        "3. Quick Cleanup (Coming soon)",
                        "4. Exit"
                    }));

            switch (choice)
            {
                case "1. System Health Check (Live)":
                    var health = new HealthCheckFeature();
                    await health.RunAsync();
                    break;

                case "2. System Information":
                    var info = new SystemInfoFeature();
                    info.Run();
                    break;

                case "3. Quick Cleanup (Coming soon)":
                    AnsiConsole.MarkupLine("[yellow]This feature is under development in v3.0 restructure.[/]");
                    break;

                case "4. Exit":
                    AnsiConsole.MarkupLine("[green]Thank you for using WinOptimizer![/]");
                    return;
            }

            AnsiConsole.WriteLine();
            AnsiConsole.MarkupLine("[grey]Press any key to return to menu...[/]");
            Console.ReadKey(true);
            AnsiConsole.Clear();
            ShowHeader();
        }
    }

    static void ShowHeader()
    {
        var rule = new Rule("[bold yellow]WinOptimizer v3.0[/]") { Style = "yellow" };
        AnsiConsole.Write(rule);

        AnsiConsole.MarkupLine("[grey]Advanced Windows Optimization Toolkit - Complete Rewrite[/]");
        AnsiConsole.WriteLine();
    }
}