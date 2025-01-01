var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/F-35A/Systems/tranceivers.xml");

var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/F-35A/Systems/autopilot-dlg.xml");

var options = gui.Dialog.new("/sim/gui/dialogs/options/dialog",
        "Aircraft/F-35A/Systems/options.xml");

gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");

