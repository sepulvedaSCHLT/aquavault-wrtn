# AQUAVAULT (WRTN)

AQUAVAULT (WRTN) es un proyecto ecológico basado en Binance Smart Chain (BEP-20) orientado a la **creación y mantenimiento de reservas de agua potable**, utilizando trazabilidad on-chain para aumentar transparencia, facilitar auditoría pública y conectar financiación digital con resultados verificables en el mundo real.

En fases posteriores, el proyecto contempla líneas de innovación como **enfriamiento sostenible** para infraestructura tecnológica (servidores / centros de datos), siempre bajo criterios de viabilidad y sostenibilidad.

---

## ⚙️ Descripción general (alineada al contrato desplegado)

AQUAVAULT (WRTN) busca demostrar que la tokenización puede ir más allá de lo especulativo: **publicar evidencia verificable** y habilitar un puente medible entre fondos digitales y ejecución real.

- **Ticker:** `WRTN`
- **Red:** Binance Smart Chain (BEP-20)
- **Cap de suministro (hard cap):** `200,000,000 WRTN` (18 decimales)
- **Emisión / supply:**
  - El contrato **acuña el cap completo al deploy** a la dirección `owner`.
  - Existe función **`mint()` (solo owner)** pero **no puede superar el cap** (hard cap por código).
  - Existe función **`burn()` (solo owner)** que reduce `totalSupply`.
- **Fee por transferencia (configurable):**
  - Se cobra en basis points (bps).
  - **Tope duro por código:** `MAX_FEE_BPS = 300` → **3.00% máximo**
  - El fee se envía a `feeRecipient`.
  - Hay exenciones configurables: `isFeeExempt`.
- **Límite por wallet (anti-concentración):**
  - Se controla por basis points con `maxWalletBps`.
  - **Tope duro por código:** `HARD_CAP_WALLET_BPS = 3000` → **30.00% máximo**
  - Exenciones configurables: `isMaxWalletExempt`.
- **Pausa / Emergencia:**
  - `pause()` / `unpause()` pueden ser ejecutadas por **`owner` o `emergencyManager`**.
  - Mientras está pausado: **solo `owner` puede mover tokens**.
- **Freeze list (bloqueo selectivo):**
  - `isFrozen[address]` bloquea transferencias desde/hacia direcciones marcadas.
- **Tipo de contrato:** **no upgradeable** (sin proxy). Seguridad basada en límites duros y controles on-chain.

> Nota de precisión: cualquier documento del proyecto debe reflejar estos límites (3% fee máx, 30% wallet máx) y el hecho de que `burn()` y `mint()` están restringidas al owner.

---

## 🔎 Verificación pública

- **Contrato (BscScan):**  
  https://bscscan.com/address/0x668aF355D33662C2E0200eBe947db6241D9a906d

Los parámetros actuales (fee y max wallet) pueden revisarse con las variables públicas:
- `feeBps`, `feeRecipient`
- `maxWalletBps`
- `paused`, `emergencyManager`
- `isFeeExempt`, `isMaxWalletExempt`, `isFrozen`

---

## 📄 Whitepaper

### Versión online
- Sitio oficial: https://tokenaquavault.com  
- Sección Whitepaper: https://tokenaquavault.com/whitepaper/

### Versión descargable (PDF)
- `docs/whitepaper_aquavault_wrtn.pdf` (se recomienda mantener la versión PDF alineada con la versión online).

---

## 🔑 Funcionalidades del contrato (explicación ejecutiva)

### 1) Fee ecológico y financiamiento continuo
El fee por transferencia permite sostener un flujo hacia una billetera operativa (`feeRecipient`).  
Principios:
- El fee tiene **tope duro de 3%** por código.
- El fee puede ser **0** (token estándar sin comisión).
- Exenciones (`isFeeExempt`) permiten no penalizar operaciones técnicas (por ejemplo pools o direcciones internas), siempre con criterios publicados.

**Objetivo del fee:** apoyar una operación de desarrollo y ejecución hídrica **por etapas**, publicando evidencia verificable.

---

### 2) Límite por wallet (anti-concentración)
Para reducir riesgos de concentración excesiva:
- El contrato valida que un receptor no supere `maxWalletAmount()` (cálculo dinámico sobre `totalSupply`).
- Existe tope duro 30% y exenciones controladas (`isMaxWalletExempt`).

**Objetivo:** evitar acumulaciones extremas que puedan comprometer gobernanza social o estabilidad de mercado.

---

### 3) Controles de emergencia: pausa global
En caso de incidentes críticos (ataques, anomalías operativas, vulnerabilidades externas), el contrato permite:
- Pausar transferencias (`pause`) y reanudar (`unpause`) por `owner` o `emergencyManager`.
- Mientras está pausado, el sistema restringe movimientos a `owner` para acciones de contención.

**Objetivo:** capacidad de respuesta sin depender de cambios de código (el contrato no es upgradeable).

---

### 4) Freeze list (bloqueo selectivo)
Permite bloquear direcciones involucradas en incidentes, preservando integridad del ecosistema en escenarios de riesgo.

**Objetivo:** contención selectiva y reducción de propagación de daños durante incidentes.

---

## 📊 Tokenomics (plan de asignación y uso)

Plan referencial sobre cap máximo `200,000,000 WRTN`:

- **50% – Fondo de Reserva de Agua**
  - Proyectos de agua potable, mantenimiento, reposición y operación.
- **20% – Liquidez**
  - Profundidad de mercado y estabilidad inicial cuando se habilite liquidez pública.
- **15% – Marketing & Alianzas**
  - Comunicación, listados, asociaciones y construcción de comunidad.
- **10% – Desarrollo Tecnológico**
  - Web3, monitoreo, automatización de transparencia y líneas futuras (ej. cooling sostenible).
- **5% – Seguridad / Contingencias**
  - Auditorías, respuesta a incidentes, herramientas de monitoreo y costos críticos.

> Transparencia: los movimientos relevantes se documentan por enlaces a transacciones on-chain y reportes publicados en canales oficiales.

---

## 💧 Plan de liquidez (cómo se crea y cómo se protege)

La liquidez no se habilita “por impulso”. Un pool débil genera volatilidad extrema y facilita manipulación.  
El plan se ejecuta por fases:

### Fase A — Preparación
- Definir par principal en DEX (p. ej. WRTN/WBNB).
- Definir política pública de:
  - custodia de LP tokens (bloqueo o custodia verificable),
  - comunicación de enlaces del pool,
  - criterios de exenciones (fee/wallet) para operación técnica.

### Fase B — Provisión inicial
- Crear pool y aportar liquidez inicial (WRTN + BNB) para establecer profundidad.
- Publicar:
  - enlace del pool,
  - transacciones de provisión,
  - reglas de operación (sin promesas financieras).

### Fase C — Estabilización
- Ajustes dentro de límites duros:
  - `feeBps` si corresponde,
  - `maxWalletBps` si corresponde,
  - exenciones estrictamente necesarias (pools / wallets técnicas).
- Reportes periódicos:
  - métricas simples (liquidez, volumen, holders, eventos clave),
  - evidencia pública.

> No se publican llaves privadas ni detalles operativos sensibles. La transparencia se centra en evidencia verificable.

---

## 🌍 Puente Blockchain ↔ Mundo real (ejecución hídrica con evidencia)

AQUAVAULT busca conectar tokenización con resultados verificables, sin exponer datos que comprometan seguridad.

### Metodología por hitos (deliverables)
1. **Selección de iniciativa**
   - Criterios públicos: impacto, viabilidad, mantenimiento, costos y riesgo.
2. **Prefactibilidad**
   - Alcance, cronograma, riesgos y requerimientos.
3. **Ejecución modular**
   - Entregables pequeños y verificables (evitar promesas macro sin evidencia).
4. **Prueba de ejecución**
   - Reportes, registros y evidencia (fotográfica/técnica) + enlaces verificables.
   - Opcional: hashes de documentos para integridad (cuando aplique).
5. **Seguimiento**
   - Mantención, mediciones y publicación periódica.

El objetivo no es “vender humo”: es construir un circuito de financiación con rendición de cuentas y evidencia.

---

## 🏛️ Gobernanza y administración (modelo real del contrato)

**Este contrato no incluye `renounceOwnership()`**, por lo que el modelo de “inmutabilidad por renuncia” debe describirse correctamente:

- Existe `owner` con capacidad de:
  - `setFeeBps` (hasta 3%),
  - `setMaxWalletBps` (hasta 30%),
  - `setFeeRecipient`,
  - configurar exenciones,
  - `mint` (solo hasta el cap; el cap no se puede superar),
  - `burn` (solo owner),
  - `setEmergencyManager`,
  - `pause/unpause` (también emergencyManager),
  - freeze list.

### Enfoque recomendado de gobernanza (sin prometer funciones inexistentes)
- Mantener límites duros como barrera principal (3% fee máx; 30% wallet máx; cap 200M).
- Publicar política de uso de funciones administrativas:
  - cuándo se ajustan parámetros,
  - qué eventos se reportan,
  - cómo se valida públicamente.
- Progresar hacia un esquema operativo más robusto (por ejemplo multisig del owner / del emergencyManager) si se considera necesario en etapas posteriores.

---

## 🧭 Roadmap (alto nivel, ejecutable por etapas)

- **Fase 1 — Base técnica y transparencia**
  - Contrato verificado, web, whitepaper, tokenomics, canales oficiales.
- **Fase 2 — Preparación de liquidez**
  - Pool, políticas públicas, evidencia de provisión, métricas y reportes.
- **Fase 3 — Ejecución hídrica por hitos**
  - Primeras iniciativas con evidencia verificable y reporte público.
- **Fase 4 — Escalamiento**
  - Automatización de reportes, expansión de iniciativas, innovación en cooling sostenible.

---

## ⚠️ Riesgos y límites

- **Riesgo de mercado:** volatilidad inherente; no se garantizan retornos.
- **Riesgo operativo:** ejecución real requiere proveedores, permisos y logística.
- **Riesgo de seguridad:** mitigado con pausa, freeze list y controles; no elimina riesgos externos.
- **Riesgo reputacional:** se gestiona con evidencia verificable, comunicación responsable y reportes.

---

## 📌 Aviso

Este documento es informativo y no constituye asesoría financiera ni una oferta de inversión.  
Toda decisión debe basarse en verificación independiente y en la evidencia pública disponible (on-chain y canales oficiales).

---

## 📁 Estructura sugerida del repositorio

```text
.
├── assets/                         # Logotipos e imágenes del proyecto
├── contracts/
│   └── AquaVaultToken.sol          # Implementación principal (alineada a BscScan)
├── docs/
│   ├── whitepaper_aquavault_wrtn.md
│   └── whitepaper_aquavault_wrtn.pdf
└── README.md
