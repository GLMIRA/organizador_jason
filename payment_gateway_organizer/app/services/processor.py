"""
Serviço para processar arquivos JSON
"""

import json
import logging
from pathlib import Path
from typing import List, Dict, Any

from models.gateway import GatewayInfo
from .detector import PaymentGatewayDetector
from .extractor import GatewayDataExtractor

logger = logging.getLogger(__name__)


class JSONProcessor:
    """Responsável por processar arquivos JSON"""
    
    def __init__(self, detector: PaymentGatewayDetector, extractor: GatewayDataExtractor):
        self.detector = detector
        self.extractor = extractor
    
    def process_file(self, file_path: Path) -> List[GatewayInfo]:
        """Processa um arquivo JSON individual"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            site_url = data.get('site', 'unknown')
            tables = data.get('tables', [])
            
            logger.info(f"Processando: {site_url}")
            
            gateways = self._extract_gateways_from_tables(tables, site_url)
            
            logger.info(f"Total de gateways encontrados: {len(gateways)}")
            return gateways
            
        except Exception as e:
            logger.error(f"Erro ao processar {file_path}: {str(e)}")
            return []
    
    def _extract_gateways_from_tables(self, tables: List[Dict], site_url: str) -> List[GatewayInfo]:
        """Extrai gateways das tabelas"""
        gateways = []
        
        for table_obj in tables:
            if isinstance(table_obj, dict):
                for table_name, table_data in table_obj.items():
                    if self.detector.is_payment_gateway(table_name):
                        gateway_info = self.extractor.extract_gateway_info(
                            table_name, table_data, site_url
                        )
                        gateways.append(gateway_info)
                        logger.info(f"Gateway encontrado: {table_name}")
        
        return gateways
