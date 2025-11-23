"""
SageMaker ML model for contract risk scoring.
Trains a simple regression model to predict risk scores (0-100).
"""
import pickle
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import pandas as pd


def train_model():
    """
    Train a risk scoring model.
    
    Features:
    - clauses_count: Number of clauses in contract
    - risky_keywords: Count of risky keywords
    - missing_clauses: Number of missing critical clauses
    - hidden_risks: Number of hidden risks identified
    - has_penalties: Binary flag for penalty terms
    - liability_score: Liability risk score (0-1)
    
    Target:
    - risk_score: Risk score (0-100)
    """
    # Generate synthetic training data
    # In production, this would come from historical contract data
    np.random.seed(42)
    n_samples = 1000
    
    X = np.random.rand(n_samples, 6)
    X[:, 0] = np.random.randint(5, 50, n_samples)  # clauses_count
    X[:, 1] = np.random.randint(0, 20, n_samples)   # risky_keywords
    X[:, 2] = np.random.randint(0, 10, n_samples)   # missing_clauses
    X[:, 3] = np.random.randint(0, 15, n_samples)   # hidden_risks
    X[:, 4] = np.random.randint(0, 2, n_samples)    # has_penalties
    X[:, 5] = np.random.rand(n_samples)             # liability_score
    
    # Generate target with some logic
    y = (
        20 +  # base score
        X[:, 0] * 0.5 +  # clauses
        X[:, 1] * 3 +    # risky keywords
        X[:, 2] * 2 +    # missing clauses
        X[:, 3] * 4 +    # hidden risks
        X[:, 4] * 15 +   # penalties
        X[:, 5] * 25 +   # liability
        np.random.normal(0, 5, n_samples)  # noise
    )
    y = np.clip(y, 0, 100)  # Ensure 0-100 range
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train model
    model = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    print(f"Model Performance:")
    print(f"  MSE: {mse:.2f}")
    print(f"  R² Score: {r2:.3f}")
    
    # Save model
    with open('model.pkl', 'wb') as f:
        pickle.dump(model, f)
    
    print("Model saved to model.pkl")
    return model


def model_fn(model_dir: str):
    """
    Load model for SageMaker inference.
    
    Args:
        model_dir: Directory containing model file
        
    Returns:
        Loaded model
    """
    with open(f'{model_dir}/model.pkl', 'rb') as f:
        model = pickle.load(f)
    return model


def input_fn(request_body: str, content_type: str):
    """
    Parse input data for inference.
    
    Args:
        request_body: CSV string of features
        content_type: Content type (text/csv)
        
    Returns:
        Numpy array of features
    """
    if content_type == 'text/csv':
        features = [float(x) for x in request_body.split(',')]
        return np.array(features).reshape(1, -1)
    else:
        raise ValueError(f"Unsupported content type: {content_type}")


def predict_fn(input_data, model):
    """
    Make prediction using model.
    
    Args:
        input_data: Feature array
        model: Trained model
        
    Returns:
        Prediction result
    """
    prediction = model.predict(input_data)
    return {'predictions': [float(p) for p in prediction]}


def output_fn(prediction, accept: str):
    """
    Format prediction output.
    
    Args:
        prediction: Model prediction
        accept: Accept header
        
    Returns:
        Formatted prediction string
    """
    if accept == 'application/json':
        import json
        return json.dumps(prediction)
    else:
        return str(prediction['predictions'][0])


if __name__ == '__main__':
    train_model()

