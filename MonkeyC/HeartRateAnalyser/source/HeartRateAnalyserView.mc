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
    hidden var totalTrendArr;
    hidden var startGroup;
    hidden enum {
            skille, // 0
            distance, // 1
            black, // 2
            darkgrey, // 3
            lightgrey // 4
        }
    hidden var blackArr;
    hidden var darkgreyArr;
    hidden var lightgreyArr;
    hidden var group;
    hidden var linRegFuncs;
    // hidden var blackFunc;
    // hidden var dGreyFuncFunc;
    // hidden var lGreyFunc;
    hidden var totalTid;

    hidden var DEBUG = false;

    function initialize() {
        DataField.initialize();
        
        curHeartRate = 0.0f;
        curSpeed = 0.0f;
        curGroup = 0.0f;
        groups = json_file[skille];
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
        totalTrendArr = [];
        startGroup = 0;
        blackArr = json_file[black];
        darkgreyArr = json_file[darkgrey];
        lightgreyArr = json_file[lightgrey];
        linRegFuncs= json_file[5];
        // blackFunc = json_file[5];
        // dGreyFuncFunc = json_file[6];
        // lGreyFunc = json_file[7]
        totalTid = 0;
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
                findTrend();
                // if (laps == 2) {
                //     // Find trend
                //     findTrend();
                //     System.println("hei");
                // } else if (laps == 1){
                //     if (curHeartRate > 134){
                //         startGroup = black;
                //     } else {
                //         startGroup = darkgrey;
                //         }
                //     System.println("Din startgruppe: " + startGroup);
                //     curGroup = startGroup;
                // }
            } else {

                curHeartRate = 0.0f;
                curGroup = 0.0f;
                curTrend = 0.0f;
                
            }
        }
    }

    // Find group
    // function findGroup() {
    //     var diff = 150;
    //     var check = 0;
    //     var trendIndex = totalTrendArr.size();
    //     System.println("totalTrend: " + totalTrend);
    //     if (trendIndex < json_file[1].size()){
    //         for (var k = 2; k < 5; k++){
    //             check = (totalTrend - json_file[k][trendIndex]).abs();
    //             System.println("k: " + k + " check: " + check + " diff: " + diff);
    //             if (check == diff){
    //                 System.println("\tBeholder forrige gruppe");
    //                 continue;
    //             } else if (check < diff){
    //                 diff = check;
    //                 if (k == black or k == darkgrey){
    //                     curGroup = startGroup;
    //                 } else {
    //                     curGroup = lightgrey;
    //                 }
    //                 System.println("\tFår ny gruppe");
    //             }
    //         }
    //     }
    //     System.println("Din gruppe: " + curGroup);
    // }

    // Find trend 
    function findTrend() {
        if (lastHR != null){
            diffHR = curHeartRate - lastHR;
            // System.println("diff: " + diffHR);
            lastHR = curHeartRate;
            
            if (trendIndex == TREND_SIZE){
                trendIndex = 0;
            }
            hrTrend[trendIndex] = diffHR;
            trendIndex++;
            // System.println("index: " + trendIndex);s
            var tid = System.getClockTime();
            // System.println(tid.hour.format("%d")+":"+tid.min.format("%d")+":"+tid.sec.format("%d"));
            delta = tid.sec - starttid.sec;
            // System.println("delta: " + delta);
            if (delta < 0){
                delta += 60;
            }
            if (delta >= TREND_SIZE){
                // System.println("ny starttid");
                starttid = System.getClockTime();
                calculateTrend(hrTrend);
            }
            System.println(hrTrend);
            if (delta % TREND_SIZE == 0) {
                totalTid += 10;
                linRegression();
            }
        } else {
            lastHR = curHeartRate;
            starttid = System.getClockTime();
        }
    }

    function calculateTrend(trendArray) {
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
        System.println("Trend siste 10 sek: " + historyTrendArray);
        totalTrend += curTrend;
        totalTrendArr.add(totalTrend);
        System.println("Total trend: " + totalTrendArr);
        // findGroup();
    }

    function linRegression() {
        var values = [0, 0, 0];
        var diff = 150;
        for (var k = 0; k < linRegFuncs.size(); k++) {
            values[k] = linRegFuncs[k][0] * totalTid + linRegFuncs[k][1];
            if (diff > (totalTrend - values[k]).abs()) {
                diff = (totalTrend - values[k]).abs();
                curGroup = k + black;
            }
        }
        System.println("Linear regression, totalTrend: " + totalTrend + ", values: " + values + ", din gruppe : " + curGroup);
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
        curGrp.setText(curGroup.format("%d"));
        curTrd.setText(curTrend.format("%d"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    function onTimerLap () {
    	System.println("TIMER LAP");
        laps++;

        if (laps == 1) {
            System.println("Start å sykle.");

        } else if (laps == 2) {
            System.println("Fortsett, regner ut...");
        }
    }

}
