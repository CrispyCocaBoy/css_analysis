import os
import json
import csv
import unicodedata
import html
import re
from datetime import datetime

def clean_text(text: str) -> str:
    """Clean text to retain only natural language: remove formatting, symbols, and noise."""
    if not isinstance(text, str):
        return ''

    # 1. Normalize Unicode
    text = unicodedata.normalize('NFKC', text)

    # 2. Remove control and formatting characters
    text = ''.join(c for c in text if unicodedata.category(c) not in {'Cc', 'Cf', 'Cs'})

    # 3. Decode HTML entities (&gt;, &amp;, etc.)
    text = html.unescape(text)

    # 4. Remove Markdown formatting
    text = re.sub(r'(\*\*|__)(.*?)\1', r'\2', text)     # bold
    text = re.sub(r'(\*|_)(.*?)\1', r'\2', text)         # italic
    text = re.sub(r'`{1,3}(.*?)`{1,3}', r'\1', text)     # inline code
    text = re.sub(r'^> ?(.*)', r'\1', text, flags=re.MULTILINE)  # blockquotes
    text = re.sub(r'^[-+*] ', '', text, flags=re.MULTILINE)      # bullets
    text = re.sub(r'\[(.*?)\]\(.*?\)', r'\1', text)              # markdown links

    # 5. Remove non-natural language symbols (keep only letters, numbers, punctuation)
    text = re.sub(r'[^\w\s.,!?\'\"-]', '', text, flags=re.UNICODE)  # remove symbols/emojis/etc.

    # 6. Collapse excess whitespace
    text = re.sub(r'\s+', ' ', text).strip()

    return text

def json_to_csv():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    results_dir = os.path.join(base_dir, '..', 'results')
    output_csv = os.path.join(base_dir, '..', 'reddit_results.csv')

    header = ['post_id', 'title', 'text', 'score', 'author', 'created_utc', 'url', 'permalink', 'reference']
    with open(output_csv, 'w', newline='', encoding='utf-8') as f_out:
        writer = csv.writer(f_out)
        writer.writerow(header)

    for file in os.listdir(results_dir):
        if not file.endswith('.json'):
            continue

        file_path = os.path.join(results_dir, file)
        print(f"🔍 Processing file: {file_path}")

        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                data = json.load(f)
                if not isinstance(data, list):
                    print(f"⚠️ Skipping {file}: not a list of posts")
                    continue
            except Exception as e:
                print(f"❌ Error reading {file}: {e}")
                continue

        for post in data:
            try:
                post_id = clean_text(post['post_id'])
                title = clean_text(post.get('title', ''))
                selftext = clean_text(post.get('selftext', ''))
                score = post.get('score', 0)
                author = clean_text(post.get('author', '[deleted]'))
                created_utc = datetime.fromisoformat(post['created_utc'])
                url = clean_text(post.get('url', ''))
                permalink = clean_text(f"https://www.reddit.com{post.get('permalink', '')}")
                comments = post.get('high_score_comments', [])

                with open(output_csv, 'a', newline='', encoding='utf-8') as f_out:
                    writer = csv.writer(f_out)
                    writer.writerow([
                        post_id, title, selftext, score, author,
                        created_utc.isoformat(), url, permalink, None
                    ])

                    for comment in comments:
                        c_author = clean_text(comment.get('author', '[deleted]'))
                        c_score = comment.get('score', 0)
                        c_body = clean_text(comment.get('body', ''))
                        c_created = datetime.fromisoformat(comment['created_utc'])

                        writer.writerow([
                            post_id, None, c_body, c_score, c_author,
                            c_created.isoformat(), None, None, post_id
                        ])

            except Exception as e:
                print(f"❌ Error processing post in {file}: {e}")

    print(f"✅ All JSON processed. Clean CSV saved to: {output_csv}")

# Run the conversion
if __name__ == '__main__':
    json_to_csv()