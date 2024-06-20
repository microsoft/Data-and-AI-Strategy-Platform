#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys
import argparse
import numpy as np
import pandas as pd
import joblib
import glob
import pathlib
import json
from datetime import datetime

from scipy.stats import binom_test
import sklearn
from sklearn.ensemble import IsolationForest
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt

from azureml.core.model import Model

## Adding `loghandler.py` script by defining absolute path
currentDir = os.path.dirname(os.getcwd())
print(f'Current working directory: {currentDir}')
sys.path.append(currentDir)
sys.path.append('./DeploymentComponents/mlops_artifacts/config_scripts')

from loghandler import * ## Added for pytest

class Utils(logHandler):
    def __init__(self,
                ## Logging
                log_config: str,
                ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)

    def load_data(self,
                inputData :str,
                ) -> pd.DataFrame():
        '''
        Load csv file and return pandas Dataframe    
        '''
        try:
            df_input = pd.read_csv(inputData, header=0)
            print(f'Loaded dataframe: {inputData}')
            print(f'Size of the loaded dataframe: {df_input.shape}')
            print(f'Head of the dataframe: \
                    {df_input.head()}')
            return df_input
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def extract_dataset(self,
                        path_input: str,
                        data_generation: int
                        ) -> pd.DataFrame():
        '''
        Extract csv files, aggragate them and convert them into one DataFrame
        Sort key is the name of the directory(yyyy-mm-dd format)
        '''
        try:
            ## Get directory candidates
            files = os.listdir(path_input)
            vat_tax_files = [f for f in files if os.path.isdir(os.path.join(path_input, f))]
            self.info(f'Target directories for ML processing: {vat_tax_files}')

            ## Sort directory by date
            ### Convert directory name into datetime format
            date_dict = {d: datetime.strptime(d, '%Y-%m-%d') for d in vat_tax_files}
            ### Sort by date
            date_sorted = sorted(date_dict.items(), key=lambda x:x[1], reverse=True)
            ### Select recent files by the number of generation
            extract_generation = min(len(vat_tax_files), int(data_generation))
            date_selected = dict(date_sorted[:extract_generation]).keys()
            self.info(f'Selected directories: {date_selected}')

            ## Aggregate target dataset(s)
            df_whole = pd.DataFrame([])
            for day_consumed in date_selected:
                whole_path = os.path.join(path_input, day_consumed)
                df_tmp = self.load_df(whole_path)
                df_whole = pd.concat([df_whole, df_tmp], axis=0)
            self.info(f'Extracted dataset shape: {df_whole.shape}')
            return df_whole
        except Exception as error:
            self.error(f'Failed to extract dataset: {error}')
            raise        

    def load_df(self,
            path_dir: str) -> pd.DataFrame():
        '''
        Load csv file by specifying the directory
            ex.) A directory has several csv files like aaa.csv, bbb.csv
             Then, this function retrieve all csv file, concat them, and convert them into pandas DataFrame.
        '''
        ## initialize DataFrame
        df_total = pd.DataFrame([])
        try:
            ## Get csv file paths
            p_temp = pathlib.Path(path_dir)
            csv_list = list(p_temp.glob('./*.csv'))
            self.info(f'Loaded paths of csv files: {csv_list}')
            ## Concat the csv files
            for csv_file in csv_list:
                df_tmp = pd.read_csv(csv_file, header=0)
                df_total = pd.concat([df_total, df_tmp], axis=0)
        except Exception as error:
            self.error(f'Error in load_df process:{error}')
            raise
        finally:
            return df_total

    def save_data(self,
                output_path: str,
                file_path: str,
                df: pd.DataFrame(),
                day_subfolder: bool):
        '''
        Save pandas DataFrame with csv format
        '''
        try:
            if day_subfolder:
                now = datetime.now()
                date_folder = f"{now:%Y}-{now.month}-{now.day}/"
                output_path = os.path.join(output_path, date_folder)
            self.info(f'Will save here: {output_path}')
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            save_path = os.path.join(output_path, file_path)
            is_file = os.path.isfile(save_path)
            if is_file:
                os.remove(save_path)
                self.info(f'Removed file: {save_path}')
            df.to_csv(save_path, index=False, mode='w')
            self.info(f'Saved file: {save_path}')
        except Exception as error:
            self.error(f'Error in saving data: {error}')
            raise

class DataPrep(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: str,
        ## Input
        input_data: str,
        include_columns: list,
        exclude_columns: list,
        ## Output
        output_path: str,
        intermediate_train_file: str,
        intermediate_score_file: str,
        intermediate_score_original_file: str,
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        ## Input: path + file_name
        self.input_data = input_data
        ## Specify columns to be included in datasets
        self.include_cols = include_columns
        self.include_col_list = self.convert_to_list(self.include_cols)
        ## Specify columns to be excluded
        self.exclude_cols = exclude_columns
        self.exclude_col_list = self.convert_to_list(self.exclude_cols)
        ## Output: path
        self.output_path = output_path
        ## Output: file_name, and taken over in the next process
        self.intermediate_train_file = intermediate_train_file ## for train
        self.intermediate_score_file = intermediate_score_file ## for score
        self.intermediate_score_original_file = intermediate_score_original_file
        ## For generating dummy variables
        self.dummy_columns = None

    def convert_to_list(self,
                        columns: str) -> list:
        try:
            col_dict = json.loads(columns)
            return list(col_dict.values())
        except Exception as error:
            self.error(f'Fail to convert to list: {error}')
            raise

    def extract_numeric_columns(self, 
                            df: pd.DataFrame()
                            ) -> pd.DataFrame():
        try:
            ## Convert & select numeric columns
            df_int = df.convert_dtypes().select_dtypes(include='int')
            df_float = df.convert_dtypes().select_dtypes(include='float')
            ## Concat int & float columns
            return pd.concat([df_int, df_float], axis=1)
        except Exception as error:
            self.error(f'Error in extract_numeric_columns:{error}')
            raise

    def getDummyVariables(self,
                        df: pd.DataFrame()) -> pd.DataFrame():
        ## Set empty DataFrame
        try:
            print(f'Existing columns: {df.columns}')
            print(f'Expand with these columns: {self.include_col_list}')
            ## Exclude unnecessary columns
            df = self.excludeColumns(df=df)
            for col in list(df.columns):
                if col in self.include_col_list:
                    print(f'Columns to expand: {col}')
                    df = pd.get_dummies(df, columns=[col])
            self.info(f'Dummy variables: {df.columns}')
            return df
        except Exception as error:
            self.error(f'Error in getDummyVariables in :{error}')
            raise

    def excludeColumns(self,
                    df: pd.DataFrame(),
                    ) -> pd.DataFrame():
        ## Try to drop exclude columns if any
        try:
            ## Check each column should be removed or not
            for col in list(df.columns):
                if col in self.exclude_col_list:
                    df = df.drop(labels=col, axis=1)
        except:
            self.info(f'No columns in {self.exclude_col_list}')
        finally:
            return df

    def commonDataprep(self,
                    df: pd.DataFrame(),
                    train_proc: bool) -> pd.DataFrame():
        try:
            ## extract numeric columns
            df_num = self.extract_numeric_columns(df)     
            ## Exclude columns, if any
            df_num = self.excludeColumns(df=df_num)
            print(f'Numerical columns: {df_num.columns}')
            
            ## Get dummy variables for include_columns
            df_dummies = self.getDummyVariables(df=df)
            ## Store dummy collumns here
            if train_proc:
                self.dummy_columns = df_dummies.columns
                print(f'dummy columns for train: {self.dummy_columns}')
            ## Select common columns:
            ### For train data, all columns will be selected
            ### For scoring data, only common columns should be selected for scoring
            df_dummies = df_dummies[self.dummy_columns]
            return pd.concat([df_num, df_dummies], axis=1)
        except Exception as error:
            self.error(f'Error in commonDataprep: {error}')
            raise

class trainScore(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: str,
        ## Input
        intermediate_path: str,
        intermediate_train_file: str,
        intermediate_model_path: str,
        ## Modelling
        model_config: str,
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)

        ## Input: path of input file (not incl. file name)
        self.intermediate_path = intermediate_path
        self.intermediate_train_file = intermediate_train_file # for train
        self.intermediate_model_path = intermediate_model_path # path to save generated model
        ## Modelling
        self.model_config = json.loads(model_config)
        self.model_name = self.model_config['NAME']
        self.model_path = self.model_config['PATH']
        self.model_file_name = self.model_config['FILE_NAME']
        self.model_contamination = self.model_config['CONTAMINATION']
        self.model_version = self.model_config['VERSION']
        self.DATA_DRIFT_RESULT_OK = self.model_config['DATA_DRIFT_RESULT_OK']
        self.clf = None
        ## Load AML Workspace, if exists
        self.ws = self.run.experiment.workspace if self.run is not None else None

    def train_iForest(self,
            X: pd.DataFrame) -> IsolationForest:
        try:
            self.info(f'Variable to be used{X.columns}')
            if self.model_contamination != 'auto':
                self.model_contamination = float(self.model_contamination)
            self.clf = IsolationForest(random_state=0,
                                contamination=self.model_contamination).fit(X)
        except Exception as error:
            self.error(f'Training process error: {error}')
            raise

    def save_model(self) -> None:
        '''
        Save model with sklearn
        '''
        try:
            if self.clf != None:
                ## Save in the local directory
                model_path = os.path.join(self.intermediate_model_path, self.model_file_name)
                joblib.dump(self.clf, model_path)
                print(f'Saved model: {self.clf} in {model_path}')
            else:
                self.info('No model to be saved')
        except Exception as error:
            self.error(f'Error in saving model {error}')
            raise


    def score(self,
            data_to_be_scored: pd.DataFrame(),
            df_original: pd.DataFrame(),
            ):
        '''
        - Feature:
            predict/score with anomaly detection model
        - Output:
            predictive values with retrieved model.
            `predict` column shows anomaly(-1) or noaml(+1)        
            `score` column shows anomalous degree. The less, the more anomalous
        '''
        try:
            if self.clf != None:
                ## Predict or score with model
                y_score = self.clf.score_samples(data_to_be_scored)
                y_pred = self.clf.predict(data_to_be_scored)
                
                ## Count anomalous records
                anomalous_records = sum(1 for x in y_pred if x == -1)
                print(anomalous_records, len(y_pred), anomalous_records / len(y_pred))
                self.info(f'Anomalous ratio: {anomalous_records / (len(y_pred) + 1e-10)}')
                
                ## Append score and predict values
                df_original['score'] = y_score
                df_original['predict'] = y_pred

                ## save plot
                self.save_plot(y_score)
                return df_original
            else:
                self.error('No model to be used for scoring.')
        except Exception as error:
            self.error(f'Error in {error}')
            raise

class modelManagement(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: str,
        ## Input
        intermediate_score_file: str,
        intermediate_score_original_file: str,
        ## Output
        output_path: str,
        step03_output_file: str,
        ## Modeling
        model_config: str,
        model_path: str,
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        ## Input
        self.intermediate_score_file = intermediate_score_file
        self.intermediate_score_original_file = intermediate_score_original_file
        ## Output
        self.output_path = output_path
        self.step03_output_file = step03_output_file
        ## convert to dict format
        self.model_config = json.loads(model_config)
        ## name of ML model for anomaly detection
        self.model_name = self.model_config['NAME']
        ## file name of ML model
        self.model_file_name = self.model_config['FILE_NAME']
        ## Tags to be stored
        self.model_tags = self.model_config['TAGS']
        ## Version of ML model
        self.model_version = self.model_config['VERSION']
        ## Contamination: Parameter of isolationForest
        self.model_contamination = self.model_config['CONTAMINATION']
        ## path of ML model in ADLS
        self.model_path = model_path
        ## threshold to be used for newly generated ML model
        self.p_value = self.model_config['P_VALUE']
        ## Data Drift result value with OK
        self.DATA_DRIFT_RESULT_OK = self.model_config['DATA_DRIFT_RESULT_OK']
        ## Load Azure ML Workspace, if exists
        self.ws = self.run.experiment.workspace if self.run is not None else None
        ## ML model parameters
        self.model_v1 = {
            'clf': None,
            'df_inferred': None,
            'silhouette_score': None,
            'p_value': None
        }
        self.model_v2 = {
            'clf': None,
            'df_inferred': None,
            'silhouette_score': None,
            'p_value': None,
            'validation': False
        }
        ## output data
        self.df_output = None

    def load_model(self) -> None:
        '''
        Load stored model
        '''
        try:
            model_path = os.path.join(self.model_path, self.model_file_name)
            return joblib.load(model_path)
        except Exception as error:
            self.error(f'Error in saving model {error}')
            raise

    def download_model(self) -> None:
        '''
        - Feature:
            Call registered anomaly detection model
        - Output:
            existing anomaly detection model
        '''
        try:
            print(os.getcwd())
            os.makedirs('./load_model')
            ## Load anomaly detection model
            if self.model_version == '':
                model = Model(
                    workspace=self.ws
                    ,name=self.model_name
                    )
            else:
                self.model_version = int(self.model_version)
                model = Model(
                    workspace=self.ws
                    ,name=self.model_name
                    ,version=self.model_version # With specific model version
                    )
            model.download(target_dir='./load_model', exist_ok=True)
            print("Use Model {} with version {}".format(model.name, model.version))
            return joblib.load(os.path.join(self.model_path,self.model_file_name))
        except Exception as error:
            self.error(f'Error in {error}')
            raise

    def load_models(self) -> None:
        '''
        Load model with different version
        '''
        ## Load populated model in `train_and_score` process
        try:
            self.model_v1['clf'] = self.load_model()
            self.info('Loaded original model as model_v1')
        except:
            self.info("Original model doesn't exist")
        try:
            self.model_v2['clf'] = self.load_model()
            self.info('Loaded new model as model_v2')
        except:
            self.info("Populated model doesn't exist")

    def get_inferred_result(self,
                            clf: IsolationForest,
                            df_score: pd.DataFrame) -> pd.DataFrame:
        try:
            score_result = clf.score_samples(df_score)
            predict_result = clf.predict(df_score)
            df_score = pd.DataFrame(score_result, columns=['score'])
            df_predict = pd.DataFrame(predict_result, columns=['predict'])
            return pd.concat([df_score, df_predict], axis=1)
        except:
            self.error("Cannot populate inferred dataset.")
            raise

    def get_silhouette_score(self,
                            df_inferred: pd.DataFrame) -> float:
        '''
        Calculate Silohette score
        '''
        try:
            return silhouette_score(X=np.array(df_inferred['score']).reshape(-1, 1),
                                    labels=df_inferred['predict'])
        except:
            self.error("Cannot get silhouette score")
            raise

    def get_p_value(self,
                    df_inferred: pd.DataFrame) -> float:
        '''
        Calculate p-value with binomial test
        '''
        try:
            ## Count anomalous records
            N_anomaly = sum([1 for x in df_inferred['predict'] if x == -1])
            N_total = len(df_inferred)
            self.info(f'Anomaly records: {N_anomaly}, total records: {N_total}')

            ## Calculate p-value of Binomial test
            p_value_null_hypo = binom_test(x=N_anomaly, 
                                        n=N_total, 
                                        p=self.model_contamination, 
                                        alternative='two-sided')
            self.info(f'p-value of binomial test: {p_value_null_hypo}')
            return p_value_null_hypo
        except:
            self.error("Cannot calculate p-value")
            raise

    def save_plot(self, model:dict) -> None:
        ## copy inferred results
        df_inferred = model['df_inferred'].copy()
        ## silhouette_score
        sil_score = model['silhouette_score']
        model_name = model['name']
        ## Extract values
        normal_values = df_inferred[df_inferred.predict == 1]['score']
        anomaly_values = df_inferred[df_inferred.predict == -1]['score']

        ## Depict the results as histgram
        plt.figure(figsize=(15, 10))
        plt.hist(normal_values, bins=30, alpha = 0.5, label='normal')
        plt.hist(anomaly_values, bins=30, alpha = 0.5, label='anomalous')
        plt.xlabel('score(The lower, the more abnormal.)')
        plt.ylabel('frequency')
        plt.title(f' {model_name} \n \
                    iForest under contamination={self.model_contamination}, \n \
                    Silhouette_score:{sil_score}')
        plt.legend(loc='upper left')
        plt.savefig(f'Plot_for_{model_name}.png')
        ## Save the plot
        self.run.log_image(f'Plot for {model_name}', plot=plt)

    def validate_model_drift(self) -> None:
        '''
        Confirm if the populated model should be stored        
        '''
        try:
            ## Prepare data to be scored
            score_path = os.path.join(self.model_path, self.intermediate_score_file)
            df_score=pd.read_csv(score_path)
            self.info(f'Loaded df_score: {len(df_score)} records')
            ## Prepare models
            self.load_models()
            ## Existing ML model
            if self.model_v1['clf'] is not None:
                ## Get inferred dataset
                self.model_v1['df_inferred'] = self.get_inferred_result(df_score=df_score, clf=self.model_v1['clf'])
                ## Calculate Silhouette score
                self.model_v1['silhouette_score'] = self.get_silhouette_score(df_inferred=self.model_v1['df_inferred'])
                ## Calculate p-value of binomial test
                self.model_v1['p_value'] = self.get_p_value(df_inferred=self.model_v1['df_inferred'])
                self.model_v1['name'] = 'Existing_model'
                self.save_plot(model=self.model_v1)
                self.info(f'Saved model_v1: {self.model_v1}')
            ## Newly populated ML model
            if self.model_v2['clf'] is not None:
                self.model_v2['df_inferred'] = self.get_inferred_result(df_score=df_score, clf=self.model_v2['clf'])
                self.model_v2['silhouette_score'] = self.get_silhouette_score(df_inferred=self.model_v2['df_inferred'])
                self.model_v2['p_value'] = self.get_p_value(df_inferred=self.model_v2['df_inferred'])
                self.model_v2['name'] = 'Newly_populated_model'
                self.save_plot(model=self.model_v2)
                self.info(f'Saved model_v2: {self.model_v2}')

            ## Check if the populated model exists
            if self.model_v2['clf'] is not None:
                ## Check p-value > threshold
                if self.model_v2['p_value'] >= self.p_value:
                    ## Populated score is more separated than previous model
                    if self.model_v2['silhouette_score'] >= self.model_v1['silhouette_score']:
                        self.model_v2['validation'] = True
        except Exception as e:
            self.error('Unable to process: {e}')
            raise

    def get_df_output(self):
        '''
        Select model and scoring accordingly
        '''
        try:
            ## Load original data
            self.df_output = self.load_data(os.path.join(self.model_path, self.intermediate_score_original_file))
            ## apply generated model
            if self.model_v2['validation']:
                self.df_output['score'] = self.model_v2['df_inferred']['score']
                self.df_output['predict'] = self.model_v2['df_inferred']['predict']
                self.info('Saved inferred data with newly generated ML model')
            ## Use existing model for inference
            else:
                self.df_output['score'] = self.model_v1['df_inferred']['score']
                self.df_output['predict'] = self.model_v1['df_inferred']['predict']
                self.info('Saved inferred data with existing ML model')
        except Exception as e:
            self.error(f'Error in populating dataset: {e}')
            raise

    def register_model(self) -> None:
        '''
        Register model
        '''
        try:
            if self.model_v2['clf'] != None and self.model_v2['validation']:
                tags = self.model_tags
                tags['silhouette_score'] = self.model_v2['silhouette_score']
                tags['p_value'] = self.model_v2['p_value']
                ## Save in the local directory
                joblib.dump(self.model_v2['clf'], self.model_file_name)

                ## Register ML model in AML Workspace
                model_location = os.path.join(self.model_path, self.model_file_name)
                print(f'model location: {model_location}')
                model = Model.register(self.ws, 
                        model_name=self.model_name, 
                        model_path=model_location,
                        model_framework=Model.Framework.SCIKITLEARN,
                        model_framework_version=sklearn.__version__, 
                        tags=tags
                        )
                self.info(f'Completed registering the model with Name: {model.name}, Version: {model.version}')
            else:
                self.info(f'Not registerd model.')
        except Exception as error:
            self.error(f'Error in saving model {error}')
            raise

