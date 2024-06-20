#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys, json

## Constants
FILE_PATH = os.path.dirname(os.path.abspath(__file__))
print(f'here is the FILE_PATH: {FILE_PATH}')
SAVE_DATA_FILE_NAME = 'save_data.csv'

currentDir = os.path.dirname(os.getcwd())
print(f'Current working directory: {currentDir}')
sys.path.append(currentDir)
sys.path.append('./DeploymentComponents/mlops_artifacts/pdf_config_scripts')

import utils_for_pdf_files
from constants_for_pdf import *

model_config = json.dumps(MODEL_CONFIG)

## Test for Utils class
ut = utils_for_pdf_files.Utils(log_config='')

def test_get_pdf_files():
    ## Load pdf files
    pdf_files = ut.get_pdf_files(path_input = FILE_PATH + '/data/')
    ## Check if pdf files are retrieved
    assert len(pdf_files) == 1

def test_construct_cols():
    pass