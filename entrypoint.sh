#!/bin/bash

model=${OLLAMA_MODEL}
EXTRACT_TARGET="${1:-all}"

bash /app/extract_archives.sh "$EXTRACT_TARGET"

mkdir -p /app/logs

# Start Ollama in the background only if installed
if command -v ollama >/dev/null 2>&1; then
    echo "Starting Ollama server..."
    nohup ollama serve > /app/logs/ollama.log 2>&1 &

    # Wait for the Ollama server to wake up
    echo "Waiting for Ollama to be ready..."
    until curl -s http://localhost:11434/api/version > /dev/null; do
        sleep 2
        echo "..."
    done

    # Pull the LLM
    # This checks if the model exists to save time on restarts if using volumes
    if ! ollama list | grep -q "$model"; then
        echo "Pulling $model model (this may take a while)..."
        ollama pull "$model"
    else
        echo "$model model already present."
    fi
else
    echo "Ollama is not installed. Skipping Ollama startup, you will need to specify your ollama host."
fi

# Activate the virtual environment explicitly (safety measure)
source /opt/venv/bin/activate

# Launch Jupyter Lab
nohup jupyter lab --notebook-dir=/app/DataAnalysis --ip=0.0.0.0 --allow-root \
    --no-browser --NotebookApp.token='' > /app/logs/jupyter.log 2>&1 &

# Print the Access Info
echo "-----------------------------------------------------"
echo "Jupyter is running at: http://localhost:20268/lab"
echo "-----------------------------------------------------"

# Execute the command passed to the docker container
exec "$@"
