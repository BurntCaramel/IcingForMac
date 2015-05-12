(function() {
	function trace() {
		try {
			throw new Error('myError');
		}
		catch(e) {
			return e.stack;
		}
		
		return '';
	}
	
	function consoleMessage(type, messageArguments) {
		window.webkit.messageHandlers.console.postMessage({
			type: type,
			'arguments': JSON.stringify([].slice.call(messageArguments)),
			'trace': trace()
		});
	}
	
	window.console.log = function() {
		consoleMessage('log', arguments);
	};
	
	window.console.error = function() {
		consoleMessage('error', arguments);
	};
	
	window.console.warn = function() {
		consoleMessage('warn', arguments);
	};
})();
