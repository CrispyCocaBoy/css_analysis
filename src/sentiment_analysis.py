from transformers import pipeline
import pandas as pd
import numpy as np
import os
from tqdm import tqdm

# --- Config ---
CHECKPOINT_SIZE = 1000  # Save every 1000 rows
EMOTIONS = ['joy', 'fear', 'surprise', 'sadness', 'disgust', 'anger']
MODEL_NAME = "valhalla/distilbart-mnli-12-1"

# --- Setup ---
classifier = pipeline("zero-shot-classification", model=MODEL_NAME)
base_dir = os.path.dirname(os.path.abspath(__file__))
input_path = os.path.join(base_dir, '..', 'results/aggregated/reddit_cleaned.csv')
output_dir = os.path.join(base_dir, '..', 'results/aggregated/emotions')
os.makedirs(output_dir, exist_ok=True)

# --- Load data ---
df = pd.read_csv(input_path)

# Add emotion score columns if not already present
for emotion in EMOTIONS:
    if emotion not in df.columns:
        df[emotion] = np.nan

# --- Process and save in chunks ---
chunk = []
for i, row in tqdm(df.iterrows(), total=len(df), desc="Classifying"):
    text = row.get('text')
    if isinstance(text, float) or pd.isna(text) or not text.strip():
        continue

    result = classifier(text, EMOTIONS)
    score_map = dict(zip(result['labels'], result['scores']))

    for emotion in EMOTIONS:
        df.at[i, emotion] = score_map.get(emotion, 0.0)

    # Checkpoint save every N rows
    if (i + 1) % CHECKPOINT_SIZE == 0:
        checkpoint_path = os.path.join(output_dir, f'reddit_with_emotions_checkpoint_{i+1:05d}.csv')
        df.iloc[:i+1].to_csv(checkpoint_path, index=False, float_format='%.2f')
        print(f"💾 Saved checkpoint: {checkpoint_path}")

# --- Final full save ---
final_path = os.path.join(output_dir, 'reddit_with_emotions_final.csv')
df.to_csv(final_path, index=False, float_format='%.2f')
print(f"✅ All done. Final file saved to: {final_path}")