using Toybox.Application;
using Toybox.Communications;

class SeveralDatafieldsApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	sendData();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new SeveralDatafieldsView() ];
    }
    
    function sendData() {
		var url = "http://127.0.0.1:5000/data"; //I am testing with a local IP 
	
	    // this is the data that you want to send out
	    var params = {"a"=> 1, "b" => 2};
		
	  	var	options = {                                            
	  	 	:method => Communications.HTTP_REQUEST_METHOD_POST,
	   		:headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},                                                    
	   		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
 		};
 	
	   	// make the Communications.makeWebRequest() call to send data
	    Communications.makeJsonRequest(url, params, options, method(:onResponse));
    }
    
	function onResponse(responseCode, responseData){
		System.println(responseCode);
		System.println(responseData); 
	}

}