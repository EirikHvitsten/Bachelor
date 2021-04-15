/*
 * Simple test app to demonstrate makeWebRequest() issue with https in SDK 2.3.{1,2,3,4} Mac simulator
 * See README.md
 */
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Sensor;
using Toybox.Application;
using Toybox.Position;


const URL = "http://127.0.0.1:5000/data";

class GarminWebRequestTestApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
        
    }

    // onStart() is called on application start up
    function onStart(state) {
        sendData({"a"=> 1, "b" => 2});
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new GarminWebRequestTestView("Starting " + URL) ];
    }
	
    function sendData(dataen) {

        var url = "http://127.0.0.1:5000/data"; //I am testing with a local IP 

        // this is the data that you want to send out
        var params = dataen;
        var ekesm = "hei";
        
        var	options = {                                            
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},                                                    
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        System.println(params);

        // make the Communications.makeWebRequest() call to send data
        Communications.makeWebRequest(url, ekesm, options, method(:onResponse));
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
}
