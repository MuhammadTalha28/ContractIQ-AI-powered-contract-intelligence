FROM python:3.9-slim

WORKDIR /opt/ml/code

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY risk_scorer_model.py .

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONONDONTWRITEBYTECODE=TRUE

ENTRYPOINT ["python", "risk_scorer_model.py"]

