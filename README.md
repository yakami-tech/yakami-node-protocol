# 📡 YAKAMI-NODE: Protocolo DePIN & Autenticação Criptográfica de Hardware

> **Módulo de Identidade e Segurança Descentralizada da Camada YAKAMI-NET**  
> *Autenticação de nós IoT físicos, prevenção de fraude em campo e governança de operadores na Amazônia Legal.*

---

## 📌 Visão Geral

O **YAKAMI-Node** é a infraestrutura de rede física descentralizada (**DePIN**) do ecossistema **YAKAMI Tech**. Desenvolvido por Walter Filho (Residência TIC 29 – Web3 Blockchain), o protocolo resolve o desafio crítico de autenticação de hardware em redes IoT remotas, garantindo que os dados coletados por nós em campo (*YAKAMI-FLOW*) e validados via órbita (*YAKAMI-SAT*) sejam provenientes exclusivamente de sensores autorizados e imutáveis.

---

## 🛠️ Arquitetura dos Contratos Inteligentes (Sepolia Testnet)

O ecossistema é composto por quatro contratos principais integrados em Solidity (`^0.8.20`):

1. **`YakEnergy` (ERC-20):** Token utilitário (`YAK`) para incentivos econômicos e recompensas de operadores de nós de campo.
2. **`YakDevice` (ERC-721):** Identidade digital de hardware baseada em **Hash PUF (*Physically Unclonable Function*)**, vinculando o chip físico a um NFT exclusivo.
3. **`YakamiNodeStaking` (Staking & Slashing):** Mecanismo de garantia econômica com penalidade de corte (*slashing* de 20%) e queima de tokens em caso de comportamento malicioso ou fraude de dados.
4. **`YakamiHardwareDAO` (Governança Técnica):** Mecanismo de votação descentralizada exclusivo para operadores detentores de dispositivos de hardware.

---

## 🚀 Como Executar e Testar (Sepolia Testnet)

1. **Deploy dos Contratos na Ordem Correta:**
   * `YakEnergy` ➔ `YakDevice` ➔ `YakamiNodeStaking` (passando os endereços dos dois anteriores) ➔ `YakamiHardwareDAO`.
2. **Mint de Identidade de Hardware:** Execute `mintDevice(address to, string memory pufHash)` para registrar o chip PUF do nó físico.
3. **Staking de Operador:** Realize o `stake(uint256 amount)` utilizando tokens `YAK`.
4. **Vinculação de Dispositivo:** Execute `registerDevice(uint256 deviceId, address operator)` para associar o NFT de hardware ao staking ativo.
5. **Governança:** Utilize a DAO para submeter e votar propostas operacionais (`createProposal` / `vote`).

---

## 🛰️ Integração no Ecossistema Ciberfísico (SAT — FLOW — NET)

```text
  [ Hardware de Campo (PUF Chip) ] ──> [ YakDevice (NFT ERC-721) ]
                                                │
                                                ▼
  [ YAKAMI-NET (Blockchain) ] <─── [ YakamiNodeStaking (Slashing / Prova) ]
🏢 Sobre a YAKAMI Tech
A YAKAMI Tech é uma startup Deep Tech sediada em Manaus/AM, dedicada a infraestruturas ciberfísicas, soberania de dados e tecnologias aeroespaciais para a Amazônia.

🌐 Site Oficial: www.yakami.com.br

✉️ E-mail Institucional: contato@yakami.com.br

💼 LinkedIn: YAKAMI Tech no LinkedIn

📄 Propriedade Intelectual & Licença
Este repositório contém código de pesquisa e desenvolvimento institucional protegido por Propriedade Intelectual Exclusiva da YAKAMI Tech Ltda.

Consulte o arquivo LICENSE para termos de uso e conformidade institucional.
