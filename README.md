# AsmetaS-web-service: online use of the Abstract State Machines (ASM) simulator AsmetaS&#8203;@run.time via a REST/JSON API

 `AsmetaS@run.time` is a model engine for the runtime simulation of Abstract State Machine (ASM) models.
It is part of the formal modelling and analysis toolset ASMETA: https://asmeta.github.io/index.html
This repository contains experimental code with examples on how to use the simulator  `AsmetaS@run.time`  as a standalone simulation server.

## Initial setup

This guide assumes you are have **Python 3.11** installed. \
Once Python is ready, move to your working dir and execute these commands:

```bash
git clone https://github.com/foselab/AsmetaS-web-service
cd /AsmetaS-web-service 
pip install -r requirements.txt
```

## How to run

### Start the `Asmeta@run.time` server on port 8080
In order to run the server it is necessary to have Java JRE 17 or higher and Python installed on your machine. 

To run the server, move to the `asmeta server` folder and run:

```bash
python asmeta_runtime_server.py
```

### Execute the code examples (client programs invoking the simulation service).

Once the server is up, move to the repository's folder `examples`, move to any example directory (e.g., `toy_example`) and run:

```bash
python main.py
```

Simulation-related parameters can be modified by editing the `config.json` file.

The following is a brief description of each field in the configuration file:
* **simulation**:
  * **ip**: the IP address of the `Asmeta@run.time` server.
  * **base_port**: the port on which the `Asmeta@run.time` server listens (e.g., 8080).
  * **spec_path**: the path to the folder containing the Asmeta models (you can use `"../asmeta spec/models"`).
  * **runtime_model**: the Asmeta model to be used at runtime.
* **logging**:
  * **level**: the logging level.
  * **target_folder**: the directory where log file is stored.

**NOTE**
* **the `"ip"` nested-field is optional and if it is not set the ip is dynamically determined (especially if the script is running in Windosw Subsystem for Linux WSL, otherwise, it is set to `localhost`).**
For example, assuming a local server is running the `AsmetaS@run.time` simulator on `localhost:8080`, the following configuration file sets up a simulation scenario with the `SafetyEnforcerModel.asm` as runtime model:

```json
{
  "asmeta_server":{
    "ip": "localhost",
    "base_port": 8080,
    "spec_path": "../../resources/models",
    "runtime_model": "SafetyEnforcerModel.asm"},
  "logging":{
    "level": "INFO",
    "target_folder": "log"}
}
```

