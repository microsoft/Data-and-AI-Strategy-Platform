#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
# Retrieve common setting
import os, sys, json, argparse
from azureml.core import Workspace
from azureml.core.authentication import ServicePrincipalAuthentication

currentDir = os.path.dirname(os.getcwd())

print(f'here is the current directory: {currentDir}')

sys.path.append('./DeploymentComponents/mlops_artifacts/config_scripts/')

# # Retrieve libraries and functions from utils
from utils_provision import *

## Add arguments, if needed
parser = argparse.ArgumentParser()
parser.add_argument('--client_id', dest = 'client_id')
parser.add_argument('--client_secret', dest = 'client_secret')
parser.add_argument('--tenant_id', dest = 'tenant_id', help = 'tenant id')
parser.add_argument('--resource_group', dest = 'resource_group', help = 'resource group name')
parser.add_argument('--define_pipeline', dest='define_pipeline', help='optional', type=int)
parser.add_argument('--draft_endpoint', dest='draft_endpoint', help='optional', type=int)
parser.add_argument('--workspace_name', dest = 'workspace_name')
parser.add_argument('--subscription_id', dest = 'subscription_id')

args = parser.parse_args()

log_config = json.dumps(LOG_CONFIG)

svc_pr = ServicePrincipalAuthentication(
    tenant_id = TENANT_ID,
    service_principal_id = args.client_id,
    service_principal_password = args.client_secret)

ws = Workspace(
    subscription_id = SUBSCRIPTION_ID,
    resource_group = RESOURCE_GROUP,
    workspace_name = args.workspace_name,
    auth = svc_pr
    )

## Initialize the class
pp = provision_pipeline(## logging
                        log_config=log_config
                        ## Set for Service principal
                        ,sp_id=args.client_id
                        ,sp_secret=args.client_secret
                        )

## Retrieve AML Workspace
pp.retrieveAMLWorkspace()

if args.define_pipeline == 1:
    ## Retrieve Azure ML resources
    pp.configAMLResource()

    ## Set variables
    pp.setVariables()

    ## Define AML pipeline
    pp.definePipeline()

if args.draft_endpoint == 1:
    ## Populate Draft pipeline
    pp.draftAMLPipeline()
else:
    # Publish AML pipeline
    pp.publishAMLPipeline()
