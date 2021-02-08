using Toybox.WatchUi;
using Toybox.Communications;

class MenuHeartRateTestDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuHeartRateTestMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}