# Autonomic Tester

Steps to run experiments

### Step 1: Install and Start Ollama

For Linux
```sh
# Install Ollama
sudo curl -L https://github.com/ollama/ollama/releases/download/v0.1.48/ollama-linux-amd64 -o /usr/bin/ollama
sudo chmod +x /usr/bin/ollama
# Start Ollama Server
nohup ollama serve > ollma.log 2>&1 &
# Pull Llama3 8B model
ollama pull llama3:8b
```

For macOS, please download Ollama directly from https://ollama.com/ and start it from Launchpad.

### Step 2: Prompt Llama3 8B
Before prompting, please export your [Hugging Face](https://huggingface.co/) user access token as an environment variable
```sh
export HUGGING_FACE_API_KEY={YOUR_USER_ACCESS_TOKEN}
```

```sh
# Test Llama3 8B with prompts generated from error-prone scenarios in Defects4J
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_8B -s BUGGY
# Test Llama3 8B with prompts generated from safe-not-yet-tested scenarios in Defects4J
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_8B -s FIXED
# Test Llama3 8B with prompts generated from already-tested scenarios in Defects4J
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_8B -s SIMILAR

# Test Llama3 8B with prompts generated from error-prone scenarios in the mined dataset from GitHub
python AutonomicTester/main.py prompt -v 4 -d Defects4AT -m LLama3_8B -s BUGGY
# Test Llama3 8B with prompts generated from safe-not-yet-tested scenarios in the mined dataset from GitHub
python AutonomicTester/main.py prompt -v 4 -d Defects4AT -m LLama3_8B -s FIXED
# Test Llama3 8B with prompts generated from already-tested scenarios in the mined dataset from GitHub
python AutonomicTester/main.py prompt -v 4 -d Defects4AT -m LLama3_8B -s SIMILAR
```

### Step 3: Summarize Results
```sh
python AutonomicTester/main.py summarize -v 4 -e {EXPERIMENT_FOLDER_NAME}
```
Replace `EXPERIMENT_FOLDER_NAME` with the one generated in `AutonomicTester/experiment_results`

Check following files in the experiment folder for data analysis:
- `summary.json` contains answers of 5 queries from the LLM for each prompt.
- `scenario_votes.csv` contains the predicted scenario for each prompt. The columns *bug id* and *project* indicate the source of the prompt. The columns *buggy*, *fixed* and *similar* store the vote for each scenario. The column *max* stores the maximum vote.
- `statistics.csv` contains the time costs of the LLM's response and the prompt size in terms of characters and tokens.