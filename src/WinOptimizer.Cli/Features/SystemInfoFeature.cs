using Spectre.Console;

namespace WinOptimizer.Cli.Features;

public class SystemInfoFeature
{
    public void Run()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold blue]System Information[/]");
        AnsiConsole.Write(rule);

        var grid = new Grid();
        grid.AddColumn();
        grid.AddColumn();

        grid.AddRow("[yellow]OS[/]", Environment.OSVersion.ToString());
        grid.AddRow("[yellow]Machine Name[/]", Environment.MachineName);
        grid.AddRow("[yellow]User[/]", Environment.UserName);
        grid.AddRow("[yellow]Processors[/]", Environment.ProcessorCount.ToString());
        grid.AddRow("[yellow].NET Version[/]", Environment.Version.ToString());

        AnsiConsole.Write(grid);
    }
}