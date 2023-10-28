public class ClipActionButton : ActionButton {

    public ClipActionButton() {
        base("Clip Screen", "screenshot-app-symbolic");
        is_builtin = true;
    }

    protected override void button_default_action() {
        string? screenshot = Environment.find_program_in_path ("org.buddiesofbudgie.BudgieScreenshot");
        if (screenshot == null) return;
        try {
            Process.spawn_command_line_async(string.join(" ", screenshot, "-a"));
        } catch (SpawnError e) {
            warning("Failed to run screenshot: %s", e.message);
        }
    }
}