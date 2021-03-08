using Toybox.WatchUi;
using Toybox.Graphics;

var json_file = WatchUi.loadResource(Rez.JsonData.jsonfile);

class HeartRateAnalyserView extends WatchUi.DataField {

    hidden var curHeartRate;
    hidden var curSpeed;
    hidden var curGroup;
    hidden var groups;
    hidden var curTrend;
    hidden var laps;
    hidden var trend;
    hidden var TREND_SIZE;
    hidden var hrTrend;
    hidden var lastHR;
    hidden var diffHR;
    hidden var trendIndex;
    hidden var historyTrendArray;
    hidden var starttid;
    hidden var delta;
    hidden var trendShow;
    hidden var totalTrend;

    hidden var DEBUG = false;

    function initialize() {
        DataField.initialize();
        curHeartRate = 0.0f;
        curSpeed = 0.0f;
        curGroup = 0.0f;
        groups = [130, 140];
        
        curTrend = 0.0f;
        laps = 0;
        trend = 0;
        TREND_SIZE = 10;
        hrTrend = new [TREND_SIZE];
        lastHR = null;
        diffHR = 0;
        trendIndex = 0;
        historyTrendArray = new [0];
        starttid;
        delta;
        trendShow = 0;
        totalTrend = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            // Current HR
            var curHRtextView = View.findDrawableById("curHRtext");
            curHRtextView.locX = curHRtextView.locX - 50;
            curHRtextView.locY = curHRtextView.locY - 10;
            var curHRView = View.findDrawableById("curHR");
            curHRView.locX = curHRView.locX - 50;
            curHRView.locY = curHRView.locY + 10;
            
            // currentGroup
            var curGrouptextView = View.findDrawableById("curGrouptext");
            curGrouptextView.locX = curGrouptextView.locX + 50;
            curGrouptextView.locY = curGrouptextView.locY - 40;
            var curGroupView = View.findDrawableById("curGrp");
            curGroupView.locX = curGroupView.locX + 50;
            curGroupView.locY = curGroupView.locY - 20;
            
            // currentTrend
            var curTrendtextView = View.findDrawableById("curTrendtext");
            curTrendtextView.locX = curTrendtextView.locX + 50;
            curTrendtextView.locY = curTrendtextView.locY + 20;
            var curTrendView = View.findDrawableById("curTrd");
            curTrendView.locX = curTrendView.locX + 50;
            curTrendView.locY = curTrendView.locY + 40;
        }

        // Set text
        View.findDrawableById("curHRtext").setText("Current HR");
        View.findDrawableById("curGrouptext").setText("Current Group");
        View.findDrawableById("curTrendtext").setText("Current Trend");
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                
                curHeartRate = info.currentHeartRate;

                if (laps == 2) {
                    // Find trend
                    findTrend();
                }

            } else {

                curHeartRate = 0.0f;
                curGroup = 0.0f;
                curTrend = 0.0f;
                
            }
        }
    }

    // Find group
    function findGroup() {
    // Finds group here
        var group = 0;
        var diff = (groups[0] - curHeartRate).abs();
        for (var i = 1; i < groups.size(); i++) {

            if ((groups[i] - curHeartRate).abs() < diff){
                diff = (groups[i] - curHeartRate).abs();
                group = i;
            }
        }
        return group;
    }

    // Find trend 
    function findTrend() {
        if (lastHR != null){
            diffHR = curHeartRate - lastHR;
            // System.println("diff: " + diffHR);
            lastHR = curHeartRate;
            // System.println(hrTrend);
            if (trendIndex == TREND_SIZE){
                trendIndex = 0;
            }
            hrTrend[trendIndex] = diffHR;
            trendIndex++;
            // System.println("index: " + trendIndex);
            var tid = System.getClockTime();
            // System.println(tid.hour.format("%d")+":"+tid.min.format("%d")+":"+tid.sec.format("%d"));
            delta = tid.sec - starttid.sec;
            if (delta < 0){
                delta += 60;
            }
            if (delta >= TREND_SIZE){
                // System.println("ny starttid");
                starttid = System.getClockTime();
                calculateTrend(hrTrend);
            }
            // System.println("delta: " + delta);
        } else {
            lastHR = curHeartRate;
            starttid = System.getClockTime();
        }


        // Finds trend here
        // var trend = 2.0f;
        // return trend;
    }

    function calculateTrend(trendArray) {
        // System.println("hei");
        // System.println(trendArray);
        var total = 0;
        for (var i = 0; i < TREND_SIZE; i++){
            if (trendArray[i] == null){
                break;
            }
            total += trendArray[i];
        }
        curTrend = total;
        trendIndex = 0;
        // System.println("trend: " + curTrend);
        historyTrendArray.add(curTrend);
        System.println(historyTrendArray);
        totalTrend += curTrend;
        System.println("Total trend: " + totalTrend);
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var curHR = View.findDrawableById("curHR");
       	var curGrp = View.findDrawableById("curGrp");
       	var curTrd = View.findDrawableById("curTrd");

        // Change text color if the background color changes
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            curHR.setColor(Graphics.COLOR_WHITE);
            curGrp.setColor(Graphics.COLOR_WHITE);
            curTrd.setColor(Graphics.COLOR_WHITE);
        } else {
            curHR.setColor(Graphics.COLOR_BLACK);
            curGrp.setColor(Graphics.COLOR_BLACK);   
            curTrd.setColor(Graphics.COLOR_BLACK);
        }

        // Set the text, similar to returning in compute(?)
        curHR.setText(curHeartRate.format("%.2f"));
        curGrp.setText(curGroup.format("%.2f"));
        curTrd.setText(curTrend.format("%d"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    function onTimerLap () {
    	System.println("TIMER LAP");
        laps++;

        if (laps == 1) {
            System.println("Start å sykle.");
            curGroup = findGroup();

        } else if (laps == 2) {
            System.println("Fortsett, regner ut...");
        }
    }

}
