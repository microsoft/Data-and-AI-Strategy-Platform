# // Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from azure.identity import ManagedIdentityCredential
from azureml.core import Run

class authManagementIdentity():
    '''
    - Retrieve Run in Azure ML in executing pipeline processes
    - Define managed identity
    - Retrieve some constants stored in Azure KeyVault    
    '''
    def __init__(self,
    ):
        self.run = self.check_aml_run()
        if self.run != None:
            ## Get client_id of managed identity
            self.client_id = self.run.get_secret('mlComputeIdentity-client-id')
            ## Credential
            self.managedIdentityCredential = self.basicCredentialWithManagedidentity()
            ## Get values
            ### Form Recognizer URL
            self.form_recognizer_account = self.run.get_secret('FormRecognizerAccount')
            self.form_recognizer_url = 'https://{}.cognitiveservices.azure.com/'.format(self.form_recognizer_account)
            ### Instrument key in AppInsight
            self.instrument_key = self.run.get_secret('INSTRUMENTATIONKEY')

    def check_aml_run(self):
        '''
        Check if the process is test
        '''
        self.run = None
        try:
            self.run = Run.get_context(allow_offline=False)
        except:
            print('This process cannot get `Run` in AML. It could be test.')
        finally:
            return self.run

    def basicCredentialWithManagedidentity(self) -> ManagedIdentityCredential:
        '''
        Get credential with Managed Identity 
        '''
        try:
            return ManagedIdentityCredential(client_id=self.client_id)
        except Exception as error:
            print(f'Cannot authenticate with Managed identity: {error}')
            raise

