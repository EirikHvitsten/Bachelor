using Toybox.WatchUi as Ui;
using Toybox.System;

class GarminWebRequestTestView extends Ui.View {

    hidden var _message;

    function initialize(message) {
        View.initialize();
        _message = message;
        System.println(message);
        Sensor.enableSensorEvents( method(:onSnsr) );
    }
    function onSnsr(sensor_info)
    {
        if ( sensor_info.heartRate != null)
    	{
	    	System.println( "sensor_info.heartRate:" );
	    	System.println( sensor_info.heartRate );
            sendData({"heartRate" => sensor_info.heartRate});
    	}
        WatchUi.requestUpdate();
        
    }
    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        View.findDrawableById("message").setText(_message);
    }
    
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

    function onResponse(responseCode, responseData)
	{
        System.println(responseCode);
        System.println(responseData); // this is the JSON data as a Lang.Dictionary
	    // responseCode is typically an HTTP response code
	    // responseData is the HTTP response.
	    
	    // changes you make to either of these variables will not affect
	    // any outoing message, these parameters are inputs only. the
	    // request has already been sent. if you want to send additional
	    // data, you should call makeWebRequest again.
	}

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
