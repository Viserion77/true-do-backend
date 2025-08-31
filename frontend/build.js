#!/usr/bin/env node

import { execSync } from 'node:child_process';
import { existsSync } from 'node:fs';

console.log('🚀 Iniciando build do projeto...');

// Verifica se o arquivo existe
if (!existsSync('./dist.zip')) {
  console.error('❌ Arquivo dist.zip não encontrado!');
  process.exit(1);
}

try {
  console.log('🔨 Extraindo arquivos...');
  execSync('unzip -o ./dist.zip', { stdio: 'inherit' });
  console.log('✅ Build concluído!');
} catch (error) {
  console.error('❌ Erro ao extrair:', error.message);
  process.exit(1);
}
