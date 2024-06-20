#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
SUBSCRIPTION_ID = "__subid__"
RESOURCE_GROUP = "__mlrg__"
VAULT_URL = 'https://' + "__amlskv__" + '.vault.azure.net/'
TENANT_ID = "__tenantid__"

AML_CONFIG = {
    'WORKSPACE_NAME': "__amlswksp__",
    'COMPUTER_TARGET_NAME': "__cluster__",
    'ENVIRONMENT':{'NAME': 'env01',
                   "FILE_PATH": './DeploymentComponents/mlops_artifacts/config_scripts/requirements.txt'
    },
    'EXPERIMENT_NAME': 'isolation_forest_exp',
}

DATASTORE = {
    'RAW': 'ds_adls_raw',
    'DATA_PROCESSED': 'ds_adls_data_processed',
    'ML_PROCESSED': 'ds_adls_ml_processed',
    'ML_INTERMEDIATE': 'ds_adls_ml_pipeline_intermediate'
}

LOG_CONFIG = {
    'LEVEL': 10,
    'CUSTOM_DIMENSIONS_FLG': {
        'parent_run_id': True,
        'step_id': True,
        'step_name': True,
        'experiment_name': True,
        'run_url': True}
}