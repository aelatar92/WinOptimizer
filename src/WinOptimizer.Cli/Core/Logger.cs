using Spectre.Console;

namespace WinOptimizer.Cli.Core;

public static class Logger
{
    public static void Info(string message)
    {
        AnsiConsole.MarkupLine($"[blue][[INFO]][/] {message}");
    }

    public static void Success(string message)
    {
        AnsiConsole.MarkupLine($"[green][[SUCCESS]][/] {message}");
    }

    public static void Warning(string message)
    {
        AnsiConsole.MarkupLine($"[yellow][[WARNING]][/] {message}");
    }

    public static void Error(string message)
    {
        AnsiConsole.MarkupLine($"[red][[ERROR]][/] {message}");
    }
}