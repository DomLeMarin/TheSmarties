/*
import "dev.oraclize.it/api.sol" just works while using
dev.oraclize.it web IDE, needs to be imported manually otherwise
*/
pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
contract GetSensorDataOraclize is usingOraclize {
    event newValueQuery(string description); // used for showing in the event log
    event newValue(string value);
    
    function GetSensorDataOraclize() payable{
        query(false);
    }
    
    function query(bool repeat) payable {
        newValueQuery("Oraclize query was sent, standing by for the answer...");
        if (repeat)
            oraclize_query(5, "URL", "json(http://178.196.11.89:8080/arduino/switchOn/18).sensor");
        else
            oraclize_query("URL", "json(http://178.196.11.89:8080/arduino/switchOn/18).sensor");
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        newValue(result);
        query(true);
    }
}
