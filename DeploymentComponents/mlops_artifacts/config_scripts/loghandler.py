import json
import logging
from auth_with_managed_identity import *
from opencensus.ext.azure.log_exporter import AzureLogHandler

class logHandler(authManagementIdentity):
    def __init__(self,
        log_config: dict
    ):
        ## Check if run is for pytest
        self.run = self.check_aml_run()
        if self.run != None: ## For usual process
            authManagementIdentity.__init__(self)
            ## Parse log_config
            self.log_config = json.loads(log_config)
            ## Log level
            self.level = int(self.log_config['LEVEL'])
            ## Define custom dimension
            self.custom_dimensions = {}
            self.custom_dimensions_flg = self.log_config['CUSTOM_DIMENSIONS_FLG']
            self.set_custom_dimension()

            ## Initialization
            self.logger = logging.getLogger(__name__)
            ## Set logger level
            self.logger.setLevel(self.level)

            ## Azure handler
            self.logger.addHandler(AzureLogHandler(connection_string='InstrumentationKey={}'.format(self.instrument_key)))

            ## Stream handler
            self.ch = logging.StreamHandler()
            self.ch.setLevel(logging.INFO)
            ch_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S')
            self.ch.setFormatter(ch_formatter)
            self.logger.addHandler(self.ch)

    def set_custom_dimension(self) -> None:
        '''
        Define custom dimension inserted into AppInsight        
        '''
        if self.custom_dimensions_flg is not None:
            if self.custom_dimensions_flg['parent_run_id']:
                self.custom_dimensions['parent_run_id'] = self.run.parent.id
            if self.custom_dimensions_flg['step_id']:
                self.custom_dimensions['setp_id'] = self.run.id
            if self.custom_dimensions_flg['step_name']:
                self.custom_dimensions['step_name'] = self.run.name
            if self.custom_dimensions_flg['experiment_name']:
                self.custom_dimensions['experiment_name'] = self.run.experiment.name
            if self.custom_dimensions_flg['run_url']:
                self.custom_dimensions['run_url'] = self.run.parent.get_portal_url()
        else:
            print(f'Not found for custom dimension on AppInsight.')

    def info(self, message: str) -> None:
        ## For pytest
        if self.run is None:
            print(message)
        ## Usual process without custom dimensions
        elif self.custom_dimensions_flg is None:
            self.logger.info(message)
        else:
            self.logger.info(message,
                            extra= {"custom_dimensions":self.custom_dimensions})
    
    def error(self, message: str) -> None:
        ## For pytest
        if self.run is None:
            print(message)
        ## Usual process without custom dimensions
        elif self.custom_dimensions_flg is None:
            self.logger.error(message)
        else:
            self.logger.error(message,
                            extra= {"custom_dimensions":self.custom_dimensions})
    
    def warning(self, message: str) -> None:
        ## For pytest
        if self.run is None:
            print(message)
        ## Usual process without custom dimensions
        elif self.custom_dimensions_flg is None:
            self.logger.warning(message)
        else:
            self.logger.warning(message,
                            extra= {"custom_dimensions":self.custom_dimensions})