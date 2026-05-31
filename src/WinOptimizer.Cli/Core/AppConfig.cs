namespace WinOptimizer.Cli.Core;

public class AppConfig
{
    public bool EnableLiveFeedback { get; set; } = true;
    public bool CreateRestorePoints { get; set; } = true;
    public string LogLevel { get; set; } = "Info";
    public string Language { get; set; } = "en";

    public static AppConfig Load()
    {
        // In future: load from config.json or user settings
        return new AppConfig();
    }
}