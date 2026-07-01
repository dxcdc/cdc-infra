# CDC Infraestrutura (Monorepo)

Este repositório centraliza todas as receitas de implantação, configurações de contêineres e documentações de infraestrutura do **Centro de Desenvolvimento e Cidadania (CDC)**.

---

## 📁 Estrutura do Repositório

```text
cdc-infra/
├── moodle/              # Configurações do LMS Moodle 5.0
│   ├── Dockerfile       # Compilação do PHP, extensões e dependências
│   └── ajuda.md         # Guia de implantação, volumes e variáveis de ambiente
└── README.md            # Índice de serviços e guia geral
```

---

## 🐳 Serviços Ativos

### 1. Moodle EAD (`/moodle`)
* **Descrição:** Plataforma de ensino online institucional.
* **Dockerfile:** Baseado em PHP 8.3 Apache com extensões `gd`, `intl`, `mysqli`, `zip`, `soap`, `opcache`, `exif`. Instala automaticamente o tema customizado **CDC Moodle** e o plugin **Custom Certificate**.
* **Implantação no Easypanel:**
  * **Build Source:** Git Repository
  * **Git Repository:** URL deste repositório
  * **Root Directory:** `moodle`
  * **Dockerfile Path:** `Dockerfile`

---

## 🔒 Boas Práticas e GitOps
1. **Segurança de Credenciais:** Nunca salve senhas, tokens ou chaves em texto plano dentro deste repositório. Utilize sempre variáveis de ambiente (`getenv()` / aba *Environment* do Easypanel).
2. **Histórico de Alterações:** Toda alteração de limite de memória, novos plugins ou configurações de Apache deve ser feita editando os arquivos deste repositório e enviando via `git commit`/`git push`.
