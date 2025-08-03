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
