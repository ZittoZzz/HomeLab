# getting ollama 
apt update && apt install -y curl
curl -fsSL https://ollama.com/install.sh | sh

# make it accessible through port 11434
systemctl edit ollama.service
# view ollama.service for the config

# reload service
systemctl daemon-reload
systemctl restart ollama

# pulling a model and running it after
ollama run ollama pull qwen2.5-coder:7b
# more models are browsable through "https://ollama.com/library"