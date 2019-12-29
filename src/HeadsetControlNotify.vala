namespace BudgieHeadsetControl {

public class HeadsetControlNotify {

    //  private Notify.Notification? notif = null;
    private const string name = "Budgie Headset Control";
    private const string icon = "audio-headphones";

    public HeadsetControlNotify() {

        //  Notify.init("net.olback.budgie-headset-control-applet");

    }

    // https://github.com/solus-project/budgie-desktop/blob/e0e8e0da5f6a1aa4b482d4e82d6289e7ea3a3a75/src/daemon/settings.vala#L351
    public void show(string title, string body) {

        // Hacky way, but it works. Thanks https://github.com/solus-project/budgie-desktop/issues/1916#issuecomment-569474343
        try {

            Process.spawn_command_line_async("notify-send -a '%s' -i '%s' '%s' '%s'".printf(name, icon, title, body));

        } catch (SpawnError e) {

            warning("Error showing notif: %s", e.message);

        }

        // This is the proper way, but it does not work.
        //  if (Notify.is_initted()) {

        //      if (this.notif == null) {

        //          this.notif = new Notify.Notification(title, body, this.icon);
        //          this.notif.set_urgency(Notify.Urgency.CRITICAL);

        //      } else {

        //          try {
        //              this.notif.close(); // Ensure previous is closed
        //          } catch (Error e) {
        //              warning("Failed to close previous notification: %s", e.message);
        //          }

        //          this.notif.update(title, body, this.icon);

        //      }

        //      try {
        //          warning("Before show call");
        //          this.notif.show();
        //          warning("After show call");
        //      } catch (Error e) {
        //          warning("Failed to send Headset Control notification: %s", e.message);
        //      }

        //  } else {

        //      warning("Notify not initted");

        //  }

    }

}

} // eon
