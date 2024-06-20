#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys
from azureml.pipeline.core import PublishedPipeline

FILE_PATH = os.path.dirname(os.path.abspath(__file__))

def add_path(path_to_add: 'str') -> None:
    path = os.path.abspath(FILE_PATH + path_to_add)
    sys.path.append(path)
    print(f'Added path:{path}')

from utils import *

## Import constants for tabular data
from constants_for_tabular_data import *
from constants_in_common import *

## Import utilities
from azureml_configuration import *

class provision_pipeline(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: str,
        ## Service Principal
        sp_id: str,
        sp_secret: str
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        ## Service Principal for authentication
        self.sp_id = sp_id
        self.sp_secret = sp_secret
        ## logging
        self.log_config = log_config
        ## class for Azure resource configuration
        self.azuremlConfig = None
        ## dataset
        self.datastore_data_processed = None
        self.datastore_ml_processed = None
        self.datastore_ml_intermediate = None
        ## configuration
        self.include_columns_str = None
        self.exclude_columns_str = None
        self.model_config = None
        ## Input
        self.path_data_processed = None
        ## flag for train or infere
        self.train_or_inference = None
        ## Output
        self.step1_output_data = None
        self.step3_output_data = None
        ## model interim data
        self.model_tmp_data = None
        ## pipeline steps
        self.pipeline_steps = [None, None, None]
        ## AML pipeline
        self.pipeline = None
        ## Draft pipeline
        self.draft_pipeline = None
        ## published pipeline
        self.published_pipeline = None
        self.experiment_name = AML_CONFIG['EXPERIMENT_NAME']


    def retrieveAMLWorkspace(self) -> None:
        '''
        Retrive AML Workspace
        '''
        try:
            self.azuremlConfig = AzureMLConfiguration(workspace=AML_CONFIG['WORKSPACE_NAME']
                                        ,subscription_id=SUBSCRIPTION_ID
                                        ,resource_group=RESOURCE_GROUP
                                        ,tenant_id=TENANT_ID
                                        ,sp_id=self.sp_id
                                        ,sp_secret=self.sp_secret
                                        )

            # configure Azure ML workspace with managed identity
            if self.sp_id is None:
                self.azuremlConfig.configWorkspace()
            # Same with service principal
            else:
                self.azuremlConfig.configWorkspaceSP()
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def configAMLResource(self) -> None:
        '''
        Configure AML resources.
        Can execute after `retrieveAMLWorkspace` method
        '''
        try:
            # configure the azure ML compute
            self.azuremlConfig.configCompute(cpu_compute_target=AML_CONFIG['COMPUTER_TARGET_NAME'])

            # configure Environment in Azure ML
            self.azuremlConfig.configEnvironment(environment_name=AML_CONFIG['ENVIRONMENT']['NAME'],
                                            file_path=AML_CONFIG['ENVIRONMENT']['FILE_PATH'])

            # configure experiment in Azure ML
            self.azuremlConfig.configExperiment(experiment_name = AML_CONFIG['EXPERIMENT_NAME'])

            # Prepare dataset to be used in pipeline
            self.datastore_data_processed = self.azuremlConfig.getDatastore(datastore_name=DATASTORE['DATA_PROCESSED'])
            self.datastore_ml_processed = self.azuremlConfig.getDatastore(datastore_name=DATASTORE['ML_PROCESSED'])
            self.datastore_ml_intermediate = self.azuremlConfig.getDatastore(datastore_name=DATASTORE['ML_INTERMEDIATE'])
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def setVariables(self) -> None:
        '''
        Set variables
        '''
        try:
            # include/exclude columns to string to pass them to AML pipeline
            self.include_columns_str = json.dumps(USED_COL['INCLUDE'])
            self.exclude_columns_str = json.dumps(USED_COL['EXCLUDE'])
            self.model_config = json.dumps(MODEL_CONFIG)

            # Configuration of Pipeline environment
            self.azuremlConfig.configPipeline_Basic()

            # Configuration of input
            self.path_data_processed = self.azuremlConfig.configPipelineInputData(datastore=self.datastore_data_processed
                                                                    ,path_on_datastore=DATAIO['DATAPREP']['IN']['DIR_TO_CONSUME'])

            ## flag for train or infer
            self.train_or_inference = self.azuremlConfig.configPipelineInputValue(pipeline_name=PIPELINE_CONFIG['FROM_SYNAPSE']['PARAMETER']
                                                                ,default_value=PIPELINE_CONFIG['FROM_SYNAPSE']['VALUE'])

            # Configuration of output
            self.step1_output_data = self.azuremlConfig.configPipelineOutputData(datastore=self.datastore_ml_intermediate
                                                                    ,store_name=DATAIO['DATAPREP']['STORE']['NAME']
                                                                    ,stored_path=DATAIO['DATAPREP']['STORE']['PATH']
                                                                    ,overwrite_flg=False)

            self.step3_output_data = self.azuremlConfig.configPipelineOutputData(datastore=self.datastore_ml_processed
                                                                    ,store_name=DATAIO['MODEL_MANAGEMENT']['STORE']['NAME']
                                                                    ,stored_path=DATAIO['MODEL_MANAGEMENT']['STORE']['PATH']
                                                                    ,overwrite_flg=True)

            self.model_tmp_data = self.azuremlConfig.configPipelineOutputData(datastore=self.datastore_ml_intermediate
                                                                    ,store_name=DATAIO['DATAPREP']['STORE']['NAME']
                                                                    ,stored_path=DATAIO['DATAPREP']['STORE']['PATH']
                                                                    ,overwrite_flg=True)
            self.info('Successfully defined variables for variables.')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def definePipeline(self) -> None:
        '''
        Define AML pipeline
        '''
        try:
            # setup the script steps
            self.pipeline_steps[0] = PythonScriptStep(name='Step 1: DataPrep',
                                        script_name = SCRIPTS['001'],
                                        arguments = [## Input from 'data-processed' container
                                                    '--input_data', self.path_data_processed,
                                                    '--include_columns', self.include_columns_str,
                                                    '--exclude_columns', self.exclude_columns_str,
                                                    '--data_generation', DATAIO['DATAPREP']['IN']['DATA_GENERATION'],
                                                    ## Output to 'ml-pipeline-intermediate' container
                                                    '--intermediate_path', self.step1_output_data,
                                                    '--intermediate_train_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_TRAIN'],
                                                    '--intermediate_score_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_SCORE'],
                                                    '--intermediate_score_original_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_SCORE_ORIGINAL'],
                                                    ## Process flag from Synapse
                                                    '--train_or_inference', self.train_or_inference,
                                                    ## Logging
                                                    '--log_config', self.log_config,
                                                    ], 
                                        inputs = [self.path_data_processed],
                                        source_directory = SCRIPTS['SOURCE_DIR'],
                                        compute_target = self.azuremlConfig.compute_target,
                                        runconfig = self.azuremlConfig.aml_run_config,
                                        allow_reuse = True)

            self.pipeline_steps[1] = PythonScriptStep(name='Step 2: Train anomaly detection algorithm',
                                        script_name = SCRIPTS['002'],
                                        arguments = [## Input from 'ml-pipeline-intermediate' container
                                                    '--intermediate_path', self.step1_output_data.as_input(), 
                                                    '--intermediate_train_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_TRAIN'],
                                                    ## Output to 'ml-pipeline-intermediate' container
                                                    '--intermediate_model_path', self.model_tmp_data,
                                                    ## Process flag from Synapse
                                                    '--train_or_inference', self.train_or_inference,
                                                    ## Modelling
                                                    '--model_config', self.model_config,
                                                    ## Logging
                                                    '--log_config', self.log_config,
                                                    ],
                                        source_directory = SCRIPTS['SOURCE_DIR'],
                                        compute_target = self.azuremlConfig.compute_target,
                                        runconfig = self.azuremlConfig.aml_run_config,
                                        allow_reuse = True)

            self.pipeline_steps[2] = PythonScriptStep(name='Step 3: Score and ML model management',
                                        script_name=SCRIPTS['003'],
                                        arguments = [## Input
                                                    '--intermediate_model_path', self.model_tmp_data.as_input(),
                                                    '--intermediate_score_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_SCORE'],
                                                    '--intermediate_score_original_file', DATAIO['DATAPREP']['OUT']['FILE_TO_STORE_SCORE_ORIGINAL'],
                                                    ## Output to 'ml-processed' container
                                                    '--output_path', self.step3_output_data,
                                                    '--step03_output_file', DATAIO['MODEL_MANAGEMENT']['OUT']['FILE_TO_STORE'],
                                                    ## Process flag
                                                    '--train_or_inference', self.train_or_inference,
                                                    ## Modelling
                                                    '--model_config', self.model_config,
                                                    ## Logging
                                                    '--log_config', self.log_config,
                                                    ],
                                        source_directory = SCRIPTS['SOURCE_DIR'],
                                        compute_target = self.azuremlConfig.compute_target,
                                        runconfig = self.azuremlConfig.aml_run_config,
                                        allow_reuse = True)

            # build and validate the pipeline
            self.pipeline = self.azuremlConfig.buildPipeline(script_steps = self.pipeline_steps)
            self.info(f'Successfully defined pipeline: {self.pipeline}')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def draftAMLPipeline(self) -> None:
        try:
            self.draft_pipeline = self.azuremlConfig.draftPipeline(
                                                        name = PIPELINE_CONFIG['DRAFT']['NAME'],
                                                        description = PIPELINE_CONFIG['DRAFT']['DESCRIPTION'],
                                                        experiment_name = PIPELINE_CONFIG['DRAFT']['EXPERIMENT_NAME'],
                                                        pipeline = self.pipeline,
                                                        tags = PIPELINE_CONFIG['DRAFT']['TAGS'],
                                                        properties = PIPELINE_CONFIG['DRAFT']['PROPERTIES']
                                                        )
            self.info(f'Successfully pipeline was drafted: {self.draft_pipeline}')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def runDraftPipeline(self) -> None:
        '''
        Try to run Draft Pipeline (before publishing it)
        '''
        try:
            self.draft_pipeline.submit_run()
            self.info(f'Start running ')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def publishAMLPipelineFromDraft(self) -> None:
        try:
            ## Publish pipeline from draft
            self.published_pipeline = self.azuremlConfig.publishPipelineFromDraft(
                                                        pipeline_id=self.draft_pipeline.id)
            self.info(f'Successfully published the pipeline:{self.published_pipeline}')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def publishAMLPipeline(self) -> None:
        '''
        Publish AML pipeline
        '''
        try:
            self.published_pipeline = self.azuremlConfig.publishPipeline(
                                                        pipeline = self.pipeline, 
                                                        name = PIPELINE_CONFIG['PUBLISHED']['NAME'],
                                                        description = PIPELINE_CONFIG['PUBLISHED']['DESCRIPTION'],
                                                        version = PIPELINE_CONFIG['PUBLISHED']['VERSION'])
        except Exception as error:
            self.error(f'Error in {error}')
            raise


class run_aml_pipeline(provision_pipeline):
    def __init__(self,
        ## Logging
        log_config: str,
        ## Service Principal
        sp_id: str,
        sp_secret: str,
        pipeline_id: str
    ):
        ## Inheritance
        super().__init__(log_config, sp_id, sp_secret)
        ## Pipeline ID as argument value
        self.pipeline_id = pipeline_id
        ## AML workspace
        self.azuremlConfig = None
        self.workspace = None
        self.experiment_name = AML_CONFIG['EXPERIMENT_NAME']

    def runPipeline(self) -> None:
        try:
            ## Set AML Workspace
            self.workspace = self.azuremlConfig.ws
            ## Logging for running
            self.info(f'Run under AML workspace:{self.workspace}')
            self.info(f'Expeirment name: {self.experiment_name}')
            self.info(f'Pieline_id: {self.pipeline_id}')
            ## Retrieve specific AML pipeline
            pipeline = PublishedPipeline.get(workspace=self.workspace, 
                                            id=self.pipeline_id)
            ## Run the AML pipeline
            pipeline.submit(workspace=self.workspace,
                            experiment_name=self.experiment_name)
        except Exception as error:
            self.error(f'Error in {error}')
            raise

