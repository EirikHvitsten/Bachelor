using Toybox.WatchUi;
using Toybox.System;

class MenuHeartRateTestMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
       
        if (item == :item_1) {
            System.println( "Heart Rate Monitor 10 sec\n");
            var confirmData = {"hei" => 2};
            sendData(confirmData);
            
            MenuHeartRateTestHRView.setHEARTRATES_SIZE(10);
            

        } else if (item == :item_2) {
            System.println( "Heart Rate Monitor 30 sec\n" );
            
            MenuHeartRateTestHRView.setHEARTRATES_SIZE(30);
        }
    }
    function sendData(data) {

        var url = "http://127.0.0.1:5000/data"; // Local Flask server

        // this is the data that you want to send out
        var params = data;
        
        var	options = {                                            
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},                                                    
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        //System.println(params);

        // make the Communications.makeWebRequest() call to send data
        //Communications.makeWebRequest(url, ekesm, options, method(:onResponse));
        Communications.makeJsonRequest(url, params, options, method(:onResponse));
    
    }

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
}