# Metodologia de Auditoria — Export Frontend (PDF + Excel)

**Funcionalidade:** `relatorios/02-export-frontend`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ NÃO (100% frontend)

---

## 1. Mapa do sistema

Export de relatórios em PDF e Excel é feito inteiramente pelo frontend React. Watson pode apenas verificar que os dados-fonte (tabela `spent`) estão corretos e acessíveis.

---

## 2. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| EXP-Q1 | Tabela spent acessível e com dados do user de teste |
| EXP-Q2 | Tabela reports: existe? Tem registros de export? |

**🟡 Broad (+2):**

| ID | Verificação |
|----|-------------|
| EXP-B1 | Dados do spent corretos pra gerar relatório (categorias, valores, datas) |
| EXP-B2 | profiles do user tem dados necessários pro header do relatório |

---

## 3. Limitações

Watson não pode testar export de PDF/Excel via frontend. Apenas verifica integridade dos dados-fonte no banco.
