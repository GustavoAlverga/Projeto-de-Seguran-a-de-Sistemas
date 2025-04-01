#!/bin/bash

# Nomes dos diretórios (baseado no seu ls)
NODE_DIR="node-api"
REACT_DIR="react-app"

# Função para verificar e iniciar um projeto
start_project() {
  local dir=$1
  local cmd=$2
  local name=$3
  local port=$4

  echo "Tentando iniciar $name em $dir..."
  if [ -d "$dir" ]; then
    echo "Diretório encontrado: $dir"
    cd "$dir" || { echo "Falha ao acessar $dir"; return 1; }
    
    if [ -f "package.json" ]; then
      echo "package.json encontrado. Executando $cmd..."
      $cmd &
      pid=$!
      echo "$pid" > "../${name}_pid.txt"
      cd ..
      echo "$name iniciado com PID $pid"
      return 0
    else
      echo "ERRO: package.json não encontrado em $dir"
      cd ..
      return 1
    fi
  else
    echo "ERRO: Diretório $dir não encontrado"
    return 1
  fi
}

# Função de limpeza
cleanup() {
  echo -e "\nEncerrando processos..."
  kill $(cat "${NODE_DIR}_pid.txt" 2>/dev/null) 2>/dev/null
  kill $(cat "${REACT_DIR}_pid.txt" 2>/dev/null) 2>/dev/null
  rm -f "${NODE_DIR}_pid.txt" "${REACT_DIR}_pid.txt" 2>/dev/null
  exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Iniciar Node.js
start_project "$NODE_DIR" "npm start" "Node.js API" "3001"
node_success=$?

# Iniciar React
start_project "$REACT_DIR" "npm run dev" "React App" "3000"
react_success=$?

# Mostrar mensagem se ambos iniciaram com sucesso
if [ $node_success -eq 0 ] && [ $react_success -eq 0 ]; then
  echo "---------------------------------------------"
  echo "Serviços iniciados com sucesso:"
  echo "• Node.js API: http://localhost:3001/status"
  echo "• React App: http://localhost:3000"
  echo "---------------------------------------------"
  echo "Pressione Ctrl+C para parar os serviços"
  
  # Manter script rodando
  while true; do sleep 1; done
else
  echo "---------------------------------------------"
  echo "Falha ao iniciar os serviços:"
  [ $node_success -ne 0 ] && echo "× Node.js API falhou ao iniciar"
  [ $react_success -ne 0 ] && echo "× React App falhou ao iniciar"
  echo "---------------------------------------------"
  cleanup
fi
