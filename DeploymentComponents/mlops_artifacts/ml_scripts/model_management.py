#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
# Retrieve libraries and functions from utils
from utils import *

parser = argparse.ArgumentParser()
## Input
parser.add_argument('--intermediate_model_path', dest='intermediate_model_path')
parser.add_argument('--intermediate_score_file', dest='intermediate_score_file')
parser.add_argument('--intermediate_score_original_file', dest='intermediate_score_original_file')
## Output
parser.add_argument('--output_path', dest='output_path')
parser.add_argument('--step03_output_file', dest='step03_output_file')
## Process flag from Synapse
parser.add_argument('--train_or_inference', dest='train_or_inference')
## Modelling
parser.add_argument('--model_config', dest='model_config')
## Logging
parser.add_argument('--log_config', dest='log_config')
args = parser.parse_args()

print('Argment check:')
## Input
print(f' intermediate_model_path: {args.intermediate_model_path}')
print(f' intermediate_score_file: {args.intermediate_score_file}')
print(f' intermediate_score_original_file: {args.intermediate_score_original_file}')
## Output
print(f' output_path: {args.output_path}')
print(f' step03_output_file: {args.step03_output_file}')
## Process flag
print(f' train_or_inference: {args.train_or_inference}')
## Modelling
print(f' model_config: {args.model_config}')
### Logging config
print(f' log_config: {args.log_config}')

mM = modelManagement(## Logging
                    log_config = args.log_config,
                    ## Input
                    intermediate_score_file = args.intermediate_score_file,
                    intermediate_score_original_file = args.intermediate_score_original_file,
                    ## Output
                    output_path = args.output_path,
                    step03_output_file = args.step03_output_file,
                    ## Modelling
                    model_config = args.model_config,
                    model_path=args.intermediate_model_path,
                    )

## Load model, if trained
mM.load_model()
if args.train_or_inference == mM.DATA_DRIFT_RESULT_OK:
    mM.validate_model_drift()
    print(mM.model_v2['validation'])
    mM.register_model()

## Get output dataset for storing
mM.get_df_output()
## Save the output
mM.save_data(output_path=mM.output_path,
            file_path=mM.step03_output_file,
            df=mM.df_output,
            day_subfolder=False)
