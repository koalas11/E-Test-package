# E-Test-package

This artifact contains the environment, code, and data required to fully replicate the results of our ICSE 2026 paper.

### 📄 Paper Details
**[E-Test: E'er-Improving Test Suites](https://conf.researchr.org/details/icse-2026/icse-2026-research-track/84/E-Test-E-er-Improving-Test-Suites)**
*Accepted at the 48th International Conference on Software Engineering (ICSE 2026)*

**Authors:** Ketai Qiu, Luca Di Grazia, Leonardo Mariani, and Mauro Pezzè.

### 🔗 Resources
* **Paper PDF:** [Read here](https://arxiv.org/pdf/2510.19860)
* **Source Code:** [GitHub Repository](https://github.com/ketaiq/E-Test-package)


## Repository Structure
- **AutonomicTester:** A Python application designed to implement advanced techniques for E-TEST.
- **DataAnalysis:** A set of Jupyter notebooks to analyze results and compute evaluation metrics.
- **Archives:** A set of tar archives of datasets of prompts and responses from LLMs.

## Getting Started

### Environment Setup

1. Create a HuggingFace user access token on [https://huggingface.co/docs/hub/security-tokens](https://huggingface.co/docs/hub/security-tokens).

2. Install [Docker](https://docs.docker.com/engine/install/).

3. Run the following commands from the project root directory using a Unix-compatible shell (Bash, Zsh). You can build an image from scratch and then switch to other LLMs by changing *OLLAMA_MODEL* to any LLMs available on [Ollama](https://ollama.com/search).

**Step 1. Prepare the Docker image**
```sh
export HUGGING_FACE_API_KEY="YOUR API KEY"

# Choice 1: Build the image locally depending on the GPU and if you want Ollama in the container
docker build -t e-test-env:1.0-with-ollama-amd -t e-test-env:latest-with-ollama-amd --target with_ollama_amd .
docker build -t e-test-env:1.0-with-ollama-nvidia -t e-test-env:latest-with-ollama-nvidia --target with_ollama_nvidia .
docker build -t e-test-env:1.0-no-ollama -t e-test-env:latest-no-ollama --target no_ollama .


# Choice 2: Pull the pre-built image from Docker Hub
docker pull ketaiq/e-test-env-llama3-1b:v1.0
docker tag ketaiq/e-test-env-llama3-1b:v1.0 e-test-env

# Choice 3: Load the pre-built image for Linux AMD64 platform
docker load -i e-test-env-llama3-1b-amd64.tar
docker tag e-test-env-llama3-1b-amd64 e-test-env
```

**Step 2. Run the Docker container**

With ollama pre-installed:

Linux:
```sh
docker run -it --rm \
  -p 20268:8888 \
  --device /dev/kfd --device /dev/dri \
  -v $(pwd)/experiment_results:/app/AutonomicTester/experiment_results \
  -v $(pwd)/logs:/app/logs \
  -e HUGGING_FACE_API_KEY=$HUGGING_FACE_API_KEY \
  -e OLLAMA_MODEL="llama3.2:1b" \
  e-test-env:1.0-with-ollama-amd
```

If using an NVIDIA GPU, replace `--device /dev/kfd --device /dev/dri` with `--gpus=all`, then install the NVIDIA Container Toolkit and replace `e-test-env:*-with-ollama-amd` with `e-test-env:*-with-ollama-nvidia`.

The image `e-test-env:*-with-ollama-amd` only works in linux if you want to use an AMD GPU.

Windows:
```sh
docker run -it --rm ^
  -p 20268:8888 ^
  --gpus=all ^
  -v "%cd%\experiment_results":/app/AutonomicTester/experiment_results ^
  -v "%cd%\logs":/app/logs ^
  -e HUGGING_FACE_API_KEY=%HUGGING_FACE_API_KEY% ^
  -e OLLAMA_MODEL="llama3.2:1b" ^
  e-test-env:1.0-with-ollama-nvidia
```

Without ollama pre-installed:

Linux/Mac:
```sh
docker run -it --rm \
  -p 20268:8888 \
  -v $(pwd)/experiment_results:/app/AutonomicTester/experiment_results \
  -v $(pwd)/logs:/app/logs \
  -e HUGGING_FACE_API_KEY=$HUGGING_FACE_API_KEY \
  e-test-env:1.0-no-ollama
```

Windows:
```sh
docker run -it --rm ^
  -p 20268:8888 ^
  -v "%cd%\experiment_results":/app/AutonomicTester/experiment_results ^
  -v "%cd%\logs":/app/logs ^
  -e HUGGING_FACE_API_KEY=%HUGGING_FACE_API_KEY% ^
  e-test-env:1.0-no-ollama
```

### Data Analysis
To reproduce evaluation results shown in the paper, please run notebooks in `DataAnalysis` folder.
You can open http://localhost:20268 to run and edit notebooks directly.

- `Dataset Stats.ipynb` and `GH Dataset Stats.ipynb` compute statistics about the dataset, which corresponds to **Section 2.2 Dataset paragraph**, and **Table 1** in the paper.
- `RQ1 Impact of LLMs.ipynb` computes evaluation metrics (precision, recall, and F1-score) for each scenario and the average F1-scores, which corresponds to **Section 3.1**, **Table 3**, **Figure 3** and **Figure 4** in the paper.
- `RQ2 Comparative Evaluation.ipynb` computes evaluation metrics of two state-of-the-art approaches (i.e., *FAST++* and *Field-ready testing*), which corresponds to **Section 3.2** and **Table 3** in the paper.
- `RQ3 Impact of Queries.ipynb` computes evaluation metrics for different combinations of queries, which corresponds to **Section 3.3** and **Figure 5** in the paper.
- `RQ4 Efficiency.ipynb` measures efficiency of E-Test in terms of response time and token consumption, which corresponds to **Section 3.4** and **Figure 6** in the paper.
- `RQ5 Test Case Generation.ipynb` analyzes JUnit test cases generated by E-Test, which corresponds to **Section 3.5** and **Figure 7** in the paper.

### E-Test Program

In the Docker interactive shell, run the following command to launch an experiment
```sh
# Test Llama3 1B with prompts generated from error-prone scenarios in Defects4J
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_2_1B -s BUGGY

# Test Llama3 1B with prompts generated from error-prone scenarios in Defects4J with Test Case Generation On
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_2_1B -s BUGGY -tcg on

# Test Llama3 1B with prompts generated from error-prone scenarios in Defects4J with Test Case Generation On and ollama not present in the container (example with host pc having ollama installed)
python AutonomicTester/main.py prompt -v 4 -d Defects4J -m LLama3_2_1B -s BUGGY -tcg on --host http://host.docker.internal:11434
```

For other settings mentioned in the paper, please check the help message via `python AutonomicTester/main.py -h`.

Run `exit` to stop the Docker container.
