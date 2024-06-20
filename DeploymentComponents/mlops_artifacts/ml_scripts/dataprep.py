#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
# Retrieve libraries and functions from utils
from utils import *

# Retrieve arguments
parser = argparse.ArgumentParser()
## Input
parser.add_argument('--input_data', type=str, dest='input_data', help='data folder mounting point')
parser.add_argument('--include_columns', dest='include_columns')
parser.add_argument('--exclude_columns', dest='exclude_columns')
parser.add_argument('--data_generation', dest='data_generation')
## Output to 'ml-pipeline-intermediate' container
parser.add_argument('--intermediate_path', dest='intermediate_path', required=True)
parser.add_argument('--intermediate_train_file', dest='intermediate_train_file')
parser.add_argument('--intermediate_score_file', dest='intermediate_score_file')
parser.add_argument('--intermediate_score_original_file', dest='intermediate_score_original_file')
## Process flag
parser.add_argument('--train_or_inference', dest='train_or_inference')
## Logging
parser.add_argument('--log_config', dest='log_config')
args = parser.parse_args()

print('Argment check:')
### Data path in loading
print(f' input_data: {args.input_data}')
print(f' include_columns: {args.include_columns}')
print(f' exclude_columns: {args.exclude_columns}')
print(f' data_generation: {args.data_generation}')
### Data path for storing the results of this process
print(f' intermediate_path: {args.intermediate_path}')
### Output file name of this script, which will be consumed in next process
print(f' intermediate_train_file: {args.intermediate_train_file}')
### Output file name of this script, which will be consumed in next process
print(f' intermediate_score_file: {args.intermediate_score_file}')
print(f' intermediate_score_original_file: {args.intermediate_score_original_file}')

### Flag of train or infer process
print(f' train_or_inference: {args.train_or_inference}')
### Logging config
print(f" log_config: {args.log_config}")

dp = DataPrep(
            ## Logging
            log_config = args.log_config,
            ## Input
            input_data=args.input_data,
            include_columns=args.include_columns,
            exclude_columns=args.exclude_columns,
            ## Output
            output_path=args.intermediate_path,
            intermediate_train_file=args.intermediate_train_file,
            intermediate_score_file=args.intermediate_score_file,
            intermediate_score_original_file=args.intermediate_score_original_file,
            )

dp.info('Start Process in dataprep')

## Import data
df_whole = dp.extract_dataset(path_input=args.input_data, 
                            data_generation=args.data_generation)

## standardize some column

## Select the processed column

# DataDrift
## MCC = 0.71, then we need to re-train.

# if MCC > 0.4, train_flag = True, else no need to re-train
## log metric for ML for DataDrift
##   - model
##   - accuracy, etc..

# Populate train dataset
## Extract numeric columns
df_train = df_whole.copy()
df_num_train = dp.commonDataprep(df_train,
                train_proc=True)

## Populate score dataset
df_score = df_whole.copy()
df_num_score = dp.commonDataprep(df_score,
                train_proc=False)

## Save the processed dataframe for train and to_csv
dp.save_data(output_path=dp.output_path, 
            file_path=dp.intermediate_train_file, 
            df=df_num_train, 
            day_subfolder=False)

dp.save_data(output_path=dp.output_path, 
            file_path=dp.intermediate_score_file, 
            df=df_num_score,
            day_subfolder=False)

dp.save_data(output_path=dp.output_path,
            file_path=dp.intermediate_score_original_file,
            df=df_score,
            day_subfolder=False)

dp.info('End of process in dataprep')


