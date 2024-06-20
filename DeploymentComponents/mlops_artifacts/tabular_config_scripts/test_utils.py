#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys, json
import sklearn

## Constants
FILE_PATH = os.path.dirname(os.path.abspath(__file__))
SAVE_DATA_FILE_NAME = 'save_data.csv'

currentDir = os.path.dirname(os.getcwd())
print(f'Current working directory: {currentDir}')
sys.path.append(currentDir)
sys.path.append('./DeploymentComponents/mlops_artifacts/tabular_config_scripts')

import utils
from constants_for_tabular_data import *

## Load variables
model_config = json.dumps(MODEL_CONFIG)

## Instantiation
ut = utils.Utils(log_config='')

dp = utils.DataPrep(input_data=FILE_PATH + '/data/' + SAVE_DATA_FILE_NAME,
                exclude_columns='{"col1": "area"}',
                include_columns='{"col1": "word"}',
                output_path=FILE_PATH,
                intermediate_train_file=FILE_PATH,
                intermediate_score_file=FILE_PATH,
                intermediate_score_original_file=FILE_PATH,
                log_config='')

ts = utils.trainScore(log_config={},
                    intermediate_path=FILE_PATH + '/data/',
                    intermediate_train_file='test_data.csv',
#                    intermediate_score_file='test_data.csv',
#                    intermediate_score_original_file='test_data.csv',
                    intermediate_model_path=FILE_PATH,
#                    output_path=FILE_PATH,
#                    step2_file='',
                    model_config=model_config
)

## Test for Utils class
def test_load_data():
    df = ut.load_data(FILE_PATH + '/data/test_data.csv')
    assert df.shape[0] == 3
    assert df.shape[1] == 2

def test_load_df():
    df_total = ut.load_df(FILE_PATH + '/data/')
    ## Record number check
    assert df_total.shape[0] == 6
    ## Column number check
    assert df_total.shape[1] == 2

def test_save_data():
    df_total = ut.load_df(FILE_PATH + '/data/')  ##6 lines
    ut.save_data(output_path=FILE_PATH + '/data/',
                file_path=SAVE_DATA_FILE_NAME,
                df=df_total,
                day_subfolder=False)
    df_total_copy = ut.load_df(FILE_PATH + '/data/') 
    ## Record number check
    assert df_total_copy.shape[0] == 12
    ## Column number check
    assert df_total_copy.shape[1] == 2

    df_total_saved = ut.load_data(os.path.join(FILE_PATH + '/data/', SAVE_DATA_FILE_NAME))
    os.remove(os.path.join(FILE_PATH + '/data/', SAVE_DATA_FILE_NAME))
    ## Record number check
    assert df_total_saved.shape[0] == 6
    ## Column number check
    assert df_total_saved.shape[1] == 2
    ## Remove used file

## Test for DataPrep class
def test_init_dp():
    ## Check instantiation of DataPrep class
    assert dp.include_col_list[0] == 'word'
    assert dp.exclude_col_list[0] == 'area'

def test_extract_numeric_columns():
    df_total = ut.load_df(FILE_PATH + '/data/')  ##6 lines
    ut.save_data(output_path=FILE_PATH + '/data/',
                file_path=SAVE_DATA_FILE_NAME,
                df=df_total,
                day_subfolder=False)
    df_total_copy = ut.load_df(FILE_PATH + '/data/') 
    df_numeric_columns = dp.extract_numeric_columns(df=df_total_copy)
    os.remove(os.path.join(FILE_PATH + '/data/', SAVE_DATA_FILE_NAME))
    ## Check total column number
    assert df_total.shape[1] == 2
    ## Check selected column number
    assert df_numeric_columns.shape[1] == 1

def test_extract_dataset():
    df_plural = ut.extract_dataset(path_input=FILE_PATH + '/data/',
                                    data_generation=2)
    assert df_plural.shape[0] == 6
    assert df_plural.shape[1] == 2

## Test in DataPrep class
def test_extract_numeric_columns():
    df = ut.load_data(FILE_PATH + '/data/test_data.csv')
    df_num = dp.extract_numeric_columns(df=df)

    ## Only one column should be selected
    assert df_num.shape[1] == 1

def test_convert_to_list():
    exclude_columns_list = dp.convert_to_list(dp.exclude_cols)

    assert exclude_columns_list == ['area']

def test_excludeColumns():
    ## Prepare base DataFrame
    df = ut.load_data(FILE_PATH + '/data/test_data.csv')
    df_num = dp.excludeColumns(df)

    ## Check original columns of base DataFrame
    assert df.shape[1] == 2
    ## Only 'word' column appears
    assert df_num.columns[0] == 'word'

def test_getDummyVariables():
    ## Prepare base DataFrame
    df = ut.load_data(FILE_PATH + '/data/test_data.csv')
    df = dp.getDummyVariables(df)
    ## Column to be expanded
    assert dp.include_col_list[0] == 'word'
    ## Column should be 'word_5', 'word_6', 'word_7'
    assert df.shape[1] == 3

def test_commonDataprep():
    ## Prepare base DataFrame
    df = ut.load_data(FILE_PATH + '/data/test_data.csv')
    df = dp.commonDataprep(df=df, train_proc=True)

    ## Check original columns to be excluded or included:
    assert dp.exclude_col_list[0] == 'area'
    assert dp.include_col_list[0] == 'word'
    ## Check the result columns
    assert df.shape[1] == 4
    assert df.columns[0] == 'word'
    assert df.columns[1] == 'word_5'
    assert df.columns[2] == 'word_6'
    assert df.columns[3] == 'word_7'

## For trainScore class

def test_train_iForest():
    ## Load sample data
    df_train = ts.load_data(os.path.join(ts.intermediate_path, ts.intermediate_train_file))
    ## Extract necessary column
    df_train = dp.excludeColumns(df_train)
    ## Try to generate isolation forest
    ts.train_iForest(X=df_train)

    ## Generated isolationForest algorithm
    assert type(ts.clf) == sklearn.ensemble._iforest.IsolationForest