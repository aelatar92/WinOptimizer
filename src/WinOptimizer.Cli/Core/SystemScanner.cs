using Spectre.Console;

namespace WinOptimizer.Cli.Core;

public class SystemScanner
{
    public async Task<Dictionary<string, object>> ScanSystemAsync(IProgress<string> progress)
    {
        var results = new Dictionary<string, object>();

        // CPU
        progress.Report("Scanning CPU...");
        await Task.Delay(300);
        results["CPU"] = Environment.ProcessorCount + " cores";

        // RAM
        progress.Report("Scanning Memory...");
        await Task.Delay(300);
        var totalRam = GC.GetTotalMemory(false) / (1024 * 1024);
        results["RAM_Used_MB"] = totalRam;

        // Disk C
        progress.Report("Scanning Drive C:...");
        await Task.Delay(400);
        var drive = new DriveInfo("C");
        results["C_Free_GB"] = drive.AvailableFreeSpace / (1024 * 1024 * 1024);

        progress.Report("Scan completed.");
        return results;
    }
}