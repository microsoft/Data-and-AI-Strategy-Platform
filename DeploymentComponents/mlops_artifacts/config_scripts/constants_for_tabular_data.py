#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys
from datetime import datetime
dt = datetime.now()

SCRIPTS = {
    'SOURCE_DIR': './',
    '001': 'DeliveryIP_GitHub/mlops_artifacts/ml_scripts/dataprep.py',
    '002': 'DeliveryIP_GitHub/mlops_artifacts/ml_scripts/train_and_score.py',
    '003': 'DeliveryIP_GitHub/mlops_artifacts/ml_scripts/model_management.py'
}


USED_COL = {
    'INCLUDE': {
        'col1': 'Industries'
    },
    'EXCLUDE': {
        "col1": "ID", 
        "col2": "location",
        "col3": "UpdateOn"}
}

DATAIO = {
    'DATAPREP':{
        'STORE':{
            'NAME': 'dataprep',
            'PATH': 'intermediate_files'
        },
        'IN':{
            'DIR_TO_CONSUME': 'VATDaily-processed',
            'DATA_GENERATION': 2
        },
        'OUT':{
            'FILE_TO_STORE_TRAIN': 'train_{}.csv'.format(dt.strftime("%Y%m%d_%H%M%S")),
            'FILE_TO_STORE_SCORE': 'score_{}.csv'.format(dt.strftime("%Y%m%d_%H%M%S")),
            'FILE_TO_STORE_SCORE_ORIGINAL': 'original_{}.csv'.format(dt.strftime("%Y%m%d_%H%M%S"))
        },
    },
    'MODEL_MANAGEMENT':{
        'STORE':{
            'NAME': 'train_dir',
            'PATH': 'inferrenced_results'
        },
        'OUT':{
            'FILE_TO_STORE': 'VAT_Tax_Daily_with_score.csv'
        }
    }
}

MODEL_CONFIG = {
    'NAME': 'isolationForest_sklearn',
    'PATH': './',
    'FILE_NAME': 'isolation_forest.pkl',
    'CONTAMINATION': 0.1,
    'VERSION': '',
    'TAGS': {
        'algorithm': 'isolation forest',
        'frameowk': 'scikit-learn'
    },
    'P_VALUE': 0.05,
    'DATA_DRIFT_RESULT_OK': 'data_quality_passed'
}


PIPELINE_CONFIG = {
    'FROM_SYNAPSE': {
        'PARAMETER': 'train_or_inference',
        'VALUE': 'data_quality_passed'
    },
    'PUBLISHED':{
        'NAME': 'published_pipeline_isolation_forest',
        'DESCRIPTION': 'desc',
        'VERSION': 1.0
    },
    'DRAFT':{
        'NAME': 'DRAFT_PIPELINE_ISOLATION_FOREST',
        'DESCRIPTION': 'draft desc',
        'EXPERIMENT_NAME': 'draft_experiment',
        'TAGS': {
            'model_name': 'isolation_forest'
        },
        'PROPERTIES': {
            'misc': 'some properties'
        }

    }
}
