#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
# deferred_pms_ml_pipeline.py script is to publish the ml pipeline to do the following:
# prep the model
print('started the ml_artifacts_script.py')

# import modules needed for the pipeline
import os
import argparse
import requests
import azureml.core
from azureml.core.runconfig import RunConfiguration
from azureml.pipeline.core.graph import PipelineParameter
from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core.conda_dependencies import CondaDependencies
from azureml.core.compute_target import ComputeTargetException
from azureml.core.authentication import ServicePrincipalAuthentication
from azureml.pipeline.core import PipelineData, Pipeline, PublishedPipeline
from azureml.core import Workspace, Datastore, Dataset, Environment, Model, Experiment

print('Getting parameters and after importing modules')
# Get parameters
parser = argparse.ArgumentParser()
parser.add_argument('--adls_rg', type = str, dest = 'adls_rg', help = 'Datalake resource group')
parser.add_argument('--adls_name', type = str, dest = 'adls_name', help = 'Datalake Name')
parser.add_argument('--ws_name', type = str, dest = 'ws_name', help = 'Name of ML workspace')
parser.add_argument('--amls_rg', type = str, dest = 'amls_rg', help = 'Resource Group Name')
parser.add_argument('--client_id', type=str, dest = 'client_id', help = 'Workspace Client id')
parser.add_argument('--client_secret', type = str, dest = 'client_secret', help = 'Workspace Client Secret')
parser.add_argument('--sub_id', type = str, dest = 'sub_id', help = 'Subscription ID')
parser.add_argument('--tenant_id', type = str, dest = 'tenant_id', help = 'Tenant ID')
parser.add_argument('--cluster_name', type = str, dest = 'cluster_name', help = 'Compute Cluster Name')

print('on line 36')
# Args - using the parser to get the 
args = parser.parse_args()

# Using the args to create the variables
adls_rg = args.adls_rg
adls_name = args.adls_name
ws_name = args.ws_name 
amls_rg = args.amls_rg
client_id = args.client_id
client_secret = args.client_secret
sub_id = args.sub_id
tenant_id = args.tenant_id
cluster_name = args.cluster_name

print("Azure ML SDK Version: ", azureml.core.VERSION)

print('Creation of the function to connect to the workspace using a service principal')
def connecting_to_workspace(tenant_id, client_id, client_secret, sub_id, amls_rg, ws_name):
    '''
    Function to connect to the workspace for amls
    Input: tenant_id, client_id, client_secret, sub_id, amls_rg and ws_name
    Output: workspace
    '''
    # Creation of the service principal
    svc_pr = ServicePrincipalAuthentication(
        tenant_id = tenant_id,
        service_principal_id =  client_id,
        service_principal_password = client_secret)

    print(f'Connecting to the workspace {ws_name}')
    # Connection to the workspace
    ws = Workspace(subscription_id = sub_id,
                resource_group = amls_rg, 
                workspace_name = ws_name,
                auth = svc_pr)
    
    return ws

# print(f'Function to register the adls datastore: {datastore_name}')
def register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name):
    '''
    Function that registers the sql datastore in case it is not registered yet
    Input: ws, tenant_id, datastore_name, sq_server_name, db_name, client_id, client_secret
    Output: nothing
    '''
    try:
        adls_datastore = Datastore.register_azure_data_lake_gen2(
            workspace = ws,
            tenant_id = tenant_id,
            datastore_name = datastore_name,
            subscription_id = sub_id,
            resource_group = adls_rg,
            account_name = adls_name,
            client_id = client_id, 
            client_secret = client_secret,
            filesystem = file_system,
            overwrite = True)
        print(f'trying to register datastore {datastore_name} for the datalake {adls_name} in the workspace {ws}')

    except Exception as e:
        print(e)

print('Function to register the model')
def register_model(workspace):
    '''
    This function registers the model for deferred_pms
    Input: workspace
    Output: model_name and model_description
    '''
    #change directory to the previous folder (AMLS/phase2)
    location = os.getcwd()
    print(f'here is the location: {location}')
    os.chdir("DeliveryIP_GitHub/mlops_artifacts")
    location = os.getcwd()
    print(f'here is the new location: {location}')

    # Register models for Work Orders:
    root_folder = './models/'
    model_path = root_folder + 'isolation_forest.pkl'

    model_name = 'isolationForest_sklearn'

    model_description = 'Model for anomaly detection with isolation forest'

    tags = {'source': 'upload from repo'}
    try:
        Model.register(model_path = model_path,
                    model_name = model_name,
                    tags = tags,
                    description = model_description,
                    workspace = workspace)
        print('Successfully registered', model_name)
    except Exception as e:
        print(e)

    return model_name, model_description

print(f'Verify that {cluster_name} exists function')
def verify_cluster(ws, cluster_name):
    '''
    Function to verify that the cluster exists
    Input: ws and cluster_name
    Output: pipeline_cluster
    '''
    # Verify that cluster exists
    try:
        pipeline_cluster = ComputeTarget(workspace = ws, name = cluster_name)
        print('Found existing cluster, use it.')
    except ComputeTargetException:
        # If not, create it
        compute_config = AmlCompute.provisioning_configuration(vm_size='STANDARD_E4_V3',
                                                            min_nodes=0,
                                                            max_nodes=4,
                                                            idle_seconds_before_scaledown=1800)
        pipeline_cluster = ComputeTarget.create(ws, cluster_name, compute_config)

# Defining main function
def main():
    '''
    Main function that will put together all of the functions above
    Input: Nothing
    Output: Nothing
    '''
    ws = connecting_to_workspace(tenant_id, client_id, client_secret, sub_id, amls_rg, ws_name)
    print(f'Now connected to the workspace {ws_name}')

    file_system = "raw"
    datastore_name = "ds_adls_raw"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_raw')

    file_system = "curated"
    datastore_name = "ds_adls_curated"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_curated')

    file_system = "structured"
    datastore_name = "ds_adls_structured"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_structured')

    file_system = "data-processed"
    datastore_name = "ds_adls_data_processed"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_data_processed')

    file_system = "ml-processed"
    datastore_name = "ds_adls_ml_processed"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_ml_processed')

    file_system = "ml-pipeline-intermediate"
    datastore_name = "ds_adls_ml_pipeline_intermediate"
    register_adls_datastore(ws, tenant_id, adls_name, client_id, client_secret, sub_id, adls_rg, file_system, datastore_name)
    print('Registered the datastore ds_adls_ml_pipeline_intermediate')

    # Registering the model
    model_name, model_description = register_model(ws)
    print("Model is registered")

    # Running the verify_cluster 
    verify_cluster(ws, cluster_name)

# Using the special variable
# __name__
if __name__=="__main__":
    main()