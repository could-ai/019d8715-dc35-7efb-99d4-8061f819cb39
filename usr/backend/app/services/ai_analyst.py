import httpx
import json
import os

class AIAnalyst:
    def __init__(self):
        self.ollama_url = os.getenv("OLLAMA_URL", "http://localhost:11434")
        self.model = "llama2" # Or mistral, depending on what is pulled

    async def analyze_event(self, event_data: dict) -> dict:
        prompt = f"""
        You are an expert SOC Analyst. Analyze the following security event log.
        Classify the threat level as: low, medium, high, or critical.
        Explain the event in human-readable language.
        Suggest DEFENSIVE actions only (e.g., block IP, isolate host). Do not suggest offensive actions.
        
        Event Data:
        {json.dumps(event_data, indent=2)}
        
        Respond in JSON format with keys: "severity", "explanation", "suggested_actions".
        """
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.ollama_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": prompt,
                        "stream": False,
                        "format": "json"
                    },
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return json.loads(result.get("response", "{}"))
                else:
                    return {"error": "Failed to reach LLM"}
        except Exception as e:
            return {"error": str(e), "severity": "unknown", "explanation": "AI analysis failed."}
