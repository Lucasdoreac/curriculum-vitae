#!/bin/bash

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Iniciando atualização do portfólio...${NC}"

# Verifica se está no diretório correto
if [ ! -d ".git" ]; then
    echo -e "${RED}Erro: Execute este script no diretório raiz do repositório${NC}"
    exit 1
fi

# Atualiza branch principal
echo -e "\n${YELLOW}Atualizando branch main...${NC}"
git checkout main
git pull origin main

# Processa arquivos CSS
echo -e "\n${YELLOW}Processando arquivos CSS...${NC}"
if command -v npx &> /dev/null; then
    npx tailwindcss -i ./docs/css/styles.css -o ./docs/css/main.css --minify
else
    echo -e "${RED}Erro: npx não encontrado. Instale o Node.js${NC}"
    exit 1
fi

# Verifica modificações
if [ -n "$(git status --porcelain)" ]; then
    echo -e "\n${YELLOW}Alterações detectadas. Commitando...${NC}"
    git add .
    git commit -m "Atualização automática: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    
    # Atualiza gh-pages
    echo -e "\n${YELLOW}Atualizando branch gh-pages...${NC}"
    git checkout gh-pages
    git merge main
    git push origin gh-pages
    
    # Volta para main
    git checkout main
    
    echo -e "\n${GREEN}Atualização concluída com sucesso!${NC}"
else
    echo -e "\n${GREEN}Nenhuma alteração detectada.${NC}"
fi

# Backups
echo -e "\n${YELLOW}Criando backup...${NC}"
backup_dir="../curriculum-backup/$(date '+%Y%m%d')"
mkdir -p "$backup_dir"
cp -r docs/* "$backup_dir/"
echo -e "${GREEN}Backup criado em $backup_dir${NC}"

echo -e "\n${GREEN}Processo finalizado!${NC}"