# Computational Social Science: Social Media-based Sentiment Analysis

## Project Overview

This repository contains code and data for a computational social science project analyzing social media discussions around school shootings, with a focus on the Parkland event. The project collects, processes, and analyzes data primarily from Reddit and YouTube to study public sentiment, emotion trends, and topic dynamics over time. Analyses include data scraping, cleaning, sentiment/emotion classification, topic modeling, and visualization using both Python and R.

---

## Repository Structure and Main Components

### Data Collection (`data_retrieval/`)

- **youtube_api.py**: Collects YouTube videos and comments related to the Parkland shooting using the YouTube Data API.
- **join_dataset.py**: Merges and deduplicates YouTube datasets for comments and video details.
- **splitdataset.py**: Splits large datasets into smaller parts for easier processing.
- **results_analysis/**: Contains intermediate results, topic trends, and grid search results for topic modeling.
- **youtube_database/**: Stores raw and processed YouTube data (comments and video details).

### Data Processing and Analysis (`src/`)

- **reddit_scraper.py**: Scrapes Reddit posts and comments using the Reddit API, saving them as JSON files.
- **reddit_to_csvV2.py**: Cleans and converts Reddit JSON data to CSV for further analysis.
- **sentiment_analysis.py**: Applies zero-shot emotion classification to text data (using HuggingFace Transformers), saving results in checkpoints and final CSVs.

### Notebooks

- **analysis.ipynb**: Main notebook for YouTube data analysis, including network analysis, comment distribution, and topic modeling.
- **notebook/df.ipynb**: Utility notebook for inspecting and handling NaN values in Reddit data.
- **notebook/to_csv.ipynb**: Used to understand how to set up the data conversion from .json to .csv format.

### R Scripts (`R/`)

- **Analysis.R**: General analysis and visualization of the datasets.
- **Data_Cleaning.R**: Data cleaning routines for the datasets.
- **data_merge.R**: Merges Reddit and YouTube data for unified analysis.
- **external_impact.R**: Statistical analysis of emotion shifts before/after key events.
- **figures_full_data.R**: Generates figures for emotion trends and summary statistics.
- **ts_modeling.R**: Time series modeling of emotion trends.
- **plots/**: Contains generated plots (STL decompositions, bubble plots, etc.).

### Results (`results/`)

- **aggregated/emotions/**: Contains emotion analysis results for both Reddit and YouTube, with checkpoint and final CSVs.
- **aggregated/reddit_cleaned.csv**: Cleaned Reddit data.
- **aggregated/reddit_results.csv**: Processed Reddit results.
- **[subreddit].json**: Raw Reddit data for each subreddit (see also `results/README.md`).

### Data (`data/`)

- **comments_youtube_filtered.csv**: Filtered YouTube comments.
- **final_dataset.csv**: Unified dataset for analysis.

### Old Data (`old/`)

- Legacy backup datasets from earlier stages.

---

## Installation

### Python Dependencies

Install Python dependencies using pip:

```bash
pip install -r requirements.txt
```

Some scripts require API keys (YouTube, Reddit) to be set in a `.env` file in the project root. Example:

```
YOUTUBE_API_KEY=your_youtube_api_key
client_id=your_reddit_client_id
client_secret=your_reddit_client_secret
username=your_reddit_username
password=your_reddit_password
user_agent=your_reddit_user_agent
```

### R Dependencies

R scripts use the `pacman` package to load required libraries. Main dependencies include:

- tidyverse
- ggplot2
- lubridate
- fpp3
- ggthemes
- ggsci

---

## Usage

### Data Collection

- **YouTube**: Run `python data_retrival/youtube_api.py` to collect videos and comments.
- **Reddit**: Run `python src/reddit_scraper.py` to collect Reddit posts and comments.

> **Note:** API credentials are required for each platform. See the Installation section.

### Data Processing

- **Reddit JSON to CSV**: Run `python src/reddit_to_csvV2.py` to clean and convert Reddit data.
- **Join/Split Datasets**: Use `join_dataset.py` and `splitdataset.py` for merging and splitting large datasets.

### Sentiment/Emotion Analysis

- Run `python src/sentiment_analysis.py` to generate emotion scores for the unified dataset. Results are saved in `results/aggregated/emotions/`.

### Analysis and Visualization

- Open and run `analysis.ipynb` for YouTube-focused analysis and topic modeling.
- Use R scripts in the `R/` directory for advanced statistical analysis and visualization. Example:
  ```R
  source('R/Analysis.R')
  ```

---

## Data Structure

### Main Fields (CSV/JSON)

- `post_id`, `comment_id`, `video_id`, `tweet_id`: Unique identifiers for posts/comments.
- `text`, `title`, `selftext`, `description`: Content fields.
- `author`, `username`, `channel_title`: Author information.
- `created_utc`, `published_at`, `created_at`: Timestamps.
- `score`, `like_count`, `comment_count`, `view_count`: Engagement metrics.
- `emotion scores`: Columns for `joy`, `trust`, `fear`, `surprise`, `sadness`, `disgust`, `anger`, `anticipation` (after running sentiment analysis).

---

## Results

- **Raw Data**: See `results/[subreddit].json` for Reddit, `data_retrival/youtube_database/` for YouTube.
- **Processed Data**: See `results/aggregated/` for cleaned and emotion-annotated datasets.
- **Plots and Figures**: See `R/plots/` for generated visualizations.
- **Intermediate Results**: See `data_retrival/results_analysis/` for topic modeling and grid search outputs.
