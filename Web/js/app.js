
	
	window.onload = init;
	///Insert your contract address var here:
	var contractAddress = '0xed6774fa1458dc34ac482c1f8d8fc2072e5749e5';
	var contractABI = [{"constant":false,"inputs":[],"name":"startMonitoring","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"location","type":"string"}],"name":"indexForLocation","outputs":[{"name":"index","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"myid","type":"bytes32"},{"name":"result","type":"string"}],"name":"__callback","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"myid","type":"bytes32"},{"name":"result","type":"string"},{"name":"proof","type":"bytes"}],"name":"__callback","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"useDelay","type":"bool"}],"name":"update","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"location","type":"string"},{"name":"URL","type":"string"}],"name":"addSensor","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"getMap","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"sensor","type":"uint256"}],"name":"getPollution","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"helloWorld","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"location","type":"string"}],"name":"getPollution","outputs":[],"payable":false,"type":"function"},{"inputs":[],"payable":true,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"description","type":"string"}],"name":"newValueQuery","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"string"}],"name":"Log","type":"event"}];
 	var continuousMonitoring = false;
	
	function init() {

		if(typeof web3 == 'undefined') {
    		// Alert the user they are not in a web3 compatible browser
			alert("Alert: You are not using a browser supporting web3. Please use Mist (or MetaMask)")
    		return;    
 		}

		
    	var coinbase = web3.eth.coinbase;
  		document.getElementById('coinbase').innerText = coinbase;

		var block = web3.eth.getBlockNumber(function(error, result){ 
			if (error) {
				alert("Error: " + error);
			} else {
				document.getElementById('latestBlock').innerText = result;
				}
			}
		);
		
		web3.eth.getCode(contractAddress, function(e, r) { 
    		if (!e && r.length > 3) 
        		loadContract();
 			});

	var contract = web3.eth.contract(contractABI).at(contractAddress);

	var event = contract.Log({},{fromBlock:10000, toBlock:50000} );
	event.watch(
		function(error, result){
			if (error) {
				alert("Error: " + error);
			} else {
				document.getElementById('logging').innerHTML += "<p><small>"+result.args.value+"</small></p>";
			}
		}
	);
	
	var pollutionAlert = contract.PollutionAlert({},{fromBlock:block-100, toBlock:50000});
	pollutionAlert.watch(
		function(error,result) {
			if (error) {
				alert("Error: " + error);
			} else {
				document.getElementById('logging').innerHTML += "<p> Pollution Alert in "+result.args.value+"</p>";
				if (result.args.value == "west") {
					$('.stately li#ca').css({"color":"#FF0000"});
				}
				if (result.args.value == "middle") {
					$('.stately li#tx').css({"color":"#FF0000"});
				}
				if (result.args.value == "east") {
					$('.stately li#ny').css({"color":"#FF0000"});
				}				
			}
		}
	);
		
				
		
	}
	 
	function loadContract() {
      contract = web3.eth.contract(contractABI).at(contractAddress);
	}

	function addSensor() {
		var location = document.getElementById("addSensorLocation").value;
		var URL = document.getElementById("addSensorURL").value;
		
		contract.addSensor.sendTransaction({location,URL},
			{from:web3.eth.defaultAccount, gas:100000}, function(err, res) {if (err) alert(err); else alert(res);}
		);
	};

	function getSensor() {
		var sensor = document.getElementById("getSensor").value;
		contract.addSensor.sendTransaction(sensor,
			{from:web3.eth.defaultAccount, gas:100000}, function (error, result){ 
					alert("You are getting a sensor");
			}
		);
	};;

	function getAveragePollution() {
        var region = document.getElementById("getAveragePollution").value;
		contract.getAveragePollution.sendTransaction(region,
			{from:web3.eth.defaultAccount, gas:100000}, function (error, result){ 
				alert("You are getting average pollution");
			}
		);	
	}
	
	function updateMap() {
		continuousMonitoring = !continuousMonitoring;
		if (continuousMonitoring) {
			document.getElementById('updateMap').innerText = "Continuously loading...";
			contract.startMonitoring.sendTransaction(
				{from:web3.eth.defaultAccount, gas:100000}, function(err, res) {if (err) alert(err); else alert(res);}
			);
			
		} 
		else {
			document.getElementById('updateMap').innerText = "";
			contract.stopMonitoring.sendTransaction(
				{from:web3.eth.defaultAccount, gas:100000}, function(err, res) {if (err) alert(err); else alert(res);}
			);
		}
		
	}
		
				



  