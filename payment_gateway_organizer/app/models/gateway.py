"""
Modelo de dados para Gateway de Pagamento
"""

from dataclasses import dataclass, field
from typing import Dict, Any


@dataclass
class GatewayInfo:
    """Classe para representar informações de um gateway de pagamento"""
    site: str
    gateway_name: str
    url: str = ""
    client_id: str = ""
    client_secret: str = ""
    ativo: str = ""
    outros_dados: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, str]:
        """Converte para dicionário para uso no DataFrame"""
        return {
            'Site': self.site,
            'Gateway': self.gateway_name,
            'URL': self.url,
            'Client ID': self.client_id,
            'Client Secret': self.client_secret,
            'Ativo': self.ativo,
            'Outros Dados': str(self.outros_dados) if self.outros_dados else ''
        }
