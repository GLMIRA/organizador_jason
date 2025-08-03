#!/bin/bash

# Script para criar a estrutura do projeto Payment Gateway Organizer
# Uso: ./create_payment_gateway_structure.sh [nome_do_diretorio]

# Define o nome do diretório do projeto
PROJECT_NAME=${1:-"payment_gateway_organizer"}

echo "Criando estrutura do projeto: $PROJECT_NAME"

# Criar diretório principal
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Criar estrutura de diretórios
mkdir -p app/{models,services,utils,config}

echo "Estrutura de diretórios criada:"
echo "📁 $PROJECT_NAME/"
echo "└── 📁 app/"
echo "    ├── 📁 models/"
echo "    ├── 📁 services/"
echo "    ├── 📁 utils/"
echo "    └── 📁 config/"

# Criar arquivo principal
cat > app/main.py << 'EOF'
"""
Payment Gateway Organizer - Aplicação Principal
"""

import logging
from pathlib import Path
from typing import Optional

from services.detector import PaymentGatewayDetector
from services.extractor import GatewayDataExtractor
from services.processor import JSONProcessor
from services.excel_generator import ExcelGenerator
from models.gateway import GatewayInfo
from utils.logger import setup_logger
from config.settings import AppConfig

# Configurar logger
logger = setup_logger(__name__)


class PaymentGatewayOrganizer:
    """Classe principal que coordena todo o processo"""
    
    def __init__(self, keywords: Optional[list] = None):
        self.detector = PaymentGatewayDetector(keywords)
        self.extractor = GatewayDataExtractor()
        self.processor = JSONProcessor(self.detector, self.extractor)
        self.excel_generator = ExcelGenerator()
        self.results = []
    
    def process_file(self, file_path):
        """Processa um arquivo JSON específico"""
        file_path = Path(file_path)
        
        if not file_path.exists():
            logger.error(f"Arquivo não encontrado: {file_path}")
            return False
        
        gateways = self.processor.process_file(file_path)
        self.results.extend(gateways)
        return True
    
    def process_directory(self, directory_path):
        """Processa todos os arquivos JSON em um diretório"""
        directory = Path(directory_path)
        
        if not directory.exists():
            logger.error(f"Diretório não encontrado: {directory}")
            return False
        
        json_files = list(directory.glob('*.json'))
        
        if not json_files:
            logger.warning("Nenhum arquivo JSON encontrado no diretório!")
            return False
        
        logger.info(f"Encontrados {len(json_files)} arquivos JSON")
        
        processed = 0
        for json_file in json_files:
            if self.process_file(json_file):
                processed += 1
        
        logger.info(f"Processados: {processed}/{len(json_files)} arquivos")
        return processed > 0
    
    def generate_excel(self, output_file: str = 'gateways_pagamento.xlsx'):
        """Gera arquivo Excel com os resultados"""
        if not self.results:
            logger.warning("Nenhum resultado para gerar Excel!")
            return False
        
        self.excel_generator.generate_excel(self.results, output_file)
        return True
    
    def clear_results(self):
        """Limpa os resultados acumulados"""
        self.results.clear()
        logger.info("Resultados limpos")


class CLIInterface:
    """Interface de linha de comando"""
    
    def __init__(self):
        self.organizer = PaymentGatewayOrganizer()
    
    def run(self):
        """Executa a interface de linha de comando"""
        logger.info("=== ORGANIZADOR DE GATEWAYS DE PAGAMENTO ===")
        logger.info("Este programa processa arquivos JSON e extrai informações de gateways de pagamento")
        
        while True:
            self._show_menu()
            choice = input("\nDigite sua escolha (1-3): ").strip()
            
            if choice == '1':
                self._process_single_file()
            elif choice == '2':
                self._process_directory()
            elif choice == '3':
                logger.info("Saindo...")
                break
            else:
                logger.warning("Opção inválida!")
            
            print("\n" + "-"*50 + "\n")
    
    def _show_menu(self):
        """Exibe o menu de opções"""
        print("\nEscolha uma opção:")
        print("1. Processar um arquivo JSON específico")
        print("2. Processar todos os arquivos JSON de uma pasta")
        print("3. Sair")
    
    def _process_single_file(self):
        """Processa um arquivo específico"""
        file_path = input("Digite o caminho do arquivo JSON: ").strip()
        
        if self.organizer.process_file(file_path):
            self._generate_excel_if_results()
        
        self.organizer.clear_results()
    
    def _process_directory(self):
        """Processa um diretório"""
        directory_path = input("Digite o caminho da pasta com arquivos JSON: ").strip()
        
        if self.organizer.process_directory(directory_path):
            self._generate_excel_if_results()
        
        self.organizer.clear_results()
    
    def _generate_excel_if_results(self):
        """Gera Excel se houver resultados"""
        if self.organizer.results:
            output_file = input("Nome do arquivo Excel (Enter para 'gateways_pagamento.xlsx'): ").strip()
            if not output_file:
                output_file = 'gateways_pagamento.xlsx'
            self.organizer.generate_excel(output_file)
        else:
            logger.warning("Nenhum gateway encontrado!")


def main():
    """Função principal"""
    cli = CLIInterface()
    cli.run()


if __name__ == "__main__":
    main()
EOF

# Criar models/__init__.py
cat > app/models/__init__.py << 'EOF'
"""
Modelos de dados da aplicação
"""

from .gateway import GatewayInfo

__all__ = ['GatewayInfo']
EOF

# Criar models/gateway.py
cat > app/models/gateway.py << 'EOF'
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
EOF

# Criar services/__init__.py
cat > app/services/__init__.py << 'EOF'
"""
Serviços da aplicação
"""

from .detector import PaymentGatewayDetector
from .extractor import GatewayDataExtractor
from .processor import JSONProcessor
from .excel_generator import ExcelGenerator

__all__ = [
    'PaymentGatewayDetector',
    'GatewayDataExtractor', 
    'JSONProcessor',
    'ExcelGenerator'
]
EOF

# Criar services/detector.py
cat > app/services/detector.py << 'EOF'
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
EOF

# Criar services/extractor.py
cat > app/services/extractor.py << 'EOF'
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
EOF

# Criar services/processor.py
cat > app/services/processor.py << 'EOF'
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
EOF

# Criar services/excel_generator.py
cat > app/services/excel_generator.py << 'EOF'
"""
Serviço para gerar relatórios Excel
"""

import logging
from typing import List

import pandas as pd

from models.gateway import GatewayInfo
from config.settings import AppConfig

logger = logging.getLogger(__name__)


class ExcelGenerator:
    """Responsável por gerar relatórios Excel"""
    
    def __init__(self, max_column_width: int = None):
        self.max_column_width = max_column_width or AppConfig.MAX_COLUMN_WIDTH
    
    def generate_excel(self, gateways: List[GatewayInfo], output_file: str = 'gateways_pagamento.xlsx') -> None:
        """Gera arquivo Excel com os resultados"""
        if not gateways:
            logger.warning("Nenhum gateway encontrado para gerar Excel!")
            return
        
        # Preparar dados para o DataFrame
        excel_data = [gateway.to_dict() for gateway in gateways]
        df = pd.DataFrame(excel_data)
        
        # Gerar Excel
        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='Gateways', index=False)
            self._adjust_column_widths(writer.sheets['Gateways'])
        
        logger.info(f"Arquivo Excel gerado: {output_file}")
        self._log_summary(gateways)
    
    def _adjust_column_widths(self, worksheet) -> None:
        """Ajusta largura das colunas"""
        for column in worksheet.columns:
            max_length = 0
            column_letter = column[0].column_letter
            
            for cell in column:
                try:
                    cell_length = len(str(cell.value))
                    if cell_length > max_length:
                        max_length = cell_length
                except:
                    pass
            
            adjusted_width = min(max_length + 2, self.max_column_width)
            worksheet.column_dimensions[column_letter].width = adjusted_width
    
    def _log_summary(self, gateways: List[GatewayInfo]) -> None:
        """Registra resumo dos gateways encontrados"""
        sites_count = len(set(g.site for g in gateways))
        logger.info(f"Sites processados: {sites_count}")
        logger.info(f"Total de gateways: {len(gateways)}")
        
        # Agrupar por site
        sites_gateways = {}
        for gateway in gateways:
            site = gateway.site
            if site not in sites_gateways:
                sites_gateways[site] = []
            sites_gateways[site].append(gateway.gateway_name)
        
        for site, gateway_names in sites_gateways.items():
            logger.info(f"{site}: {', '.join(gateway_names)}")
EOF

# Criar config/__init__.py
cat > app/config/__init__.py << 'EOF'
"""
Configurações da aplicação
"""

from .settings import AppConfig

__all__ = ['AppConfig']
EOF

# Criar config/settings.py
cat > app/config/settings.py << 'EOF'
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
EOF

# Criar utils/__init__.py
cat > app/utils/__init__.py << 'EOF'
"""
Utilitários da aplicação
"""

from .logger import setup_logger

__all__ = ['setup_logger']
EOF

# Criar utils/logger.py
cat > app/utils/logger.py << 'EOF'
"""
Configuração de logging
"""

import logging
from config.settings import AppConfig


def setup_logger(name: str) -> logging.Logger:
    """Configura e retorna um logger"""
    logging.basicConfig(
        level=getattr(logging, AppConfig.LOG_LEVEL),
        format=AppConfig.LOG_FORMAT
    )
    return logging.getLogger(name)
EOF

# Criar requirements.txt
cat > requirements.txt << 'EOF'
pandas>=1.3.0
openpyxl>=3.0.0
EOF

# Criar README.md
cat > README.md << 'EOF'
# Payment Gateway Organizer

Aplicação para processar arquivos JSON e extrair informações de gateways de pagamento, gerando relatórios Excel organizados.

## Estrutura do Projeto

```
payment_gateway_organizer/
├── app/
│   ├── main.py                 # Aplicação principal
│   ├── models/
│   │   ├── __init__.py
│   │   └── gateway.py          # Modelo de dados
│   ├── services/
│   │   ├── __init__.py
│   │   ├── detector.py         # Detector de gateways
│   │   ├── extractor.py        # Extrator de dados
│   │   ├── processor.py        # Processador JSON
│   │   └── excel_generator.py  # Gerador Excel
│   ├── utils/
│   │   ├── __init__.py
│   │   └── logger.py           # Configuração logging
│   └── config/
│       ├── __init__.py
│       └── settings.py         # Configurações
├── requirements.txt
└── README.md
```

## Instalação

1. Instale as dependências:
```bash
pip install -r requirements.txt
```

## Uso

1. Execute a aplicação:
```bash
cd app
python main.py
```

2. Escolha uma opção do menu:
   - Processar um arquivo JSON específico
   - Processar todos os arquivos JSON de uma pasta
   - Sair

## Funcionalidades

- Detecta gateways de pagamento em arquivos JSON
- Extrai informações como URL, Client ID, Client Secret, etc.
- Gera relatórios Excel organizados
- Interface de linha de comando intuitiva
- Logging detalhado das operações

## Dependências

- pandas: Para manipulação de dados e geração Excel
- openpyxl: Para criação de arquivos Excel
EOF

# Tornar o script executável
chmod +x create_payment_gateway_structure.sh 2>/dev/null || true

echo ""
echo "✅ Estrutura do projeto criada com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "1. cd $PROJECT_NAME"
echo "2. pip install -r requirements.txt"
echo "3. cd app && python main.py"
echo ""
echo "📁 Arquivos criados:"
find . -type f -name "*.py" -o -name "*.txt" -o -name "*.md" | sort
echo ""
echo "🎉 Projeto pronto para uso!"
