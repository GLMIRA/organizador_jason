"""
Configurações da aplicação
"""


class AppConfig:
    """Configurações centralizadas da aplicação"""
    
    # Palavras-chave para detectar gateways
    DEFAULT_KEYWORDS = [
        'pay', 'pagamento', 'payment', 'bank', 'banco', 'pix', 'card', 'cartao',
        'wallet', 'checkout', 'mercado', 'pagseguro', 'paypal', 'stripe',
        'gateway', 'financeiro', 'transacao', 'billing', 'invoice', 'fatura'
    ]
    
    # Mapeamento de campos
    FIELD_MAPPING = {
        'url': ['url'],
        'client_id': ['client_id', 'clientid'],
        'client_secret': ['client_secret', 'clientsecret'],
        'ativo': ['ativo', 'active', 'status']
    }
    
    # Dados ignorados
    IGNORED_KEYS = {'id'}
    IGNORED_VALUES = {'-', ''}
    
    # Configurações Excel
    MAX_COLUMN_WIDTH = 50
    
    # Configurações de logging
    LOG_LEVEL = 'INFO'
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
