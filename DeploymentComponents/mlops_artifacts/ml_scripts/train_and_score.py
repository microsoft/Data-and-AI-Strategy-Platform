#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
# Retrieve libraries and functions from utils
from utils import *

parser = argparse.ArgumentParser()
## Input from 'ml-pipeline-intermediate' container
parser.add_argument('--intermediate_path', type=str, dest='intermediate_path', help='data folder mounting point')
parser.add_argument('--intermediate_train_file', dest='intermediate_train_file')
## Output to 'ml-pipeline-intermediate' container
parser.add_argument('--intermediate_model_path', dest='intermediate_model_path')
## Process flag from Synapse
parser.add_argument('--train_or_inference', dest='train_or_inference')
## Modelling
parser.add_argument('--model_config', dest='model_config')
## Logging
parser.add_argument('--log_config', dest='log_config')
args = parser.parse_args()

print('Argment check:')
## Input from 'ml-pipeline-intermediate' container
print(f' intermediate_path: {args.intermediate_path}')
print(f' intermediate_train_file: {args.intermediate_train_file}')
## Output to 'ml-pipeline-intermediate' container
print(f' intermediate_model_path: {args.intermediate_model_path}')
## Process flag from Synapse
print(f' train_or_inference: {args.train_or_inference}')
### Model configuration
print(f' model_config: {args.model_config}')
### Logging config
print(f' log_config: {args.log_config}')

## Initialize
ts = trainScore(## Logging
                log_config = args.log_config,
                ## Input
                intermediate_path=args.intermediate_path,
                intermediate_train_file=args.intermediate_train_file,
                intermediate_model_path=args.intermediate_model_path,
                ## Modelling
                model_config = args.model_config,
                )

## Load data
### For training or scoring with numerical columns
df_train = ts.load_data(os.path.join(ts.intermediate_path, ts.intermediate_train_file))

## Train process, if needed:
if args.train_or_inference == ts.DATA_DRIFT_RESULT_OK:
    ts.info('Start training process in train_and_score')
    ## Train anomaly detection model
    ts.train_iForest(X=df_train)
    ## Save model in intermediate storage
    ts.save_model()
    ts.info('End training process in train_and_score')
