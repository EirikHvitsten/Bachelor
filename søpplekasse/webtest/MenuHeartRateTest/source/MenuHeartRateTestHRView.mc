using Toybox.WatchUi;
using Toybox.System;
using Toybox.Sensor;
using Toybox.Math;

var HEARTRATES_SIZE = 10; // Determine how big the heartrate array can be

class MenuHeartRateTestHRView extends WatchUi.View {

	// Current HR
    hidden var curHeartrate;

    
    // Average HR last 30
    
    hidden var heartrates = new [0]; // An array to hold 30 measurements
    hidden var totalHR = 0; // Will add/subtract all 30 measurements 
    hidden var averageHR; // Will hold totalHR / heartrate.size()

	// Max HR last 30
	hidden var maxHeartrate;

    function initialize() {
        View.initialize();
        
        Sensor.enableSensorEvents( method(:onSnsr) );
        
        curHeartrate = 0;
        averageHR = 0;
        maxHeartrate = 0;
    }
    
    function setHEARTRATES_SIZE(size) {
        HEARTRATES_SIZE = size;
    }

    function onSnsr(sensor_info)
    {
        if ( sensor_info.heartRate != null )
    	{
	    	System.println( "sensor_info.heartRate:" );
	    	System.println( sensor_info.heartRate );

            curHeartrate = sensor_info.heartRate;
            calculate(sensor_info);

            sendData({"currentHeartRate" => curHeartrate, "maxHeartRate" => maxHeartrate, "averageHeartRate" => averageHR});
            System.println("-------------------------------------------");
    	}
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.HRLayout(dc));
    
        
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
        View.findDrawableById("curHRtext").setText("Current HR");
        View.findDrawableById("avgHRtext").setText("Average HR/" + HEARTRATES_SIZE.format("%.0f") + "s");
        View.findDrawableById("maxHRtext").setText("Max HR/" + HEARTRATES_SIZE.format("%.0f") + "s");
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        View.findDrawableById("curHR").setText(curHeartrate.format("%.2f") );
        View.findDrawableById("maxHR").setText(maxHeartrate.format("%.2f") );
        View.findDrawableById("avgHR").setText(averageHR.format("%.2f") );
        View.findDrawableById("avgHRtext").setText("Average HR/" + HEARTRATES_SIZE.format("%.0f") + "s");
        View.findDrawableById("maxHRtext").setText("Max HR/" + HEARTRATES_SIZE.format("%.0f") + "s");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // Send data to the Flask data
    function sendData(dataen)
    {

        var url = "http://127.0.0.1:5000/data"; //I am testing with a local IP 

        // this is the data that you want to send out
        var params = dataen;
        
        var	options = {                                            
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},                                                    
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        System.println(params);

        // make the Communications.makeJsonRequest() call to send data
        Communications.makeJsonRequest(url, params, options, method(:onResponse));
        }

    // Response from the Flask server
    function onResponse(responseCode, responseData)
	{
        //System.println(responseCode);
        //System.println(responseData); // this is the JSON data as a Lang.Dictionary
	    // responseCode is typically an HTTP response code
	    // responseData is the HTTP response.
	    
	    // changes you make to either of these variables will not affect
	    // any outoing message, these parameters are inputs only. the
	    // request has already been sent. if you want to send additional
	    // data, you should call makeWebRequest again.
	}

    function calculate(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :heartRate){
            if(info.heartRate != null){
                addHR(info.heartRate);
                System.println(heartrates);

       			
                curHeartrate = info.heartRate;
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

    // Add newest HR reading, delete oldest
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
