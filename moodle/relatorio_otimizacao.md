# Relatório de Otimização e Limpeza do Tema Uena

Fizemos uma varredura profunda em todos os diretórios do tema `uena_moodle` para verificar o peso dos arquivos e identificar itens legados da conversão do template HTML original que não estão sendo utilizados pelo Moodle. 

---

## 📊 Resumo da Análise

* **Tamanho Atual do Tema:** **3.6 MB**
* **Arquivos Inúteis Identificados:** **~1.7 MB** (Cerca de **47%** do tamanho total do tema é composto por arquivos mortos).
* **Impacto da Limpeza:** Reduzirá o tamanho do tema para **~1.9 MB**, tornando o pacote muito mais leve para instalação, backup e exportação.

---

## 🔍 Detalhamento dos Arquivos Inutilizados

### 1. Diretórios de Imagens de Demonstração (`pix/`)
O diretório `pix/` contém diversas pastas de imagens que vieram do template HTML de demonstração (fotos de perfil falsas, ícones de criptomoedas, gráficos estáticos). O Moodle gera e carrega essas imagens dinamicamente a partir do banco de dados de usuários e cursos, ou seja, estes arquivos locais nunca são lidos pelo tema.

| Pasta / Arquivo | Tamanho | Descrição / Motivo | Status |
| :--- | :--- | :--- | :--- |
| `pix/svg/` | 316 KB | Vetores de criptomoedas (bitcoin, ethereum, etc.) e ícones demo | 🗑️ **Pode Excluir** |
| `pix/demo/` | 224 KB | Imagens de mockups e banners de demonstração | 🗑️ **Pode Excluir** |
| `pix/profile/` | 152 KB | Fotos de perfil falsas de usuários e capas de teste | 🗑️ **Pode Excluir** |
| `pix/big/` | 96 KB | Imagens grandes de carros e banners para blogs | 🗑️ **Pode Excluir** |
| `pix/card/` | 80 KB | Banners de demonstração para cartões de conteúdo | 🗑️ **Pode Excluir** |
| `pix/product/` | 64 KB | Fotos de pratos de comida/produtos para e-commerce fictício | 🗑️ **Pode Excluir** |
| `pix/avatar/` | 52 KB | Mais avatares genéricos de teste | 🗑️ **Pode Excluir** |
| `pix/iconly/` | 44 KB | Ícones de utilidade que não são mapeados ou usados no Moodle | 🗑️ **Pode Excluir** |
| `pix/table/` | 32 KB | Minhas fotos de perfil de teste para tabelas | 🗑️ **Pode Excluir** |
| `pix/menu/` | 20 KB | Imagens de background para menus flutuantes demo | 🗑️ **Pode Excluir** |
| `pix/background/` | 20 KB | Padrões de fundo estáticos da versão HTML | 🗑️ **Pode Excluir** |
| `pix/contacts/` | 20 KB | Fotos de rostos para lista de contatos demo | 🗑️ **Pode Excluir** |
| `pix/tab/` | 16 KB | Banners para abas de teste | 🗑️ **Pode Excluir** |
| `pix/browser/` | 12 KB | Logos antigos de navegadores (IE, Chrome, etc.) | 🗑️ **Pode Excluir** |
| `pix/map.jpg` | 88 KB | Foto de um mapa estático de localização | 🗑️ **Pode Excluir** |
| Outros arquivos soltos | ~90 KB | Arquivos como `hand.png`, `like.png`, logos antigos de teste duplicados | 🗑️ **Pode Excluir** |

---

### 2. Estilos SCSS não Importados (`scss/`)
O Moodle compila o SCSS dinamicamente lendo a lista de arquivos configurados dentro da função `theme_uena_moodle_get_main_scss_content` em `lib.php`. Os seguintes arquivos dentro de `scss/` não estão listados lá e, portanto, nunca são lidos pelo tema:

- `scss/uena/tables/_table-bootgrid.scss` (Estilos de tabela Bootgrid)
- `scss/uena/tables/_table-footable.scss` (Estilos de tabela FooTable)
- `scss/uena/tables/_table-jsgrid.scss` (Estilos de tabela JSGrid)
- `scss/uena/tables/_table.scss` (Importações genéricas de tabelas demo)

---

## 🛠️ Plano de Ação Recomendado

1. **Limpeza Automatizada:** Remover as pastas e arquivos de imagem listados acima.
2. **Remoção de SCSS Morto:** Excluir os 4 arquivos de tabelas SCSS inutilizados.
3. **Limpeza do Contêiner:** Sincronizar a remoção no ambiente Docker e rodar `purge_caches.php` para validar que nada quebrou e que a compilação continua 100% íntegra (o que irá acontecer, pois estes arquivos já estão desligados).
