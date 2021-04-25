using Toybox.WatchUi;
using Toybox.Graphics;

var json_file = WatchUi.loadResource(Rez.JsonData.jsonfile);

class HeartRateAnalyserAvstandView extends WatchUi.DataField {

    hidden var curHR;
    hidden var curGrp;
    hidden var curTrd;
    hidden var curTrGr;
    hidden var curHeartRate;
    hidden var curSpeed;
    hidden var curGroup;
    hidden var curTrend;
    hidden var curTreeGroup;
    hidden var laps;
    hidden var hrTrend;
    hidden var lastHR;
    hidden var diffHR;
    hidden var historyTrendArray;
    hidden var totalTrend;
    hidden var totalTrendArr;
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
    hidden var totalTid;
    hidden var posCount;
    hidden var negCount;
    hidden var BUFFERSIZE;
    hidden var hrArr;
    hidden var AVSTANDDELTA;
    hidden var avstandPassert;
    hidden var analyser;
    hidden var analysertFerdig;
    hidden var startDistanse;
    hidden var distanseAnalysert;
    hidden var gruppeTekst;
    hidden var treeGroup;
    hidden var linGroup;

    hidden var DEBUG = false;

    function initialize() {
        DataField.initialize();
        
        curHeartRate = 0.0f;
        curSpeed = 0.0f;
        curGroup = 0.0f;
        curTrend = 0.0f;
        curTreeGroup = 0.0f;
        laps = 0;
        AVSTANDDELTA = 50;
        hrTrend = [];
        lastHR = null;
        diffHR = 0;
        historyTrendArray = new [0];
        totalTrend = 0;
        totalTrendArr = [];
        linRegFuncs = json_file[6];
        posCount = 0;
        negCount = 0;
        BUFFERSIZE = 0.6;
        hrArr = [];
        avstandPassert = 0;
        analyser = false;
        analysertFerdig = false;
        startDistanse = 0;
        distanseAnalysert = 0;
        gruppeTekst = "N/A";
        treeGroup = "N/A";
        linGroup = "N/A";
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
            curHRtextView.locY = curHRtextView.locY - 43;
            var curHRView = View.findDrawableById("curHR");
            curHRView.locX = curHRView.locX - 50;
            curHRView.locY = curHRView.locY - 20;
            
            // currentTrend
            var curTrendtextView = View.findDrawableById("curTrendtext");
            curTrendtextView.locX = curTrendtextView.locX - 50;
            curTrendtextView.locY = curTrendtextView.locY + 17;
            var curTrendView = View.findDrawableById("curTrd");
            curTrendView.locX = curTrendView.locX - 50;
            curTrendView.locY = curTrendView.locY + 40;

            // currentGroup
            var curGrouptextView = View.findDrawableById("curGrouptext");
            curGrouptextView.locX = curGrouptextView.locX + 50;
            curGrouptextView.locY = curGrouptextView.locY - 43;
            var curGroupView = View.findDrawableById("curGrp");
            curGroupView.locX = curGroupView.locX + 50;
            curGroupView.locY = curGroupView.locY - 20;

            // currentTreeGroup
            var curTreeGrouptextView = View.findDrawableById("curTreeGrouptext");
            curTreeGrouptextView.locX = curTreeGrouptextView.locX + 50;
            curTreeGrouptextView.locY = curTreeGrouptextView.locY + 17;
            var curTreeGroupView = View.findDrawableById("curTrGr");
            curTreeGroupView.locX = curTreeGroupView.locX + 50;
            curTreeGroupView.locY = curTreeGroupView.locY + 40;
        }

        // Set text
        View.findDrawableById("curHRtext").setText("HR");
        View.findDrawableById("curGrouptext").setText("Lin Group");
        // Viser trend
        // View.findDrawableById("curTrendtext").setText("Trend");
        // Viser distanse
        View.findDrawableById("curTrendtext").setText("Distance");
        View.findDrawableById("curTreeGrouptext").setText("Tree Group");
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate and info.currentHeartRate != null){
            curHeartRate = info.currentHeartRate;
            if (analyser and info.elapsedDistance != null){                 
                if (startDistanse == 0){
                    startDistanse = info.elapsedDistance;
                }
                findTrend(info);
            }
        }
    }

    // Find trend 
    function findTrend(info) {
        if (lastHR != null){
            diffHR = curHeartRate - lastHR;
            // System.println("diff: " + diffHR);
            lastHR = curHeartRate;
            hrTrend.add(diffHR);

            if (info.elapsedDistance - startDistanse - avstandPassert >= AVSTANDDELTA){
                avstandPassert += AVSTANDDELTA;
                distanseAnalysert = info.elapsedDistance - startDistanse;
                System.println("\tAvstand analysert: " + distanseAnalysert);
                System.println("\tAvstand passert: " + avstandPassert);
                System.println("\t\tTotal avstand: " + info.elapsedDistance);
                System.println("\t\tDistanse ved start på analyse: " + startDistanse);
                calculateTrendAvstand(hrTrend);
                linRegression();
                hrTrend = [];
            }

            // Bruk denne hvis decision tree skal kjøres etter 800 meter
            if (avstandPassert == 800){
                decTree(totalTrendArr);
                analysertFerdig = true;
            }

            if (analysertFerdig){
                if (avstandPassert < 800) {
                    System.println("Fikk ikke analysert nok data til å kjøre decision tree!");
                    curTreeGroup = -1;
                }
                nullstill();
            }
        } else {
            lastHR = curHeartRate;
        }
    }

    // Fjerner lagret data fra forrige analyse
    function nullstill() {
        System.println("Nullstiller");
        analyser = false;
        startDistanse = 0;
        avstandPassert = 0;
        hrTrend = [];
        historyTrendArray = [];
        posCount = 0;
        negCount = 0;
        totalTrendArr = [];
        hrArr = [];
        curTrend = 0;
        totalTrend = 0;
        // distanseAnalysert = 0;
    }

    function calculateTrendAvstand(trendArray) {
        // System.println(trendArray);
        var total = 0;
        for (var i = 0; i < trendArray.size(); i++){
            total += trendArray[i];
        }
        curTrend = total;
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
            values[k] = linRegFuncs[k][0] * avstandPassert + linRegFuncs[k][1];
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

        // Buffer mellom svart og lysegrå
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

        // Buffer mellom svart og mørkegrå
        // else if (middlepoints[0] + buffer[0] > totalTrend > middlepoints[0] - buffer[0]){
        //     System.println("Du er i buffersonen mellom mørkegrå og svart");
        // }
        
        // System.println("middleppoints: " + middlepoints);
        // System.println("buffer: " + buffer);

        linGroup = skrivGruppe(curGroup);

        System.println("Antall positive trender: " + posCount + ", antall negative trender: " + negCount);
        System.println("Linear regression, totalTrend: " + totalTrend + ", values: " + values + ", din gruppe : " + linGroup + "\n");
    }

    // Skal hente decision tree fra resources
    function decTree(list){
        if (list[3] <= -1.5){
            if (list[3] <= -3.5){
                if (list[8] <= -0.5){
                    System.println("weights: [0.00, 0.00, 1.00] class: svart");
                    treeGroup = skrivGruppe(black);
                }else {
                    System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
                    treeGroup = skrivGruppe(lightgrey);
                }
            }else {
                System.println("weights: [0.00, 4.00, 0.00] class: moerkegraa");
                treeGroup = skrivGruppe(darkgrey);
            }
        }else {
            if (list[5] <= -0.5){
                System.println("weights: [0.00, 0.00, 3.00] class: svart");
                treeGroup = skrivGruppe(black);
            }else {
                if (list[6] <= -1.0){
                    if (list[0] <= -1.5){
                        System.println("weights: [0.00, 0.00, 1.00] class: svart");
                        treeGroup = skrivGruppe(black);
                    }else {
                        System.println("weights: [0.00, 1.00, 0.00] class: moerkegraa");
                        treeGroup = skrivGruppe(darkgrey);
                    }
                }else {
                    System.println("weights: [4.00, 0.00, 0.00] class: lysegraa");
                    treeGroup = skrivGruppe(lightgrey);
                }
            }
        }
    }

    function skrivGruppe(n) {
        if (n == 2) {
            gruppeTekst = "Normal";
        } else if (n == 3) {
            gruppeTekst = "Safe";
        } else if (n == 4) {
            gruppeTekst = "Press";
        } else {
            gruppeTekst = "N/A";
        }
        
        System.println("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tn:" + n + ", GruppeTekst: " + gruppeTekst);
        return gruppeTekst;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        curHR = View.findDrawableById("curHR");
       	curGrp = View.findDrawableById("curGrp");
       	curTrd = View.findDrawableById("curTrd");
        curTrGr = View.findDrawableById("curTrGr");

        // Change text color if the background color changes
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            curHR.setColor(Graphics.COLOR_WHITE);
            // curGrp.setColor(Graphics.COLOR_WHITE);
            curTrd.setColor(Graphics.COLOR_WHITE);
            // curTrGr.setColor(Graphics.COLOR_WHITE);
        } else {
            curHR.setColor(Graphics.COLOR_BLACK);
            // curGrp.setColor(Graphics.COLOR_BLACK);   
            curTrd.setColor(Graphics.COLOR_BLACK);
            // curTrGr.setColor(Graphics.COLOR_BLACK);
        }

        if (analysertFerdig) {
            curGrp.setColor(Graphics.COLOR_GREEN);
            curTrGr.setColor(Graphics.COLOR_GREEN);
            curTrd.setColor(Graphics.COLOR_GREEN);
        } else {
            curGrp.setColor(Graphics.COLOR_LT_GRAY);
            curTrGr.setColor(Graphics.COLOR_LT_GRAY);
        }

        // Set the text, similar to returning in compute(?)
        curHR.setText(curHeartRate.format("%d"));
        // curGrp.setText(curGroup.format("%d"));
        curGrp.setText(linGroup);
        // Viser trend
        // curTrd.setText(curTrend.format("%d"));
        // Viser distanse
        curTrd.setText((distanseAnalysert).format("%d"));
        // curTrGr.setText(curTreeGroup.format("%d"));
        curTrGr.setText(treeGroup);
        

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    function onTimerLap () {
    	System.println("TIMER LAP");
        
        if (analyser == false){ // Når analysen blir kjørt
             analyser = true;
             analysertFerdig = false;
             System.println("analyser: " + analyser);
             distanseAnalysert = 0;
        } else { // Når analysen ikke blir kjørt
            analysertFerdig = true;
            System.println("analysertFerdig: " + analysertFerdig);
        }
    }

}