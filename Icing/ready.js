window.webkit.messageHandlers.ready.postMessage(true);

/*(function() {
	var callbackQueue = [];
	
	function readyCallbackHandler(callback) {
		setTimeout(callback, 0);
	}
	
	function documentDidLoad() {
		callbackQueue.forEach(function(callback) {
			callback();
		})
		
		document.removeEventListener('DOMContentLoaded', documentDidLoad);
		
		window.callWhenDocumentLoaded = readyCallbackHandler;
	}
	
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', documentDidLoad);
		
		window.callWhenDocumentLoaded = function(callback()) {
			callbackQueue.push(callback);
		}
	}
	else {
		window.callWhenDocumentLoaded = readyCallbackHandler;
	}
 
	callWhenDocumentLoaded(function() {
		window.webkit.messageHandlers.ready.postMessage(true);
	});
})();*/