/*
import "dev.oraclize.it/api.sol" just works while using
dev.oraclize.it web IDE, needs to be imported manually otherwise
*/
pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
contract PollutionMonitor is usingOraclize {
    event newValueQuery(string description); // used for showing in the event log
    event Log(string value);
    
    string[3] regions = ["east", "middle", "west"];
    
    struct answer{
        // uint sensor 1,2,3
        // uint polution;
    }
    
    struct sensorData{
        string location;
        string polution;
        string URL;
        address owner;
    }
    
    uint nofsensors = 0;
    
    sensorData[3] sensors;
    
    function PollutionMonitor() payable{
        update(false);
    }
    
    function addSensor(string location, string URL){
        Log("Adding Sensor...");
        if (!stringsEqual(location, regions[0]) && !stringsEqual(location,regions[1]) && !stringsEqual(location,regions[2])) throw;
        address owner = msg.sender;
        Log("Owner successfully assigned.");
        sensors[nofsensors] = sensorData(location, "", URL, owner);
        Log("New sensor created.");
        nofsensors++;
        Log("Sensor added successfully!");
    }
    
    function getPollution(uint sensor) /*returns (string polution)*/ {
        Log("Getting pollution...");
        Log(sensors[sensor].polution);
        //return sensors[sensor].polution;
    }
    
    function getPollution(string location) /*returns (string polution)*/{
        Log("Getting pollution...");
        for (uint i=0; i<nofsensors; i++){
            if (stringsEqual(sensors[i].location, location)) Log(sensors[i].polution);//return sensors[i].polution;
        }
    }
    
    function getMap() payable {
        Log("Getting map...");
        Log(sensors[indexForLocation("east")].polution);
        Log(sensors[indexForLocation("middle")].polution);
        Log(sensors[indexForLocation("west")].polution);
    }
    
    function indexForLocation(string location) returns (uint index){
        Log("Getting index for location...");
        for (uint i=0; i<nofsensors; i++){
            if (stringsEqual(sensors[i].location, location)) return i;
        }
    }
    
    function startMonitoring(){
        update(false);
    }
    
    function update(bool useDelay) {
        Log("Updating...");
        if (useDelay)
            oraclize_query(5, "URL", "json(http://178.196.11.89:8080/arduino/switchOn/18).sensor");
        else
            oraclize_query("URL", "json(http://178.196.11.89:8080/arduino/switchOn/18).sensor");
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        Log(result);
        sensors[0].polution = result;
        sensors[1].polution = result;
        sensors[2].polution = result;
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
        
    function helloWorld(){
        Log("HelloWorld");
    }
}
 