#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import sys
sys.path.append('./../common')

from constants_in_common import *

SCRIPTS = {
    'SOURCE_DIR': '../',
    '001': 'pipeline_for_pdf_files/src/dataprep_for_pdf_files.py',
    '002': 'pipeline_for_pdf_files/src/analyzeFormRecognizer.py',
    '003': 'pipeline_for_pdf_files/src/train_and_score.py'
}

USED_COLUMNS = {
    'INCLUDE': {
        'col1': 'Total Revenue(prior year)',
        'col2': 'Total Expenses(prior year)',
        'col3': 'P&L(prior year)',
        'col4': 'Total Revenue(current year)',
        'col5': 'Total Expenses(current year)',
        'col6': 'P&L(current year)'
    },
    'EXCLUDE': {
        'col1': 'Doc ID',
        'col2': 'Company Name'
    }
}

DATAIO = {
    'DATAPREP': {
        'STORE':{
            'NAME': 'dataprep',
            'PATH': 'pdf_files'
        },
        'IN':{
            'DIR_TO_CONSUME': 'invoices/samples/'
        }
    },
    'ANALYZE_WITH_FR':{
        'STORE':{
            'NAME': 'analyze',
            'PATH': 'extracted'
        }
    },
    'TRAIN_AND_SCORE':{
        'STORE':{
            'NAME': 'train_and_score',
            'PATH': 'scored_for_pdf'
        }
    }
}

MODEL_CONFIG = {
    'NAME': 'isolationForest_sklearn_for_pdf_files',
    'PATH': './',
    'FILE_NAME': 'isolation_forest.pkl',
    'CONTAMINATION': 0.05,
    'VERSION': '',
    'TAGS': {
        'algorithm': 'isolation forest',
        'frameowk': 'scikit-learn'
    }
}

FORM_RECOGNIZER_CONFIG = {
    'MODEL_ID': 'prebuilt-document',
    'PAGES': '1-3',
    'LOCALE': 'en-US'
}
