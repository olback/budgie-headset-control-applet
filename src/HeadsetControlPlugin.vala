namespace BudgieHeadsetControl {

public class HeadsetControlPlugin : Budgie.Plugin, Peas.ExtensionBase {

    public Budgie.Applet get_panel_widget(string uuid) {

        return new HeadsetControlApplet(uuid);

    }

}

} // eon
