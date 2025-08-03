"""
Serviço para extrair dados dos gateways
"""

import logging
from typing import List, Dict, Any, Optional

from models.gateway import GatewayInfo
from config.settings import AppConfig

logger = logging.getLogger(__name__)


class GatewayDataExtractor:
    """Responsável por extrair dados dos gateways encontrados"""
    
    def __init__(self):
        self.field_mapping = AppConfig.FIELD_MAPPING
        self.ignored_keys = AppConfig.IGNORED_KEYS
        self.ignored_values = AppConfig.IGNORED_VALUES
    
    def extract_gateway_info(self, table_name: str, table_data: List[Any], site_url: str) -> GatewayInfo:
        """Extrai informações importantes do gateway"""
        gateway_info = GatewayInfo(site=site_url, gateway_name=table_name)
        
        if not table_data:
            return gateway_info
        
        self._process_table_data(table_data, gateway_info)
        return gateway_info
    
    def _process_table_data(self, table_data: List[Any], gateway_info: GatewayInfo) -> None:
        """Processa os dados da tabela e popula as informações do gateway"""
        for row in table_data:
            if isinstance(row, list):
                for item in row:
                    if isinstance(item, dict):
                        self._process_dict_item(item, gateway_info)
    
    def _process_dict_item(self, item: Dict[str, Any], gateway_info: GatewayInfo) -> None:
        """Processa um item do tipo dicionário"""
        for key, value in item.items():
            key_lower = key.lower()
            
            # Mapear campos conhecidos
            mapped_field = self._map_field(key_lower)
            if mapped_field:
                setattr(gateway_info, mapped_field, value)
            elif self._should_store_as_other_data(key_lower, value):
                gateway_info.outros_dados[key] = value
    
    def _map_field(self, key_lower: str) -> Optional[str]:
        """Mapeia uma chave para um campo do GatewayInfo"""
        for field, keywords in self.field_mapping.items():
            if any(keyword in key_lower for keyword in keywords):
                return field
        return None
    
    def _should_store_as_other_data(self, key_lower: str, value: Any) -> bool:
        """Verifica se o dado deve ser armazenado como outros dados"""
        return (
            key_lower not in self.ignored_keys and
            value not in self.ignored_values
        )
