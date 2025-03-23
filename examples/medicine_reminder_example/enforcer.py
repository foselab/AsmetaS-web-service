"""
    Author:      Nico Pellegrinelli, Patrizia Scandurra
    Created:     21/03/2025
"""
import time
import logging_manager
from rest_client import RestClient

class PillboxEnforcer(RestClient):    
    def __init__(self, ip, base_port, asm_name):
        """
        Initialize the Enforcer class.
        """
        super().__init__(ip, base_port)
        self.logger = logging_manager.get_logger(__name__)
        self.asm_name = asm_name
        self.exec_id = None
    
    def begin_enforcement(self):
        """
        Start a new execution of the ASM.
        """
        try:
            response = self._send_request("POST", "start", params={"name": self.asm_name})
            self.exec_id = response.json()["id"]
            self.logger.info(f"Execution started with ID: {self.exec_id}")
        except Exception as e:
            self.logger.error(f"Failed to start execution: {e}")
            raise     
            
    def end_enforcement(self):
        """
        Stop the execution of the ASM.
        """
        try:
            self._send_request("DELETE", "stop-model", params={"id": str(self.exec_id)})
            self.logger.info(f"Execution stopped for ID: {self.exec_id}")
        except Exception as e:
            self.logger.error(f"Failed to stop execution: {e}")
            raise

    #First input for an initialization step (if necessary) of the ASM enforcement model 
    def initialize_enforcement_model(self,input_dict):
        endpoint = "step"
        json_data = {}
        json_data["id"] = self.exec_id
        json_data["monitoredVariables"] = input_dict    
        try:
            start_time = time.perf_counter()
            response = self._send_request("PUT", endpoint, json=json_data)
            delay = (time.perf_counter() - start_time) * 1000
            self.logger.info(f"ASM step performed for ID {self.exec_id} with delay {delay:.2f} ms")
            if not response.json()["runOutput"]["outvalues"]: # outAction not set (should never happen)
                self.logger.error("The ASM returned no outAction but should always return something")
                return None
            else:
                self.logger.info("Initialization done!")
                return response.json()["runOutput"]["outvalues"]["out_state"]
        except Exception as e:
            self.logger.error("ASM step execution failed: %s", e)
            raise    
    
    #Your output sanitization logic goes here. This is application-specific and depends on the
    #I/O interfaces (and also on Probe/Effector interfaces in case of gray-box enforcement).
    def sanitise_output(self, input_dict):
        """
        Perform a step on the ASM and repair (if necessary) the system action (i.e. output sanitisation).
        """
        endpoint = "step"
        json_data = {}
        json_data["id"] = self.exec_id
        json_data["monitoredVariables"] = input_dict    
        
        try:
            start_time = time.perf_counter()
            response = self._send_request("PUT", endpoint, json=json_data)
            delay = (time.perf_counter() - start_time) * 1000
            self.logger.info(f"ASM step performed for ID {self.exec_id} with delay {delay:.2f} ms")
            # Check if dictionary of out locations is empty
            enforced_actions = response.json()["runOutput"]["outvalues"]
            if not enforced_actions: # outAction not set (should never happen)
                self.logger.error("The ASM returned no outAction but should always return something")
                return None
            self.logger.info(f"ASM output: {enforced_actions}")
            if len(enforced_actions) <= 1:
                self.logger.info("Enforcement not applied.")
                return None
            else:
                self.logger.info("Enforcement applied - changing action")
            return enforced_actions
        except Exception as e:
            self.logger.error("ASM step execution failed: %s", e)
            raise    
        