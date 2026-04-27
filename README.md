# 📡 YAKAMI-Node: Protocolo de Autenticação para Hardware DePIN

**Autor:** Walter Filho  
**Curso:** Residência TIC 29 – Web3 Blockchain  
**Rede:** Sepolia Testnet  

## 📌 Visão Geral

YAKAMI-Node é a camada de infraestrutura descentralizada (DePIN) do ecossistema Yakami Tech. O protocolo resolve o problema de autenticação de hardware em redes IoT na Amazônia, garantindo que dados ambientais sejam provenientes de sensores físicos autorizados.

## 🎯 Componentes do Protocolo

| Contrato | Função | Endereço (Sepolia) |
|----------|--------|--------------------|
| **YakEnergy (ERC-20)** | Token de utilidade para recompensas | `0xd9145CCE52D386f254917e481eB44e9943F39138` |
| **YakDevice (ERC-721)** | NFT – Identidade digital do hardware | `0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8` |
| **YakamiNodeStaking** | Staking com slashing (corte de 20%) | `0xf8e81D47203A594245E36C48e151709F0C19fBe8` |
| **YakamiHardwareDAO** | Governança técnica para operadores | `0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B` |

## 🔧 Funcionalidades

- ✅ NFT YAK-Device – Identidade única para cada hardware
- ✅ Staking com slashing – Garantia econômica de honestidade
- ✅ DAO técnica – Governança exclusiva para operadores
- ✅ Oráculo Chainlink – Verificação de conectividade

## 🚀 Como testar

1. Faça deploy dos contratos na Sepolia (ordem: YakEnergy → YakDevice → Staking → DAO)
2. Execute `mintDevice()` para criar identidade do hardware
3. Execute `stake(100000000000000000000)` para travar tokens
4. Execute `registerDevice(0, sua_carteira)` para vincular NFT ao stake
5. Execute `createProposal()` para criar proposta de governança

## 📊 Links

- [Relatório técnico (PDF)](U1C5O1T1_Walter_Filho.pdf)
- [Explorer – YakEnergy](https://sepolia.etherscan.io/address/0xd9145CCE52D386f254917e481eB44e9943F39138)
- [Explorer – YakDevice](https://sepolia.etherscan.io/address/0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8)

---
**YAKAMI TECH – Conectando a floresta à blockchain**
