"""
Serviço para detectar gateways de pagamento
"""

import logging
from typing import List, Optional

from config.settings import AppConfig

logger = logging.getLogger(__name__)


class PaymentGatewayDetector:
    """Responsável por detectar gateways de pagamento em nomes de tabelas"""
    
    def __init__(self, keywords: Optional[List[str]] = None):
        self.keywords = keywords or AppConfig.DEFAULT_KEYWORDS
        logger.info(f"Detector inicializado com {len(self.keywords)} palavras-chave")
    
    def is_payment_gateway(self, table_name: str) -> bool:
        """Verifica se o nome da tabela indica um gateway de pagamento"""
        table_lower = table_name.lower()
        return any(keyword in table_lower for keyword in self.keywords)
