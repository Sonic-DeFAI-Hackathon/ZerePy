"""
Mock Goat Connection for Baultro Integration

This is a placeholder that doesn't attempt to import external dependencies
"""

import logging
from typing import Dict, Any, List
from src.connections.base_connection import BaseConnection, Action, ActionParameter

logger = logging.getLogger("connections.goat_connection")

class GoatConnectionError(Exception):
    """Base exception for Goat connection errors"""
    pass

class GoatConnection(BaseConnection):
    """Mock Goat Connection for compatibility with the connection manager"""
    
    def __init__(self, config: Dict[str, Any]):
        logger.info("Mock Goat Connection - Not functional for Baultro")
        super().__init__(config)
    
    @property
    def is_llm_provider(self) -> bool:
        return False
        
    def validate_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        return config
        
    def register_actions(self) -> None:
        self.actions = {}
        
    def configure(self) -> bool:
        return False
        
    def is_configured(self, verbose: bool = False) -> bool:
        return False
        
    def perform_action(self, action_name: str, kwargs) -> Any:
        raise GoatConnectionError("Goat Connection is not supported in Baultro")
