#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import azureml
from azureml.core import Workspace, Dataset, Datastore, Experiment, Environment
from azureml.core.authentication import MsiAuthentication, ServicePrincipalAuthentication
from azureml.core.compute import AmlCompute, ComputeTarget
from azureml.core.compute_target import ComputeTargetException
from azureml.core.conda_dependencies import CondaDependencies
from azureml.core.runconfig import RunConfiguration

from azureml.pipeline.steps import PythonScriptStep
from azureml.pipeline.core import Pipeline, PipelineParameter, PipelineDraft

from azureml.data.datapath import DataPath, DataPathComputeBinding
from azureml.data import OutputFileDatasetConfig

class AzureMLConfiguration():
    """ 
    Class mainly to perform all necessary Auzre ML setups and configuration, including 
    workspace, datasets and piplines
    """

    def __init__(self, 
            workspace : str,
            subscription_id : str, 
            resource_group : str,
            tenant_id: str,
            sp_id: str,
            sp_secret: str
        ) -> None:
        super().__init__() # inherit if applicable

        self.workspace_name = workspace
        self.subscription_id = subscription_id
        self.resource_group = resource_group
        self.tenant_id = tenant_id
        self.sp_id = sp_id
        self.sp_secret = sp_secret
        
        # workspace and other features will be assigned once configured
        self.ws = None
        self.ml_client = None
        self.cpu_compute_target = 'cpu-cluster'
        self.env = None

        # pipeline 
        self.aml_run_config = None
        self.experiment = None

    def configWorkspace(self) -> None:
        """
        The Azure ML Workspace is key parameter for performing the text analytics, pipeline development and deployment. 
        Here, the Azure ML workspace is created (if doesnt exist) or extracts an exisitng instance
        The datastore and the asscoated datasets contain all the input data
        """
        # obtaining the wrkspace requires authentification. Here, the managed serive authentication is used
        try:
            ## Authentication with managed identity
            msi_auth = MsiAuthentication()
            # print the workspace information
            self.ws = Workspace(subscription_id=self.subscription_id,
                            resource_group=self.resource_group,
                            workspace_name=self.workspace_name,
                            auth=msi_auth)
            print(f'Succeeded in configuring workspace{self.ws}')
        except:
            print('Cannot get Azure ML Workspace.')
            raise

    def configWorkspaceSP(self) -> None:
        try:
            # Set SP variables
            svc_pr = ServicePrincipalAuthentication(
                            tenant_id=self.tenant_id,
                            service_principal_id=self.sp_id,
                            service_principal_password=self.sp_secret)
            # print the workspace information
            self.ws = Workspace(subscription_id=self.subscription_id,
                            resource_group=self.resource_group,
                            workspace_name=self.workspace_name,
                            auth=svc_pr
                            )
            print(f'Succeeded in configuring workspace with Service Principal{self.ws}')
        except:
            print('Cannot get Azure ML Workspace.')
            raise

    def configCompute(self,
                    cpu_compute_target : str = 'cpu-cluster',
                    size : str               = 'Standard_E4a_v4',
                    min_instances : int      = 0,
                    max_instances : int      = 4,
                    vm_priority : str        = 'lowpriority',
                    identity_type : str      = 'SystemAssigned'
                    ) -> None:
        """
        The Azure ML compute target is created if it doesnt existy
        """
        
        if(self.ws is not None):
            try:
                self.compute_target = ComputeTarget(workspace=self.ws, name=cpu_compute_target)

            except ComputeTargetException:
                config = AmlCompute.provisioning_configuration(vm_size=size,
                                                            vm_priority=vm_priority, 
                                                            min_nodes=min_instances, 
                                                            max_nodes=max_instances,
                                                            identity_type=identity_type)

                self.compute_target = ComputeTarget.create(workspace=self.ws,
                                                        name=cpu_compute_target,
                                                        provisioning_configuration=config)
                self.compute_target.wait_for_completion(show_output=True, 
                                                        min_node_count=None, 
                                                        timeout_in_minutes=20)
            finally:
                print(f'The AML compute target name is {self.compute_target.name}')
        else:
            print('Error in workspace resulted to compute error')
            raise

    def configEnvironment(self, 
                        environment_name : str ='env',
                        file_path : str        ='./requirements.txt'
                        ) -> None:
        """
        Function to create the Azure ML environment
        """       
        try:
            if self.ws is not None:
                self.environment = Environment.from_pip_requirements(name = environment_name,
                                                                    file_path=file_path)
#                self.environment = Environment.from_dockerfile(name=environment_name,
#                                                                dockerfile=file_path)                                
                # Register environment to re-use later
                self.environment.register(workspace=self.ws)
            else:
                raise Exception('Workspace error')
        except Exception as error:
            print(f'Error in {error}')
            raise

    def getDatastore(self, 
                    datastore_name : str,
                    ) -> azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore:
        """
        Function to return the datastore from the workspace
        """
        try:
            datastore, dataset = None, None
            # get the datastore object
            datastore = Datastore.get(self.ws, datastore_name=datastore_name) 

        except Exception as error:
            print(f'Error in {error}')
        finally:
            return datastore

    def getDatastoreDataset(self, 
                        datastore_name : str,
                        file_path : str
                        ) -> Tuple[azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore,
                                    azureml.data.tabular_dataset.TabularDataset]:
        """
        Function to return the datastore from the workspace
        """
        try:
            datastore, dataset = None, None
            # get the datastore object
            datastore = Datastore.get(self.ws, 
                                    datastore_name=datastore_name) 
            dataset = Dataset.Tabular.from_delimited_files(path = (datastore, file_path)) 

        except Exception as error:
            print(f'Error in {error}')
        finally:
            return datastore, dataset

    def configPipeline_Basic(self) -> None:
        """
        Function to configure the Azure ML pipeline and its parameters with the same environment
        with AML Environment
        """
        try:
            # may require to set the azure ml snapshot size
            azureml._restclient.snapshots_client.SNAPSHOT_MAX_SIZE_BYTES = 1000000000

            # setup the pipeline run configuration
            self.aml_run_config = RunConfiguration()                                    
            self.aml_run_config.target = self.compute_target
            self.aml_run_config.environment = self.environment        
        except Exception as error:
            print(f'Error in {error}')

    def configPipeline(self, 
                    python_version : str,
                    conda_packages : list, 
                    pip_packages : list) -> None:
        """
        Function to configure the Azure ML pipeline and its parameters
        Please use it, if you want fine-tuning about the environment in AML pipeline
        """
        try:
            # may require to set the azure ml snapshot size
            azureml._restclient.snapshots_client.SNAPSHOT_MAX_SIZE_BYTES = 1000000000

            # setup the pipeline run configuration
            self.aml_run_config = RunConfiguration()                                    
            self.aml_run_config.target = self.compute_target
            self.aml_run_config.environment = self.environment
            self.aml_run_config.environment.python.conda_dependencies = CondaDependencies.create(
                python_version=python_version
                ,conda_packages=conda_packages
                ,pip_packages=pip_packages
                ,pin_sdk_version=False)

        except Exception as error:
            print(f'Error in {error}')

    def configPipelineInputValue(self,
                                pipeline_name : str,
                                default_value : str) -> azureml.pipeline.core.graph.PipelineParameter:
        """
        Function to configure the pipeline input value path
        """
        try:
            pipeline_param = PipelineParameter(name=pipeline_name, default_value=default_value)
        except Exception as error:
            print(f'Error in {error}')        
        finally:
            return pipeline_param

    def configPipelineInputData(self,
                            datastore : azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore, 
                            path_on_datastore : str
                            ) -> azureml.data.datapath.DataPathComputeBinding:
        """
        Function to configure the pipeline input data path
        """
        try:
            datapath_pipeline_param = None
            datapath_input = None

            if datastore is not None:
                # setup the data path
                data_path = DataPath(datastore=datastore, path_on_datastore=path_on_datastore)
                # setup the parapeter and the input path
                datapath_pipeline_param = PipelineParameter(name='Datastore where raw files are located', 
                                                            default_value=data_path)
                datapath_input = (datapath_pipeline_param, DataPathComputeBinding(mode='download'))
            else:
                raise Exception("Datastore is none'")
        except Exception as error:
            print(f'Error in {error}')

        finally:
            return datapath_input        

    def configPipelineOutputData(self,
                                datastore : azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore,
                                store_name : str,
                                stored_path : str,
                                overwrite_flg: bool
                                ) -> azureml.data.output_dataset_config.OutputFileDatasetConfig:
        try:
            output_data = None
            output_data = OutputFileDatasetConfig(name=store_name,
                                                destination=(datastore, stored_path)
                                                ).as_upload(overwrite=overwrite_flg)
        except Exception as error:
            print(f'Error in {error}')
        finally:
            return output_data   

    def configExperiment(self, 
                        experiment_name : str
                        ) -> None:
        """
        Function to create the ML experiments
        """
        try:
            if self.ws is not None:
                self.experiment = Experiment(workspace=self.ws, name=experiment_name)
            else:
                raise Exception('Workspace error')

        except Exception as error:
            print(f'Error in {error}')   

    def buildPipeline(self, 
                    script_steps : list
                    ) -> azureml.pipeline.core.pipeline.Pipeline:
        """
        Function to buld the pipeline based on thhe provided steps
        """
        try:
            pipeline = None
            if self.ws is not None:
                # build the pipeline
                pipeline = Pipeline(workspace=self.ws, steps=script_steps)
                # Validate the pipeline
                print(f'Found {len(pipeline.validate())} error(s) in built pipeline')
            else:
                raise Exception('Azure ml workspace is nonw')

        except Exception as error:
            print(f'Error in {error}')

        finally:
            return pipeline

    def draftPipeline(self,
                        name: str,
                        description: str,
                        experiment_name: str,
                        pipeline: azureml.pipeline.core.pipeline.Pipeline,
                        tags: dict,
                        properties: dict,
                        ) -> azureml.pipeline.core.pipeline_draft.PipelineDraft:
        try:
            if self.ws is not None:
                pipeline_draft = PipelineDraft.create(workspace=self.ws,
                                                    name=name,
                                                    description=description,
                                                    experiment_name=experiment_name,
                                                    pipeline=pipeline,
                                                    continue_on_step_failure=True,
                                                    tags=tags,
                                                    properties=properties
                                                    )
        except Exception as error:
            print(f'Cannot create draftPipeline: {error}')
        finally:
            return pipeline_draft

    def publishPipeline(self,
                        pipeline : azureml.pipeline.core.pipeline.Pipeline,
                        name : str,
                        description : str,
                        version : str
                        ) -> azureml.pipeline.core.graph.PublishedPipeline:
        try:
            published_pipeline = pipeline.publish(name=name,
                                    description=description,
                                    version=version)
        except Exception as error:
            print(f'Error in {error}')

        finally:
            return published_pipeline

    def publishPipelineFromDraft(self,
                                pipeline_id):
        try:
            if self.ws is not None:
                ## Get draft pipeline with pipeline_id
                draft_pipeline = PipelineDraft.get(workspace = self.ws
                                                ,id = pipeline_id)
                ## Publish the draft pipeline
                published_pipeline = draft_pipeline.publish()
        except Exception as error:
            print(f'Error in {error}')
        finally:
            return published_pipeline
