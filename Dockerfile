FROM ubuntu:26.04 AS base

ARG DEFECTS4J_COMMIT=8022adcd685ae8f591f0cb5d71282e5c93798e4d

# Set environment variables to prevent Python from buffering stdout
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set timezone for defects4j
ENV TZ=America/Los_Angeles

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash curl git unzip \
        subversion perl build-essential cpanminus \
        openjdk-11-jre-headless \
        python3.13 python3.13-venv python3-pip && \
    ln -sf /usr/bin/python3.13 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/rjust/defects4j.git defects4j && \
    cd defects4j && \
    git checkout $DEFECTS4J_COMMIT

WORKDIR /defects4j
RUN cpanm --installdeps . && \
    chmod +x ./init.sh && \
    ./init.sh && \
    cd project_repos && \
    rm -rf defects4j-repos-v3.zip

WORKDIR /app
# Create a Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV

# Update PATH so we use the venv and defects4j by default
ENV PATH="/defects4j/framework/bin:$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Setup the entrypoint script
COPY entrypoint.sh /entrypoint.sh
COPY extract_archives.sh .
RUN chmod +x extract_archives.sh && \
    chmod +x /entrypoint.sh

COPY AutonomicTester AutonomicTester
COPY DataAnalysis DataAnalysis

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

FROM ollama/ollama:0.13.5-rocm AS ollama_amd
FROM ollama/ollama:0.13.5 AS ollama_nvidia

# --- Ollama Layer ---
FROM base AS base_with_ollama_amd
# Arguments
# You can override this with -e OLLAMA_MODEL="..." in docker run
ENV OLLAMA_MODEL="llama3.2:1b"
COPY --from=ollama_amd /usr/bin/ollama /usr/bin/ollama
COPY --from=ollama_amd /usr/lib/ollama /usr/lib/ollama

FROM base AS base_with_ollama_nvidia
# Arguments
# You can override this with -e OLLAMA_MODEL="..." in docker run
ENV OLLAMA_MODEL="llama3.2:1b"
COPY --from=ollama_nvidia /usr/bin/ollama /usr/bin/ollama
COPY --from=ollama_nvidia /usr/lib/ollama /usr/lib/ollama

# --- No Ollama ---
FROM base AS no_ollama
WORKDIR /app
COPY Archives Archives
ENV EXTRACT_TARGET="all"

# --- With Ollama ---
FROM base_with_ollama_amd AS with_ollama_amd
WORKDIR /app
COPY Archives Archives
ENV EXTRACT_TARGET="all"

FROM base_with_ollama_nvidia AS with_ollama_nvidia
WORKDIR /app
COPY Archives Archives
ENV EXTRACT_TARGET="all"
