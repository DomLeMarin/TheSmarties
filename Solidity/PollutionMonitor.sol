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
    
    SensorData[] public sensorData;
    bool continuousMonitoring = false;
    uint triggerLevel = 20;
    
    struct SensorData{
        bytes32 queryId;
        string location;
        string pollution;
        string URL;
        address owner;
    }
    
    function PollutionMonitor() public payable{
        
    }
    
    function initialize() public payable{
        sensorData.push(SensorData({
            queryId: 0,
            location: "east",
            pollution: "N.A",
            URL: "json(http://178.196.11.89:8080/arduino/sensor/1).sensor",
            owner: msg.sender
        }));
        sensorData.push(SensorData({
            queryId: 0,
            location: "middle",
            pollution: "N.A",
            URL: "json(http://178.196.11.89:8080/arduino/sensor/2).sensor",
            owner: msg.sender
        }));
        sensorData.push(SensorData({
            queryId: 0,
            location: "west",
            pollution: "N.A",
            URL: "json(http://178.196.11.89:8080/arduino/sensor/3).sensor",
            owner: msg.sender
        }));
        Log("Sensor added successfully!");
        update(false);
    }
    
    function addSensor(string loc, string URLName) payable {
        Log("Adding Sensor...");
        sensorData.push(SensorData({
            queryId: 0,
            location: loc,
            pollution: "N.A",
            URL: URLName,
            owner: msg.sender
        }));
        Log("Sensor added successfully!");
    }
    
    function getPollution(uint sensorIndex) public payable {
        Log("Getting pollution...");
        Log(sensorData[sensorIndex].pollution);
    }
    
    function getAveragePollution(string location) public payable {
        Log("Getting average pollution...");
        uint nLocation = 0;
        uint total = 0;
        for (uint i=0; i<sensorData.length; i++){
            if (stringsEqual(sensorData[i].location, location)) {
                total += stringToUint(sensorData[i].pollution);
                nLocation++;
            }
        }
        uint average = total/nLocation;
        Log(appendUintToString(location, average));
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
            for (uint i=0; i<sensorData.length; i++) {
                sensorData[i].queryId = oraclize_query(5, "URL", sensorData[i].URL);
                Log("Sensor successfully queried 1...");
            }
        } else {
             for (uint j=0; j<sensorData.length; j++) {
                sensorData[j].queryId = oraclize_query("URL", sensorData[j].URL);
                Log("Sensor successfully queried 2...");
            }
        }
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        Log(result);
         for (uint j=0; j<sensorData.length; j++) {
             if (sensorData[j].queryId == myid) {
                sensorData[j].pollution = result;
                if (stringToUint(result) > triggerLevel) {
                    PollutionAlert(sensorData[j].location);
                }
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