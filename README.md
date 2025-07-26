# 🖥️ Windows Activation Script

---

Este projeto é um serviço de ativação automatizada do Windows, desenvolvido em PowerShell e integrado a um banco de dados MySQL. Ele foi criado para facilitar o processo de ativação de forma segura, eficiente e sem intervenção manual.

---

# 🚀 Funcionalidades

🔑 Requisição automática de chave de ativação via banco de dados

⚙️ Instalação, validação e ativação da chave diretamente nos servidores da Microsoft

🔄 Atualização automática do status da chave no banco de dados

🧹 Restauração de configurações padrão do Windows após execução

🔒 Autoapagamento do script após ativação para segurança

---

# 🛠️ Tecnologias Utilizadas
PowerShell – Script nativo do Windows, ideal para automação

MySQL – Gerenciamento e controle das chaves de ativação

Windows – Ambiente-alvo para aplicação e validação das licenças

---

# 📦 Estrutura do Banco de Dados
Coluna	Descrição
idkey	ID único para cada chave no banco
keycontent	Chave de ativação do Windows
serialcontent	Número serial da máquina ativada
keystate	Status da chave (0 = disponível, 1 = em uso, 2 = bloqueada, 3 = ativada com sucesso)
bancada	Usuário (bancada) que utilizou a chave
disco	Informação auxiliar sobre o disco da máquina
memória	Informação auxiliar sobre a memória da máquina

---

# 🔄 Funcionamento do Script
1. Desbloqueio do PowerShell: Altera a política de execução (ExecutionPolicy) para Bypass.

2. Requisição da Chave: Consulta o banco de dados para obter uma chave com keystate = 0.

3. Instalação da Chave: Usa comandos nativos do Windows para instalar a chave.

4. Ativação: Valida a chave com os servidores da Microsoft.

5. Atualização no Banco: O script registra o status da ativação (sucesso ou falha) no banco de dados.

6. Auto Limpeza: Retorna a política original do sistema e se auto remove.

---

# 🔐 Status das Chaves
Status	Significado
0	Chave disponível para uso
1	Chave em uso (processo de ativação em andamento)
2	Chave bloqueada ou inválida
3	Chave utilizada com sucesso

---

# 📊 Exemplo de Ciclo de Ativação

🧱 Criação da Imagem com Macrium

A imagem da máquina é criada com o script embutido e configurado para iniciar automaticamente no primeiro boot.

🔁 Inicialização da Máquina

O sistema é iniciado automáticamente após a instalação da imagem.

⚙️ Execução do Script

O script de ativação é disparado automaticamente.

🔑 Requisição de Chave

O script consulta o banco de dados e requisita a primeira chave disponível (keystate = 0).

📥 Instalação e Validação

A chave é instalada na máquina e validada nos servidores da Microsoft.

✅ Ativação Bem-sucedida

A chave tem seu status alterado para 3.

O serial da máquina é salvo no banco (serialcontent preenchido, quantidade de memória RAM e espaço em Disco).

❌ Ativação Mal-sucedida

A chave tem seu status alterado para 2 (bloqueada ou inválida).

Nenhum serial é salvo.

🔄 Loop de Retentativa

O script repete o processo até uma chave válida ser aplicada com sucesso e a máquina é desligada de forma automática.

---

# 🧩 Considerações Finais
Este projeto foi idealizado com foco em:

Compatibilidade com o Windows

Segurança e confiabilidade no processo de ativação

Automação completa para ambientes que requerem múltiplas ativações (ex: laboratórios, VMs)
