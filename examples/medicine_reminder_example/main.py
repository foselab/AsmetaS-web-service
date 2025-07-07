"""
    Author:      Patrizia Scandurra
    Created:     21/03/2025
"""

import os
import sys
import uuid
import time
# Add the parent directory to the sys.path
#sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import logging_manager
from configuration_manager import ConfigurationManager
from model_uploader import ModelUploader
from enforcer import PillboxEnforcer


def read_input(input_dict):
    s = input("Insert input location values: ")
    x = s.split()
    for i in range(0,len(x),2):
        input_dict[x[i]] = x[i+1] 
   

def run(enforcer:PillboxEnforcer, model_uploader:ModelUploader):
    """
    Run a series of tests for the Target System, with or without an ASM model used as enforcement policy specification

    Parameters:

        enforcer (Enforcer or None):  enforcement module (if any) to validate and correct actions.
        model_uploader(ModelUploader or None): module for uploading the ASM model and its libraries.
   
    Returns:
        None
    """
        
    execute_enforcer = enforcer != None
    
    if execute_enforcer:
        start_time = time.perf_counter()
        model_uploader.upload_runtime_model()
        upload_delay = (time.perf_counter() - start_time) * 1000

    logger.info("--Starting new test run--")
    test_run_start = time.perf_counter()
    
    n_step = 0
    if execute_enforcer:
            total_sanitisation_delay = 0
            max_sanitisation_delay = 0
            enforcer_interventions = 0 # Number of step in which the enforcer changed the input action to a different action
            start_time = time.perf_counter()
            enforcer.begin_enforcement()
            start_delay = (time.perf_counter() - start_time) * 1000
            input_dict = {} #to prepare the dict for ASM inputs
            logger.info("Invoke the initialization step...")
            #Read the inputs for initializing the ASM model (a dict: the name of the function is the key, the value is the function's value)
            read_input(input_dict)
            #Invoke the initialization step
            out_state = enforcer.initialize_enforcement_model(input_dict)
            logger.info(f"ASM out_state: {out_state}")
    done = False
    while not done:
        logger.info("--Executing new step--")
        if execute_enforcer:
            # Observe the environment and the target system: your logics goes here (it's application-specific).
            #//Inputs from the target system Pillbox
            # monitored isPillMissed: Compartment -> Boolean //pill missed
            # monitored pillTakenWithDelay: Compartment -> Boolean // is true if the patient takes the pill but it causes mintointerfer violation
            # monitored actual_time_consumption: Compartment -> Seq(Natural) //Which time is the pill taken
            # monitored day: Integer //Day number since first day of use      
            # No Pillbox exists and co-executed with the PillboxEnforcer in this version, 
            # so for testing purposes, target system's inputs/outputs and probes values are 
            # to be read from keyboard here for a testing scenario (e.g., MP1: first pill taken, second pill rescheduled). 
            #Read the inputs for the ASM model (a dict: the name of the function is the key, the value is the function's value)
            input_dict = {} #to prepare the dict for ASM inputs
            read_input(input_dict)       
            # If the enforcer is running, try to sanitise the system's output with the ASM enforcement model
            start_time = time.perf_counter()
            n_step+=1
            #invoke the output sanitization step
            enforced_action = enforcer.sanitise_output(input_dict)
            #some stats 
            sanitisation_delay = (time.perf_counter() - start_time) * 1000
            max_sanitisation_delay = max(max_sanitisation_delay, sanitisation_delay)
            total_sanitisation_delay += sanitisation_delay
            # Change the action if the enforcer returns a new different one
            if enforced_action != None: 
                out_action = enforced_action
                enforcer_interventions += 1
            #else:
             #   logger.info(f"Action: {out_action}")
        # Run the step on the environment using the effector interface
        # No target system exists in this version, so we do nothing.  
        done = input('Do you want to stop execution (enter T to stop, any other character to continue)?: ') == 'T'  #for running a certain number of tests
            
    # Stop the execution of the runtime model
    if execute_enforcer:
            start_time = time.perf_counter()
            enforcer.end_enforcement()
            stop_delay = (time.perf_counter() - start_time) * 1000
            logger.info("Enforcer delays:")
            logger.info(f"* Start delay: {start_delay:.2f}ms")
            logger.info(f"* Total sanitisation delay: {total_sanitisation_delay:.2f}ms (max {max_sanitisation_delay:.2f}ms)")
            logger.info(f"* Stop delay: {stop_delay:.2f}ms")
            logger.info(f"Number of enforcer interventions: {enforcer_interventions} (out of {n_step})")

    test_execution_time = (time.perf_counter() - test_run_start) * 1000
    #logger.info(f"Test run {i} completed in {test_execution_time:.2f}ms:")
    logger.info(f"Test run completed in {test_execution_time:.2f}ms:")
    logger.info(f"* Model simulation steps: {n_step}")
    logger.info("")


    # Delete the runtime models
    if execute_enforcer:
        start_time = time.perf_counter()
        model_uploader.delete_runtime_model()
        delete_delay = (time.perf_counter() - start_time) * 1000
        logger.info(f"Upload model delay: {upload_delay:.2f}ms")
        logger.info(f"Delete model delay: {delete_delay:.2f}ms")



if __name__ == '__main__':
    CONFIG_FILE = "config.json"

    # Setup from a configuration file
    config_manager = ConfigurationManager(CONFIG_FILE)

    # Setup Logging
    execution_id = uuid.uuid4()
    level, log_folder = config_manager.get_logging_params()
    logging_manager.setup_logging(level, log_folder, execution_id)
    logger = logging_manager.get_logger(__name__)

    logger.info(f"Loaded config.json - Starting execution with id {execution_id}")
    config_manager.log_configuration()

    # Run the ASM model
    ip, port, asm_path, asm_file_name, other_models_names = config_manager.get_server_params()
    enforcer = PillboxEnforcer(ip, port, asm_file_name)
    model_uploader = ModelUploader(ip, port, asm_path, asm_file_name, other_models_names)
    try:                    
        run(enforcer,model_uploader)
    except Exception as e:
        # Try to run the tests again without the ASM model if at a certain point the server is down  
        logger.error("Failed to connect to the server - Executing the test runs WITHOUT the model")            
        run(None, None)
    #else:
    #    run(None, None)


