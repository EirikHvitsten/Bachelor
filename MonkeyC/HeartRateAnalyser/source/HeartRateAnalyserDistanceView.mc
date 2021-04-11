using Toybox.WatchUi;
using Toybox.Graphics;

var json_file = WatchUi.loadResource(Rez.JsonData.jsonfile);

class HeartRateAnalyserDistanceView extends WatchUi.DataField {

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
    hidden var posCount;
    hidden var negCount;
    hidden var BUFFERSIZE;
    hidden var hrArr;
    hidden var AVSTANDDELTA;
    hidden var avstandPassert;

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
        // For tid
        // hrTrend = new [TREND_SIZE];
        // For avstand
        AVSTANDDELTA = 50;
        hrTrend = new [AVSTANDDELTA];
        lastHR = null;
        diffHR = 0;
        trendIndex = 0;
        historyTrendArray = new [0];
        starttid;
        trendShow = 0;
        totalTrend = 0;
        totalTrendArr = [];
        startGroup = 0;
        blackArr = json_file[black];
        darkgreyArr = json_file[darkgrey];
        lightgreyArr = json_file[lightgrey];
        // For tid
        // linRegFuncs= json_file[5];
        // For avstand
        linRegFuncs = json_file[6];
        // blackFunc = json_file[5];
        // dGreyFuncFunc = json_file[6];
        // lGreyFunc = json_file[7]
        totalTid = 0;
        posCount = 0;
        negCount = 0;
        BUFFERSIZE = 0.6;
        hrArr = [];
        avstandPassert = 0;
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
            if (info.elapsedDistance != null){
                if(info.currentHeartRate != null){
                    curHeartRate = info.currentHeartRate;
                    findTrend(info);
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
    function findTrend(info) {
        if (lastHR != null){
            diffHR = curHeartRate - lastHR;
            // System.println("diff: " + diffHR);
            lastHR = curHeartRate;
            
            // if (trendIndex == TREND_SIZE){
            //     trendIndex = 0;
            // }

            if (trendIndex == AVSTANDDELTA){
                trendIndex = 0;
            }

            hrTrend[trendIndex] = diffHR;
            trendIndex++;

            // var tid = System.getClockTime();
            // System.println(tid.hour.format("%d")+":"+tid.min.format("%d")+":"+tid.sec.format("%d"));

            // System.println(hrTrend);

            // Usikker på om denne vil bli kjørt en gang i sekundet eller oftere/sjeldnere
            // totalTid += 1;
            // if (totalTid % TREND_SIZE == 0){
            //     System.println("Brukt totalt " + totalTid + " sek.");
            //     starttid = System.getClockTime();
            //     // calculateTrendTid(hrTrend);
            //     // linRegression();
                
            // }
            // if (totalTid == 90){
            //     decTree(totalTrendArr);
            // }
            // System.println("Avstand: " + info.elapsedDistance);
            // System.println("Passert: " + avstandPassert);
            if (info.elapsedDistance - avstandPassert >= AVSTANDDELTA){
                avstandPassert += AVSTANDDELTA;
                System.println("\tTotal avstand: " + info.elapsedDistance);
                calculateTrendAvstand(hrTrend);
                linRegression();
            }
            
        } else {
            lastHR = curHeartRate;
            starttid = System.getClockTime();
        }
    }

    function calculateTrendTid(trendArray) {
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
        System.println("Trend per " + TREND_SIZE + " sek: " + historyTrendArray);
        totalTrend += curTrend;
        totalTrendArr.add(totalTrend);
        System.println("Total trend: " + totalTrendArr);
        hrArr.add(curHeartRate);
        System.println("Dine hjerterytmehistorie: " + hrArr);
        // findGroup();
    }

    function calculateTrendAvstand(trendArray) {
        // System.println(trendArray);
        var total = 0;
        for (var i = 0; i < AVSTANDDELTA; i++){
            if (trendArray[i] == null){
                break;
            }
            total += trendArray[i];
        }
        curTrend = total;
        trendIndex = 0;
        // System.println("trend: " + curTrend);
        historyTrendArray.add(curTrend);
        System.println("Trend per " + AVSTANDDELTA + " meter: " + historyTrendArray);
        totalTrend += curTrend;
        totalTrendArr.add(totalTrend);
        System.println("Total trend: " + totalTrendArr);
        hrArr.add(curHeartRate);
        System.println("Dine hjerterytmehistorie: " + hrArr);
    }

    function linRegression() {
        var values = [0, 0, 0]; // [svart, mørkegrå, lysegrå]
        var middlepoints = [0, 0]; // [svart-mørkegrå, svart-lysegrå]
        var buffer = [0, 0]; // [svart-mørkegrå, svart-lysegrå]
        var diff = 150;
        var lastTrend = totalTrendArr[totalTrendArr.size() - 1];
        if (lastTrend > 0){
            posCount++;
        } else if (lastTrend < 0){
            negCount++;
        }
        for (var k = 0; k < linRegFuncs.size(); k++) {
            values[k] = linRegFuncs[k][0] * totalTid + linRegFuncs[k][1];
            if (diff > (totalTrend - values[k]).abs()) {
                diff = (totalTrend - values[k]).abs();
                curGroup = k + black;
            }
        }
        middlepoints[0] = (values[0] + values[1]) / 2;
        middlepoints[1] = (values[0] + values[2]) / 2;
        buffer[0] = ((middlepoints[0] + values[0]) / 2).abs() * BUFFERSIZE; 
        buffer[1] = ((middlepoints[1] + values[2]) / 2).abs() * BUFFERSIZE;
        
        System.println("Øvre buffer: " + (middlepoints[1] + buffer[1]));
        System.println("Nedre buffer: " + (middlepoints[1] - buffer[1]));

        if (middlepoints[1] + buffer[1] > totalTrend and totalTrend > middlepoints[1] - buffer[1]){
            System.println("\tDu er i buffersonen mellom svart og lysegrå");
            if (posCount > negCount){
                System.println("\tDu er i lysegrå gruppe");
                curGroup = 4;
            } else if (posCount < negCount) {
                System.println("\tDu er i svart gruppe");
                curGroup = 2;
            }
        }
        // else if (middlepoints[0] + buffer[0] > totalTrend > middlepoints[0] - buffer[0]){
        //     System.println("Du er i buffersonen mellom mørkegrå og svart");
        // }
        
        // System.println("middleppoints: " + middlepoints);
        // System.println("buffer: " + buffer);

        System.println("Antall positive trender: " + posCount + ", antall negative trender: " + negCount);
        System.println("Linear regression, totalTrend: " + totalTrend + ", values: " + values + ", din gruppe : " + curGroup + "\n");
    }

    function decTree(list){
        if (list[3] <= -1.5){
            if (list[3] <= -3.5){
                if (list[8] <= -0.5){
                    System.println("weights: [0.00, 0.00, 1.00] class: svart");
                }else {
                    System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
                }
            }else {
                System.println("weights: [0.00, 4.00, 0.00] class: moerkegraa");
            }
        }else {
            if (list[5] <= -0.5){
                System.println("weights: [0.00, 0.00, 3.00] class: svart");
            }else {
                if (list[6] <= -1.0){
                    if (list[0] <= -1.5){
                        System.println("weights: [0.00, 0.00, 1.00] class: svart");
                    }else {
                        System.println("weights: [0.00, 1.00, 0.00] class: moerkegraa");
                    }
                }else {
                    System.println("weights: [4.00, 0.00, 0.00] class: lysegraa");
                }
            }
        }
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