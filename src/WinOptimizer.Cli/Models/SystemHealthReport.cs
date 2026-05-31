namespace WinOptimizer.Cli.Models;

public class SystemHealthReport
{
    public int HealthScore { get; set; }
    public string CpuStatus { get; set; } = string.Empty;
    public string MemoryStatus { get; set; } = string.Empty;
    public string DiskStatus { get; set; } = string.Empty;
    public List<string> Recommendations { get; set; } = new();
}