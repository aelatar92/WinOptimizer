using Spectre.Console;

namespace WinOptimizer.Cli.Features;

public class DiskCleanupFeature
{
    public async Task RunAsync()
    {
        AnsiConsole.Clear();
        
        var rule = new Rule("[bold green]Disk Cleanup[/]");
        AnsiConsole.Write(rule);

        await AnsiConsole.Progress()
            .Columns(
                new TaskDescriptionColumn(),
                new ProgressBarColumn(),
                new PercentageColumn(),
                new RemainingTimeColumn()
            )
            .StartAsync(async ctx =>
            {
                var task1 = ctx.AddTask("[green]Cleaning Temp files[/]");
                var task2 = ctx.AddTask("[green]Cleaning Recycle Bin[/]");
                var task3 = ctx.AddTask("[green]Cleaning Windows Update Cache[/]");

                // Simulate work
                for (int i = 0; i <= 100; i += 10)
                {
                    task1.Increment(10);
                    await Task.Delay(150);
                }

                for (int i = 0; i <= 100; i += 20)
                {
                    task2.Increment(20);
                    await Task.Delay(200);
                }

                for (int i = 0; i <= 100; i += 5)
                {
                    task3.Increment(5);
                    await Task.Delay(100);
                }
            });

        AnsiConsole.MarkupLine("\n[bold green]Disk cleanup completed successfully![/]");
    }
}