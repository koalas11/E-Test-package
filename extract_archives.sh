#!/bin/bash

# Usage: ./extract_archives.sh [all|dataset|results|plotdata|github|no_results]
# Default is 'all'

RESULTS_DIR="AutonomicTester/experiment_results"
EXTRACT_TARGET="${1:-all}"
ARCHIVES_DIR="Archives"

extract_dataset() {
    if [ -d "PromptDataset" ]; then
        echo "Dataset already extracted. Skipping."
        return
    fi
    echo "Extracting dataset ..."
    cd "${ARCHIVES_DIR}/dataset"
    for file in *.tar.gz; do
        tar -xzf "$file" -C ../../
    done
    cd - > /dev/null
}

extract_results() {
    if [ -d "$RESULTS_DIR" ] && [ "$(ls -A $RESULTS_DIR 2>/dev/null)" ]; then
        echo "Results already extracted. Skipping."
        return
    fi
    echo "Extracting results ..."
    cd "${ARCHIVES_DIR}/results"
    for result_folder in *; do
        if [ -d "$result_folder" ]; then
            for file in "${result_folder}"/*.tar.gz; do
                echo "Extracting $file ..."
                mkdir -p "../../${RESULTS_DIR}/${result_folder}"
                tar -xzf "$file" -C "../../${RESULTS_DIR}/${result_folder}"
            done
        fi
    done
    cd - > /dev/null
}

extract_plotdata() {
    if [ -d "DataAnalysis/images" ] && [ -f "DataAnalysis/plotdata.tar.gz" ] && [ "$(ls -A DataAnalysis/images 2>/dev/null)" ]; then
        echo "Plot data already extracted. Skipping."
        return
    fi
    echo "Extracting plot data ..."
    cd "DataAnalysis"
    mkdir -p "images"
    tar -xzf "plotdata.tar.gz"
    cd - > /dev/null
}

# Extract GitHub repos and Llama tokenizer
extract_github() {
    if [ -d "DataAnalysis/GitHubRepos" ] || [ -f "DataAnalysis/GitHubRepos.tar.gz" ]; then
        echo "GitHub repos already extracted. Skipping."
        return
    fi
    echo "Extracting GitHub repos ..."
    GITHUB_REPOS_DIR="DataAnalysis"
    mkdir -p $GITHUB_REPOS_DIR
    tar -xzf "Archives/GitHubRepos.tar.gz" -C $GITHUB_REPOS_DIR
    tar -xzf "Archives/meta-llama-Llama-3.2-1B.tar.gz" -C .
}

mkdir -p $RESULTS_DIR

case "$EXTRACT_TARGET" in
    all)
        extract_dataset
        extract_results
        extract_plotdata
        extract_github
        ;;
    dataset)
        extract_dataset
        ;;
    results)
        extract_results
        ;;
    plotdata)
        extract_plotdata
        ;;
    github)
        extract_github
        ;;
    no_results)
        extract_dataset
        extract_plotdata
        extract_github
        ;;
    *)
        echo "Unknown extraction target: $EXTRACT_TARGET"
        echo "Usage: $0 [all|dataset|results|plotdata|github|no_results]"
        exit 1
        ;;
esac
