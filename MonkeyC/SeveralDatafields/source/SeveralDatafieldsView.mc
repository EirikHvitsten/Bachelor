using Toybox.WatchUi;
using Toybox.Graphics;

// Currently just one value, which is the one we send from python
var sim_variables = WatchUi.loadResource(Rez.JsonData.variables);

class SeveralDatafieldsView extends WatchUi.DataField {

	// Current HR
    hidden var curHeartrate;
    
    // Average HR last 30
    hidden var HEARTRATES_SIZE; // Determine how big the heartrate array can be
    hidden var heartrates = new [0]; // An array to hold 30 measurements
    hidden var totalHR = 0; // Will add/subtract all 30 measurements 
    hidden var averageHR; // Will hold totalHR / heartrate.size()

	// Max HR last 30
	hidden var maxHeartrate;

    function initialize() {
        DataField.initialize();
        
        HEARTRATES_SIZE = sim_variables.toNumber();
        System.println(HEARTRATES_SIZE);
        
        curHeartrate = 0.0f;
        averageHR = 0.0f;
        maxHeartrate = 0.0f;
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
            
            // Average HR last 30
            var avgHRtextView = View.findDrawableById("avgHRtext");
            avgHRtextView.locX = avgHRtextView.locX + 50;
            avgHRtextView.locY = avgHRtextView.locY - 40;
            var avgHRView = View.findDrawableById("avgHR");
            avgHRView.locX = avgHRView.locX + 50;
            avgHRView.locY = avgHRView.locY - 20;
            
            // Max HR last 20
            var maxHRtextView = View.findDrawableById("maxHRtext");
            maxHRtextView.locX = maxHRtextView.locX + 50;
            maxHRtextView.locY = maxHRtextView.locY + 20;
            var maxHRView = View.findDrawableById("maxHR");
            maxHRView.locX = maxHRView.locX + 50;
            maxHRView.locY = maxHRView.locY + 40;
        }

		// Set text
        View.findDrawableById("curHRtext").setText("Current HR");
        View.findDrawableById("avgHRtext").setText("Average HR/30s");
        View.findDrawableById("maxHRtext").setText("Max HR/30s");
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
                addHR(info.currentHeartRate);
                System.println(heartrates);
       			
                curHeartrate = info.currentHeartRate;
            } else {
            	// Does this ever happen while simulating?
                // curHeartrate = 0.0f;
            }
        } else {
        	curHeartrate = 0.0f;
        	averageHR = 0.0f;
        	maxHeartrate = 0.0f;
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var curHR = View.findDrawableById("curHR");
       	var avgHR = View.findDrawableById("avgHR");
       	var maxHR = View.findDrawableById("maxHR");
       	
       	// Change text color if the background color changes
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            curHR.setColor(Graphics.COLOR_WHITE);
            avgHR.setColor(Graphics.COLOR_WHITE);
            maxHR.setColor(Graphics.COLOR_WHITE);
        } else {
            curHR.setColor(Graphics.COLOR_BLACK);
            avgHR.setColor(Graphics.COLOR_BLACK);
            maxHR.setColor(Graphics.COLOR_BLACK);
        }
        
        // Set the text, similar to returning in compute(?)
        curHR.setText(curHeartrate.format("%.2f"));
        avgHR.setText(averageHR.format("%.2f"));
        maxHR.setText(maxHeartrate.format("%.2f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    function addHR(heartrate) {    	
    	if(heartrates.size() < HEARTRATES_SIZE){ // If less than 30, add to the list
        	heartrates.add(heartrate);
        	
        	totalHR += heartrate; // Before 30 measurements, just add to total
        	averageHR = Math.round(totalHR.toFloat() / heartrates.size().toFloat()); // Update average HR, have to use float, if not it automatically floors() the average
        } else { // If we reached our desired cap, remove first, then add
        	totalHR -= heartrates[0]; // Subtract the value that will be removed
        	totalHR += heartrate; // Add the newest hr value to the array
        	averageHR = Math.round(totalHR.toFloat() / heartrates.size().toFloat()); // Update average HR, have to use float, if not it automatically floors() the average
        	
        	heartrates = heartrates.slice(1, HEARTRATES_SIZE);
        	heartrates.add(heartrate);
        }
        
        // Not very optimal, but works for now
        var highest = 0;
        for(var i=0; i<heartrates.size(); i++){
        	if(heartrates[i] > highest){
        		highest = heartrates[i];
        	}
        }
        maxHeartrate = highest.toFloat();
    }

}
