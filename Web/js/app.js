
	
	window.onload = init;
	///Insert your contract address var here:
	var contractAddress = '0xfc32187741addb63b27b1eba3a1175d69ed262bd';
	var contractABI = [{"constant":false,"inputs":[],"name":"startMonitoring","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"s","type":"string"}],"name":"stringToUint","outputs":[{"name":"result","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"myid","type":"bytes32"},{"name":"result","type":"string"}],"name":"__callback","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"myid","type":"bytes32"},{"name":"result","type":"string"},{"name":"proof","type":"bytes"}],"name":"__callback","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"stopMonitoring","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"useDelay","type":"bool"}],"name":"update","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"loc","type":"string"},{"name":"URLName","type":"string"}],"name":"addSensor","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[],"name":"initialize","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"sensorData","outputs":[{"name":"queryId","type":"bytes32"},{"name":"location","type":"string"},{"name":"pollution","type":"string"},{"name":"URL","type":"string"},{"name":"owner","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"sensorIndex","type":"uint256"}],"name":"getPollution","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"inStr","type":"string"},{"name":"v","type":"uint256"}],"name":"appendUintToString","outputs":[{"name":"str","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"location","type":"string"}],"name":"getAveragePollution","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"v","type":"uint256"}],"name":"uintToString","outputs":[{"name":"str","type":"string"}],"payable":false,"type":"function"},{"inputs":[],"payable":true,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"description","type":"string"}],"name":"newValueQuery","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"string"}],"name":"Log","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"location","type":"string"}],"name":"PollutionAlert","type":"event"}];
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

	var event = contract.Log({},{fromBlock:20000, toBlock:50000} );
	event.watch(
		function(error, result){
			if (error) {
				alert("Error: " + error);
			} else {
				document.getElementById('logging').innerHTML += "<p><small>"+result.args.value+"</small></p>";
			}
		}
	);
	
	var pollutionAlert = contract.PollutionAlert({},{fromBlock:20000, toBlock:50000});
	pollutionAlert.watch(
		function(error,result) {
			if (error) {
				alert("Error: " + error);
			} else {
				alert("Pollution Alert");
				document.getElementById('updateMap').innerHTML += "<p> Pollution Alert in "+result.args.value+"</p>";
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
		
		contract.initialize.sendTransaction({},
			{from:web3.eth.defaultAccount, gas:100000}, function(err, res) {if (err) alert(err); else alert(res);}
		);
	};

	function getSensorData() {
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
		
				



  