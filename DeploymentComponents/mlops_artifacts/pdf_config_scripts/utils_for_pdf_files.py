#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os, sys
import json
import shutil
import argparse
import numpy as np
import pandas as pd
import joblib
import matplotlib.pyplot as plt
from sklearn.ensemble import IsolationForest
from azure.ai.formrecognizer import DocumentAnalysisClient

## Adding `loghandler.py` script by defining absolute path
FILE_PATH = os.path.dirname(os.path.abspath(__file__))

currentDir = os.path.dirname(os.getcwd())
print(f'Current working directory: {currentDir}')
sys.path.append(currentDir)
sys.path.append('./DeploymentComponents/mlops_artifacts/config_scripts')

#from common.loghandler import *
from loghandler import * ## Added for pytest

class Utils(logHandler):
    def __init__(self,
            ## Logging
            log_config: str
            ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)

    def get_pdf_files(self, 
                    path_input: str) -> None:
        try:
            ## Extract only pdf files 
            pdf_files = [f for f in os.listdir(path_input) if '.pdf' in f]
            self.info(f'Picked up {len(pdf_files)} pdf files: {pdf_files}')
            return pdf_files
        except Exception as error:
            self.error(f'Cannot pick up pdf files with {error}')
            raise

    def construct_cols(self,
                    used_columns: str,
                    include_column: bool,
                    exclude_column: bool) -> list:
        '''
        Construct columns with given columns definition
        '''
        try:
            cols_dict = json.loads(used_columns) # Convert string to dict format
            cols = []
            if exclude_column:
                cols.extend(list(cols_dict['EXCLUDE'].values()))
            if include_column:
                cols.extend(list(cols_dict['INCLUDE'].values()))
            return cols
        except Exception as e:
            self.error(f'Unable to define columns')
            raise

class DataPrepForPDF(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: dict,
        ## input PDF file path
        input_path: str,
        intermediate_path: str, 
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        self.input_path = input_path
        self.intermediate_path = intermediate_path

    def store_files(self,
                    path_input: str,
                    path_output) -> None:
        try:
            os.makedirs(os.path.dirname(path_output), exist_ok=True)

            ## Get pdf files with file name
            pdf_files = self.get_pdf_files(path_input=path_input)

            for pdf_file in pdf_files:
                base_filename = os.path.basename(pdf_file)
                shutil.copyfile(os.path.join(path_input,base_filename), \
                                os.path.join(path_output, base_filename))
        except Exception as error:
            self.error(f'Failed to copy pdf files with {error}')

class AnalyzeFormRecognizer(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: dict,
        ## Input
        intermediate_path: str,
        ## used columns
        used_columns: str,
        ## Parameter for Form Recognizer
        fr_config: str,
    ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        ## Specific values to be used
        self.intermediate_path = intermediate_path
        ## Parameters for Form Recognizer
        self.fr_config = json.loads(fr_config)   # Convert to dict format
        self.model_id = self.fr_config['MODEL_ID']
        self.pages = self.fr_config['PAGES']
        self.locale = self.fr_config['LOCALE']
        self.result_list = []
        ## Convert for used columns
        self.used_columns = self.construct_cols(used_columns,
                                                include_column=True,
                                                exclude_column=True)

    def analyze_tax_form(self) -> None:
        '''
        - Analyze tax form with Form Recognizer with locally stored pdf files
        '''
        try:
            ## Configuration for Form Recognizer
            document_analysis_client = DocumentAnalysisClient(endpoint=self.form_recognizer_url,
                                                            credential=self.managedIdentityCredential)

            ## Extract pdf files from ml-intermediate container
            pdf_files = self.get_pdf_files(path_input=self.intermediate_path)

            ## Analyze with Form recognizer
            self.result_list = []
            for pdf_file in pdf_files:
                print(f'Start process for {pdf_file}')

                ## Get stored file path
                base_filename = os.path.basename(pdf_file)
                file = os.path.join(self.intermediate_path, base_filename)
                ## open the file
                with open(file, "rb") as fd:
                    doc = fd.read()

                ## Analyze with form recognizer
                poller = document_analysis_client.begin_analyze_document(model_id=self.model_id, 
                                                                        document=doc,
                                                                        pages=self.pages,
                                                                        locale=self.locale)
                result = poller.result()
                result_dict = result.to_dict()
                result_dict['file_name'] = os.path.basename(pdf_file)
                self.result_list.append(result_dict)
        except Exception as e:
            self.error(f'Error occurred at analyzing with form recognizer, {e}')
            raise

    def add_centers(self,
                    result_list: list) -> list:
        '''
        Add central coordinates for x, y
        '''
        try:
            for result_num in range(len(result_list)):
                for table_num in range(len(result_list[result_num]['tables'])):
                    for content in result_list[result_num]['tables'][table_num]['cells']:
                        ## Calculate the central coordinates for each x, y
                        content['x_mean'] = np.mean([coord['x'] for coord in content['bounding_regions'][0]['polygon']])
                        content['y_mean'] = np.mean([coord['y'] for coord in content['bounding_regions'][0]['polygon']])
            return result_list
        except Exception as e:
            self.error(f'Uable add center coordinate: {e}')
            raise

    def generate_df_table(self,
                        result_list: list,
                        result_num: int) -> pd.DataFrame:
        try:
            global_list = []
            for table_num in range(len(result_list[result_num]['tables'])):
                for content in result_list[result_num]['tables'][table_num]['cells']:
                    global_list.append([table_num,content['kind'], content['content'], content['x_mean'], content['y_mean'] ])
            return pd.DataFrame(global_list, columns=['table_num','kind', 'content', 'x_mean', 'y_mean'])
        except Exception as e:
            self.error(f'Unable to generate df_table: {e}')
            raise

    def generate_df_kv(self,
                    result_list: list,
                    result_num: int) -> pd.DataFrame:
        '''
        Generate DataFrame with key-value pair
        '''
        try:
            global_list = []
            for kv_num in range(len(result_list[result_num]['key_value_pairs'])):
                try:
                    kv = result_list[result_num]['key_value_pairs'][kv_num]
                    global_list.append([kv['key']['content'], kv['value']['content']])
                except:
                    pass
            return pd.DataFrame(global_list, columns=['key', 'value'])
        except Exception as e:
            self.error(f'Unable to generate df for key-value content: {e}')
            raise

    def extract_feature(self,
                        df: pd.DataFrame,
                        key_phrase: str, 
                        match_pattern: str,
                        extract_target: str) -> list:
        '''
        Extract features such as coordinates, characters, etc..
        '''
        try:
            feature_list = []
            for index, data in df.iterrows():
                ## For getting 'coordinate' or 'character'
                if extract_target in ['coordinate', 'character']:
                    if (match_pattern == 'include' and str.lower(key_phrase) in str.lower(data['content']))\
                        or (match_pattern == 'exact' and str.lower(key_phrase) == str.lower(data['content'])):
                        if extract_target == 'coordinate':
                            feature_list.append([index, data['x_mean'], data['y_mean']])
                        elif extract_target == 'character':
                            feature_list.append(data['content'])
                            print('matched!')
                ## For getting key-value
                elif extract_target == 'key-value':
                    if (match_pattern == 'include' and str.lower(key_phrase) in str.lower(data['key']))\
                        or (match_pattern == 'exact' and str.lower(key_phrase) == str.lower(data['key'])):
                        feature_list.append(data['value'])
            return feature_list
        except Exception as e:
            self.error(f'Unable to extract feature')
            raise

    def add_col(self,
                df: pd.DataFrame,
                key_phrase: str,
                match_pattern: str,
                x_or_y: str)-> pd.DataFrame:
        try:
            ## Extract coordinates
            center_list = self.extract_feature(df = df,
                                        key_phrase = key_phrase,
                                        match_pattern = match_pattern,
                                        extract_target = 'coordinate')
            col = 'distance_' + key_phrase.replace(' ', '_') + '_' + x_or_y
            coord_number = 1 if x_or_y == 'x' else 2
            ## Add additional distance as separate column
            df[col] = df['y_mean'].apply(lambda x: abs(x - center_list[0][coord_number]))
            return df
        except Exception as e:
            self.error(f'Unable add columns: {e}')
            raise

    def add_min_max(self,
        result_list: list) -> list:
        try:
            for result_num in range(len(result_list)):
                for data in result_list[result_num]['paragraphs']:
                    data['x_min'] = np.min([coord['x'] for coord in data['bounding_regions'][0]['polygon']])
                    data['x_max'] = np.max([coord['x'] for coord in data['bounding_regions'][0]['polygon']])
                    data['y_min'] = np.min([coord['y'] for coord in data['bounding_regions'][0]['polygon']])
                    data['y_max'] = np.max([coord['y'] for coord in data['bounding_regions'][0]['polygon']])
            return result_list
        except Exception as e:
            self.error(f'Unable to add min and max: {e}')
            raise

    def extract_numerical_values(self,
                    df: pd.DataFrame,
                    col: str)-> list:
        '''
        Extract values with target columns
        '''
        try:
            ## Eliminate non-convertible records to numbers
            df['content_replaced'] = df['content'].apply(lambda x: x.replace('.','').replace(',', '').replace(' ', ''))
            df_replaced = df[pd.to_numeric(df['content_replaced'], errors="coerce").notna()]
            ## Sort with give column and pick up top 2
            candidate_values = list(df_replaced.nsmallest(2, col).sort_values('x_mean')['content_replaced'])
            return float(candidate_values[0]), float(candidate_values[1])
        except Exception as e:
            self.error(f'Unable to extrace numerical values: {e}')
            raise

    def generate_df_paragraph(self,
                        result_list: list,
                        result_num: int) -> pd.DataFrame:
        '''
        Generate DataFrame and pick up some fields
        '''
        try:
            global_list = [[d['content'], d['x_min'], d['x_max'], d['y_min'], d['y_max']] for d in result_list[result_num]['paragraphs']]
            return pd.DataFrame(global_list, columns=['content', 'x_min', 'x_max', 'y_min', 'y_max'])
        except Exception as e:
            self.error(f'Unable to generate dataframe: {e}')
            raise

    def extract_name_from_paragraph(self,
                                df: pd.DataFrame,
                                key_phrase: str,
                                x_range: float) -> str:
        try:
            ## Extract coordinates of key phrase
            x_min_key_phrase = df[df['content'] == key_phrase]['x_min'].values[0]
            y_min_key_phrase = df[df['content'] == key_phrase]['y_min'].values[0]

            ## Match the rectangle and extract value
            return df[(df.x_min >= x_min_key_phrase - x_range) \
                    & (df.x_min <= x_min_key_phrase + x_range) \
                    & (df.y_min > y_min_key_phrase)].nsmallest(1 ,'y_min')['content'].values[0]
        except Exception as e:
            self.error(f'Unable to extract name from paragraph: {e}')
            raise

    def convert_result_to_table(self) -> pd.DataFrame:
        '''
        extract necessary fields
        '''
        try:
            # Preprocessing
            ## Add some features
            ### Add 'centeral point' with 4 edges
            self.result_list = self.add_centers(self.result_list)
            ### Add edge coordinates: x_min, x_max, y_min, y_max
            self.result_list = self.add_min_max(self.result_list)

            total_output = []
            for result_num in range(len(self.result_list)):
                ## Picked up Doc id
                doc_id = self.result_list[result_num]['file_name'].replace('.pdf', '')

                ## Extract part of result_list, and convert them into DataFrame
                df_table = self.generate_df_table(result_list = self.result_list,
                                            result_num = result_num)
                df_paragraph = self.generate_df_paragraph(result_list=self.result_list,
                                                    result_num= result_num)
                df_kv = self.generate_df_kv(result_list=self.result_list,
                                        result_num=result_num)

                ## Add distance from 'total revenue' key phrase
                df_table = self.add_col(df=df_table,
                                        key_phrase = 'total revenue',
                                        match_pattern='include',
                                        x_or_y='y')

                ## add distance from 'total expense' key phrase
                df_table = self.add_col(df=df_table,
                                        key_phrase='total expense',
                                        match_pattern='include',
                                        x_or_y='y')

                # Extract values
                ## For total revenue
                prior_rev, current_rev = self.extract_numerical_values(df=df_table, col='distance_total_revenue_y')
                ## For total expense
                prior_exp, current_exp = self.extract_numerical_values(df=df_table, col='distance_total_expense_y')
                ## Calculate profit or loss
                prior_profit_loss, current_profit_loss = prior_rev - prior_exp, current_rev - current_exp
                ## For company name
                try:
                    ## Next to "C"
                    company_name = self.extract_name_from_paragraph(df=df_paragraph, 
                                                                    key_phrase='C', 
                                                                    x_range=0.05)
                except:
                    try:
                        ## Next to 'C Name of organization'
                        print('second')
                        company_name = self.extract_feature(df=df_table, 
                                                            match_pattern = 'include',
                                                            key_phrase = 'name of organization',
                                                            extract_target='character')[0]
                        company_name = company_name.replace('C Name of organization ', '')
                    except:
                        try:
                            ## Pick up 'key-value' area of Form Recognizer
                            print('third')
                            company_name = self.extract_feature(df=df_kv,
                                                                match_pattern = 'include',
                                                                key_phrase = 'Name of organization',
                                                                extract_target='key-value')[0]
                        except:
                            company_name = 'N/A'
                            print('Cannot find company name so far.')

                ### Save the data as csv file
                total_output.append([doc_id, \
                                    company_name, \
                                    prior_rev, \
                                    prior_exp, \
                                    prior_profit_loss, \
                                    current_rev, \
                                    current_exp, \
                                    current_profit_loss])
            return pd.DataFrame(total_output, columns=self.used_columns)
        except Exception as e:
            self.error(f'Unable to convert to pd.DataFrame: {e}')
            raise

    def save_pickle(self,
                df_output: pd.DataFrame,
                output_path: str) -> None:
        try:
            os.makedirs(output_path, exist_ok=True)
            df_output.to_pickle(output_path + '/df_output.pkl')
        except Exception as e:
            self.error(f'Unable to save as pickle: {e}')
            raise

class train_and_score(Utils, logHandler):
    def __init__(self,
        ## Logging
        log_config: str,
        ## input PDF file path
        analyzed_output_path: str,
        ## Output for scored results
        scored_path: str,
        ## columns to be used in DataFrame
        used_columns: str,
        ## Model param
        ml_config: str
        ):
        ## Inheritance from loghandler
        logHandler.__init__(self, log_config)
        ## Specific values to be used
        self.analyzed_output_path = analyzed_output_path
        ## 
        self.scored_path = scored_path
        ## Columns to be extracted
        self.used_columns = self.construct_cols(used_columns,
                                                include_column=True,
                                                exclude_column=True)
        ## ML model parameters
        self.ml_config = json.loads(ml_config)
        self.model_name = self.ml_config['NAME']
        self.model_filename = self.ml_config['FILE_NAME']
        self.model_contamination = self.ml_config['CONTAMINATION']
        self.model = None

    def load_df(self,
                input_path: str) -> pd.DataFrame:
        return pd.read_pickle(input_path + '/df_output.pkl')

    def select_columns(self,
                    df_original: pd.DataFrame) -> pd.DataFrame:
        try:
            return df_original[self.include_columns]
        except Exception as e:
            self.error(f'Unable to select columns from original DataFrame: {e}')

    def train_iForest(self,
            df_original: pd.DataFrame,
            contamination: float or str) -> None:
        '''
        '''
        try:
            ## Extract columns to be used in training
            df_selected = self.select_columns(df_original)
            ## Prep for parameter of ML
            if contamination != 'auto':
                contamination = float(contamination)
            ## Training
            self.model = IsolationForest(contamination=contamination).fit(df_selected)
        except Exception as e:
            self.error(f'Unable train with isolationForest:{e}')
            raise

    def score(self,
            df_original: pd.DataFrame) -> pd.DataFrame:
        '''
        Get Score and predict results for original DataFrame
        '''
        try:
            ## Extract columns to be used in training
            df_selected = self.select_columns(df_original).copy()
            ## Score & Predict
            df_original['score'] = self.model.score_samples(df_selected)
            df_original['predict'] = self.model.predict(df_selected)
            return df_original
        except Exception as e:
            self.error(f'Unable to score with model')
            raise

    def store_scored_results(self,
                            df_result: pd.DataFrame) -> None:
        '''
        '''
        try:
            os.makedirs(os.path.dirname(self.scored_path), exist_ok=True)            
            file_path = os.path.join(self.scored_path, 'result.csv')
            df_result.to_csv(file_path, index=False)
            self.info(f'Saved the scored results!')
        except Exception as e:
            self.error(f'Unable to store the scored results: {e}')
            raise

    def plot_scored_result(self,
                        df_result: pd.DataFrame)-> None:
        try:
            plt.figure(figsize=(15, 10))
            plt.hist(df_result['score'], bins=30)
            plt.xlabel('score(The lower, the more abnormal.)')
            plt.ylabel('frequency')
            plt.title('distribution of score')
            plt.savefig('my_plot.png')
            self.run.log_image('Plot', plot=plt)
            print(f'Saved images')
        except Exception as e:
            self.info(f'Error in {e}')
            raise
