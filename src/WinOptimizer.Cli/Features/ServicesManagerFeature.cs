using Spectre.Console;

namespace WinOptimizer.Cli.Features;

public class ServicesManagerFeature
{
    public void Run()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold blue]Windows Services Manager[/]");
        AnsiConsole.Write(rule);

        AnsiConsole.Status()
            .Start("Loading services...", ctx =>
            {
                ctx.Status("Querying system services...");
                Thread.Sleep(800);
            });

        var table = new Table()
            .Border(TableBorder.Rounded)
            .Title("[yellow]Important Services[/]")
            .AddColumn("Service")
            .AddColumn("Status")
            .AddColumn("Startup Type");

        table.AddRow("Windows Update (wuauserv)", "[green]Running[/]", "Manual");
        table.AddRow("Print Spooler", "[green]Running[/]", "Automatic");
        table.AddRow("Superfetch/SysMain", "[yellow]Stopped[/]", "Manual");

        AnsiConsole.Write(table);

        AnsiConsole.MarkupLine("\n[grey]Note: Full management coming in future updates.[/]");
    }
}