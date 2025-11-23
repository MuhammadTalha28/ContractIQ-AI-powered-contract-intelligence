"""
SageMaker inference script for risk scoring model.
This script handles model loading, input parsing, prediction, and output formatting.
"""
import json
import pickle
import os
import numpy as np


def model_fn(model_dir):
    """
    Load the model from the model directory.
    
    Args:
        model_dir: Path to directory containing model file
        
    Returns:
        Loaded model object
    """
    model_path = os.path.join(model_dir, 'model.pkl')
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    return model


def input_fn(request_body, content_type):
    """
    Parse input data for inference.
    
    Args:
        request_body: Raw request body (string)
        content_type: Content type of request (e.g., 'text/csv')
        
    Returns:
        Numpy array of features ready for prediction
    """
    if content_type == 'text/csv':
        # Parse CSV string: "10,5,2,3,1,0.7"
        features = [float(x.strip()) for x in request_body.split(',')]
        return np.array(features).reshape(1, -1)
    elif content_type == 'application/json':
        # Parse JSON: {"features": [10, 5, 2, 3, 1, 0.7]}
        data = json.loads(request_body)
        features = data.get('features', [])
        return np.array(features).reshape(1, -1)
    else:
        raise ValueError(f"Unsupported content type: {content_type}")


def predict_fn(input_data, model):
    """
    Make prediction using the model.
    
    Args:
        input_data: Feature array from input_fn
        model: Loaded model from model_fn
        
    Returns:
        Dictionary with predictions
    """
    prediction = model.predict(input_data)
    # Ensure prediction is between 0-100
    prediction = np.clip(prediction, 0, 100)
    return {'predictions': [float(p) for p in prediction]}


def output_fn(prediction, accept):
    """
    Format prediction output.
    
    Args:
        prediction: Prediction dictionary from predict_fn
        accept: Accept header from request
        
    Returns:
        Formatted prediction string
    """
    if accept == 'application/json':
        return json.dumps(prediction)
    elif accept == 'text/csv':
        return str(prediction['predictions'][0])
    else:
        # Default to JSON
        return json.dumps(prediction)

