/*
import "dev.oraclize.it/api.sol" just works while using
dev.oraclize.it web IDE, needs to be imported manually otherwise
*/
pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
contract PollutionMonitor is usingOraclize {
    event newValueQuery(string description); // used for showing in the event log
    event Log(string value);
    event PollutionAlert(string location);
    
    string[3] regions = ["east", "middle", "west"];
    
    SensorData sensor0;
    SensorData sensor1;
    SensorData sensor2;
    bytes32 sensorQuery0;
    bytes32 sensorQuery1;
    bytes32 sensorQuery2;
    bool continuousMonitoring = false;
    uint triggerLevel = 20;
    
    struct SensorData{
        string location;
        string pollution;
    }
    
    function PollutionMonitor() public payable{
        Log("Created!");
    }
    
    function initialize() public payable{
        Log("Initializing");
        sensor0=SensorData("east","N.A");
        sensor1=SensorData("middle","N.A");
        sensor2=SensorData("west","N.A");
        Log("Sensor added successfully!");
        update(false);
    }
    
   /* function addSensor(string loc, string URLName) payable {
        Log("Adding Sensor...");
        sensorData.push(SensorData({
            queryId: 0,
            location: loc,
            pollution: "N.A",
            URL: URLName,
            owner: msg.sender
        }));
        Log("Sensor added successfully!");
    }*/
    
    function getPollution(uint sensorIndex) public payable {
        Log("Getting pollution...");
        if (sensorIndex == 0){
            Log(sensor0.pollution);
        }else if(sensorIndex == 1){
            Log(sensor1.pollution);
        }else{
            Log(sensor2.pollution);
        }
    }
    
    function getAveragePollution(string location) public payable {
        Log("Getting average pollution...");
    /*    uint nLocation = 0;
        uint total = 0;
        
        
        for (uint i=0; i<sensorData.length; i++){
            if (stringsEqual(sensorData[i].location, location)) {
                total += stringToUint(sensorData[i].pollution);
                nLocation++;
            }
        }
        uint average = total/nLocation;
        Log(appendUintToString(location, average));*/
    }
    
    
    function startMonitoring() public payable {
        continuousMonitoring = true;
        update(true);
    }
    
    function stopMonitoring() public payable {
        continuousMonitoring = false;
    }
    
    function update(bool useDelay) payable {
        Log("Updating...");
        if (useDelay) {
            sensorQuery0 = oraclize_query(5, "URL", "json(http://178.196.11.89:8080/arduino/sensor/1).sensor");
            sensorQuery1 = oraclize_query(5, "URL", "json(http://178.196.11.89:8080/arduino/sensor/2).sensor");
            sensorQuery2 = oraclize_query(5, "URL", "json(http://178.196.11.89:8080/arduino/sensor/3).sensor");
            Log("Sensor successfully queried 1...");
        } else {
            sensorQuery0 = oraclize_query("URL", "json(http://178.196.11.89:8080/arduino/sensor/1).sensor");
            sensorQuery1 = oraclize_query("URL", "json(http://178.196.11.89:8080/arduino/sensor/2).sensor");
            sensorQuery2 = oraclize_query("URL", "json(http://178.196.11.89:8080/arduino/sensor/3).sensor");
            Log("Sensor successfully queried 2...");
        }
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        
        if (stringToUint(result) > triggerLevel){
            if (myid == sensorQuery0){
                PollutionAlert(sensor0.location);
            }else if (myid == sensorQuery1){
                PollutionAlert(sensor1.location);
            }else{
                PollutionAlert(sensor2.location);

            }
        }
        if (continuousMonitoring)
            update(true);
    }
    
    function stringsEqual(string memory _a, string memory _b) internal returns (bool) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
                return false;
        return true;
    }
    
    function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    
    function appendUintToString(string inStr, uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i + 1);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j <= i; j++) {
            s[j + inStrb.length] = reversed[i - j];
        }
        str = string(s);
    }
    
    function uintToString(uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
        
}