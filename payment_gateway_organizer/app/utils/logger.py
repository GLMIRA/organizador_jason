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
