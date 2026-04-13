from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
import asyncio

from app.services.ai_analyst import AIAnalyst
from app.services.correlation_engine import CorrelationEngine
from app.services.soar import SOAR
from app.services.osint import OSINTManager
from app.services.prediction import ThreatPredictor

app = FastAPI(title="SOC Backend API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ai_analyst = AIAnalyst()
correlation_engine = CorrelationEngine()
soar = SOAR()
osint_manager = OSINTManager()
predictor = ThreatPredictor()

@app.get("/")
def read_root():
    return {"status": "SOC Backend is running"}

@app.get("/api/dashboard/stats")
async def get_dashboard_stats():
    return {
        "global_risk_score": 72,
        "local_risk_score": 45,
        "active_alerts": 12,
        "ai_insights": 3
    }

@app.post("/api/ingest/log")
async def ingest_log(log_data: dict, background_tasks: BackgroundTasks):
    # 1. Correlate
    correlation_result = correlation_engine.analyze(log_data)
    
    # 2. If suspicious, trigger AI Analyst
    if correlation_result.get("suspicious"):
        background_tasks.add_task(process_suspicious_event, log_data, correlation_result)
        
    return {"status": "Log ingested", "correlation": correlation_result}

async def process_suspicious_event(log_data: dict, correlation_result: dict):
    # AI Analysis
    analysis = await ai_analyst.analyze_event(log_data)
    
    # Prediction
    prediction = predictor.predict_next_stage(log_data)
    
    # SOAR Action
    if analysis.get("severity") in ["high", "critical"]:
        soar.execute_defensive_action(log_data, analysis)
        
@app.get("/api/osint/cve")
async def get_cve_intel():
    return osint_manager.fetch_latest_cves()
