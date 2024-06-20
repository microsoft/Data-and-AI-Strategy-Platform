#// Copyright (c) Microsoft Corporation.
#// Licensed under the MIT license.
from typing import Tuple
import os
import pickle
import json
import numpy as np
import joblib
from sklearn.linear_model import Ridge
from azureml.core.model import Model
import time

def init():
    global model
    # note here "sklearn_regression_model.pkl" is the name of the model registered under the workspace
    # this call should return the path to the model.pkl file on the local disk.
    model_path = Model.get_model_path(model_name = 'isolationForest_sklearn')
    #   

    # deserialize the model file back into a sklearn model
    model = joblib.load(model_path)

def run(input_data):
    try:
        ## retrieve model
        data = json.loads(input_data)['data']
        data = np.array(data).reshape(1, -1)
        ## predict with the existing model
        result = model.predict(data)
        info = {
            "input": input_data,
            "output": result.tolist()
        }
        print(json.dumps(info))
        ## return the predict value
        return result.tolist()
    except Exception as e:
        error = str(e)
        print (error + time.strftime("%H:%M:%S"))
        return error