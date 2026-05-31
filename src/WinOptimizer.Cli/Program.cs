using Spectre.Console;

namespace WinOptimizer.Cli;

class Program
{
    static void Main(string[] args)
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold yellow]WinOptimizer v3.0[/]");
        AnsiConsole.Write(rule);
        
        AnsiConsole.MarkupLine("[green]Welcome to the new WinOptimizer CLI![/]");
        AnsiConsole.MarkupLine("[grey]This is a complete rewrite with live feedback and better structure.[/]");
        
        AnsiConsole.WriteLine();
        
        // TODO: Main menu and modules will be implemented here
        AnsiConsole.MarkupLine("[red]Project restructure in progress...[/]");
    }
}