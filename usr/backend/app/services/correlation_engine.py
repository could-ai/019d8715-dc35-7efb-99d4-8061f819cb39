import networkx as nx
from typing import Dict, Any

class CorrelationEngine:
    def __init__(self):
        # Using a graph to track entities (IPs, Users, Hosts) and their relationships/events
        self.graph = nx.DiGraph()

    def analyze(self, event: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyzes an incoming event and correlates it with existing graph data.
        Detects patterns like brute force, lateral movement, etc.
        """
        source_ip = event.get("src_ip")
        dest_ip = event.get("dest_ip")
        event_type = event.get("type") # e.g., "failed_login", "network_connection"
        
        if not source_ip or not dest_ip:
            return {"suspicious": False, "reason": "Missing IP data"}

        # Add nodes and edges
        self.graph.add_node(source_ip, type="ip")
        self.graph.add_node(dest_ip, type="ip")
        
        # Add edge with event details
        if self.graph.has_edge(source_ip, dest_ip):
            self.graph[source_ip][dest_ip]['weight'] += 1
            self.graph[source_ip][dest_ip]['events'].append(event_type)
        else:
            self.graph.add_edge(source_ip, dest_ip, weight=1, events=[event_type])

        # Simple Rule: Brute Force Detection
        edge_data = self.graph.get_edge_data(source_ip, dest_ip)
        if edge_data and edge_data['weight'] > 5 and "failed_login" in edge_data['events']:
            return {
                "suspicious": True,
                "pattern": "Potential Brute Force",
                "source": source_ip,
                "target": dest_ip,
                "confidence": 0.85
            }
            
        # Simple Rule: Lateral Movement (Source IP connects to multiple internal IPs)
        out_degree = self.graph.out_degree(source_ip)
        if out_degree > 3:
             return {
                "suspicious": True,
                "pattern": "Potential Lateral Movement / Scanning",
                "source": source_ip,
                "confidence": 0.75
            }

        return {"suspicious": False}
