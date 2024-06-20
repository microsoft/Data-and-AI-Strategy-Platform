#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import argparse, os
from azureml.core.model import Model, InferenceConfig
#from azureml.core.authentication import MsiAuthentication
from azureml.core.webservice import AciWebservice, Webservice
from azureml.core import Datastore, Dataset, Environment, Workspace
from azureml.core.authentication import ServicePrincipalAuthentication

## Add arguments, if needed
parser = argparse.ArgumentParser()
parser.add_argument('--client_id', dest = 'client_id')
parser.add_argument('--client_secret', dest = 'client_secret')
parser.add_argument('--tenant_id', dest = 'tenant_id')
parser.add_argument('--subscription_id', dest = 'subscription_id')
parser.add_argument('--resource_group', dest = 'resource_group')
parser.add_argument('--workspace_name', dest = 'workspace_name')
args = parser.parse_args()

svc_pr = ServicePrincipalAuthentication(
    tenant_id = args.tenant_id,
    service_principal_id = args.client_id,
    service_principal_password = args.client_secret)

ws = Workspace(
    subscription_id = args.subscription_id,
    resource_group = args.resource_group,
    workspace_name = args.workspace_name,
    auth = svc_pr
    )

print(f'here is the workspace: {ws}')

model = Model(ws, 'isolationForest_sklearn')
print(f'here is the model {model}')

#deployment configuration setup
deployment_config = AciWebservice.deploy_configuration(cpu_cores = 1, memory_gb = 1)
print(f'here is the deployment_config setup: {deployment_config}')

#env = Environment(name = "env01")
# environment setup
env = Environment(name = "AzureML-sklearn-1.0-ubuntu20.04-py38-cpu")
print(f'here is the environment: {env}')

location = os.getcwd()
print(f'here is the location we are in: {location}')
# setting up the inference configuration
inference_config = InferenceConfig(
    environment = env,
    source_directory = "./DeploymentComponents/mlops_artifacts/config_scripts",
    entry_script = "./score.py",
)
# adding a comment
print(f'here is the inference_config: {inference_config}')

# deploy the model using ACI for actstaxdevusemlwcrkyiwasak9
service = Model.deploy(workspace = ws, name = "isolation-forest-model", models = [model], inference_config = inference_config, deployment_config = deployment_config, overwrite = True)
service.wait_for_deployment(show_output = False)
print(f'The service state is for isolation-forest-model: {service.state}')

print(f'here are the logs: {service.get_logs()}')