class ThreatPredictor:
    def __init__(self):
        # Define the typical kill chain phases
        self.phases = [
            "reconnaissance",
            "initial_access",
            "execution",
            "persistence",
            "privilege_escalation",
            "defense_evasion",
            "credential_access",
            "discovery",
            "lateral_movement",
            "collection",
            "exfiltration",
            "impact"
        ]

    def predict_next_stage(self, event_data: dict) -> dict:
        """
        Uses heuristic/statistical models to predict the next likely phase of an attack.
        IMPORTANT LIMITATION: This cannot predict unknown zero-days. It only maps known 
        behaviors to the MITRE ATT&CK kill chain to anticipate the attacker's next goal.
        """
        current_phase = event_data.get("mitre_tactic", "unknown").lower()
        
        if current_phase not in self.phases:
            return {
                "prediction": "unknown",
                "confidence": 0.0,
                "reason": "Current phase not recognized in standard kill chain."
            }
            
        current_index = self.phases.index(current_phase)
        
        if current_index < len(self.phases) - 1:
            next_phase = self.phases[current_index + 1]
            return {
                "predicted_next_phase": next_phase,
                "risk_evolution": "increasing",
                "confidence": 0.65, # Heuristic confidence
                "mitigation_focus": f"Implement controls to prevent {next_phase}"
            }
        else:
            return {
                "predicted_next_phase": "none",
                "risk_evolution": "peaked",
                "confidence": 0.9,
                "mitigation_focus": "Containment and Recovery"
            }
