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
