namespace BudgieHeadsetControl {

public class HeadsetControlSettings : Gtk.Box {

    GLib.Settings settings;

    public HeadsetControlSettings() {

        // Load settings
        this.settings = new GLib.Settings("net.olback.budgie-headset-control-applet");

    }

    public bool battery_notification {
        get {
            return this.settings.get_boolean("battery-notification");
        }
    }

    public int notify_below {
        get {
            return this.settings.get_int("notify-below");
        }
    }

    public int interval {
        get {
            return this.settings.get_int("interval");
        }
    }

    public HeadsetControlSettingsUI get_ui() {

        return new HeadsetControlSettingsUI(this.settings);

    }

}

} // eon
