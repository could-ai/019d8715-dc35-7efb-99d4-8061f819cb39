import httpx
import logging

logger = logging.getLogger(__name__)

class OSINTManager:
    def __init__(self):
        self.nvd_cve_url = "https://services.nvd.nist.gov/rest/json/cves/2.0"
        
    async def fetch_latest_cves(self):
        """
        Fetches recent CVEs from NVD.
        In a real scenario, this would run periodically and store in OpenSearch/Postgres.
        """
        try:
            async with httpx.AsyncClient() as client:
                # Fetching a small subset for demonstration
                response = await client.get(
                    self.nvd_cve_url, 
                    params={"resultsPerPage": 5},
                    timeout=10.0
                )
                if response.status_code == 200:
                    data = response.json()
                    cves = []
                    for item in data.get("vulnerabilities", []):
                        cve = item.get("cve", {})
                        cves.append({
                            "id": cve.get("id"),
                            "description": cve.get("descriptions", [{}])[0].get("value", "No description"),
                            "published": cve.get("published")
                        })
                    return {"status": "success", "data": cves}
                return {"status": "error", "message": f"HTTP {response.status_code}"}
        except Exception as e:
            logger.error(f"Failed to fetch CVEs: {e}")
            return {"status": "error", "message": str(e)}
