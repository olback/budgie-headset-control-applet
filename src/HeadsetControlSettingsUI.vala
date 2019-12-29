namespace BudgieHeadsetControl {

public class HeadsetControlSettingsUI : Gtk.Box {

    public HeadsetControlSettingsUI(GLib.Settings settings) {

        // Builder
        Gtk.Builder builder = new Gtk.Builder.from_resource("/net/olback/budgie-headset-control-applet/glade-ui");

        // Grid
        Gtk.Grid settings_layout = (Gtk.Grid)builder.get_object("settings_layout");
        Gtk.Switch battery_notification = (Gtk.Switch)builder.get_object("settings_battery_notification");
        Gtk.SpinButton notify_below = (Gtk.SpinButton)builder.get_object("settings_notify_below");
        Gtk.SpinButton interval = (Gtk.SpinButton)builder.get_object("settings_interval");
        Gtk.Button reset = (Gtk.Button)builder.get_object("settings_reset");

        // Bind widgets to settings
        settings.bind("battery-notification", battery_notification, "active", GLib.SettingsBindFlags.DEFAULT);
        settings.bind("notify-below", notify_below, "value", GLib.SettingsBindFlags.DEFAULT);
        settings.bind("interval", interval, "value", GLib.SettingsBindFlags.DEFAULT);

        reset.button_press_event.connect(() => {
            string[] keys = settings.list_keys();
            foreach (string key in keys) {
                settings.reset(key);
            }
            return Gdk.EVENT_PROPAGATE;
        });

        // Show
        this.add(settings_layout);
        this.show_all();

    }

}

} // eon
