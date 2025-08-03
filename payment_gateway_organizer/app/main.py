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
