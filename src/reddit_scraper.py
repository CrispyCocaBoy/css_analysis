import requests
import csv
from datetime import datetime
import time
import json
from dotenv import load_dotenv
import os

load_dotenv()

# --- Configuration ---
client_id = os.environ.get('client_id')
client_secret = os.environ.get('client_secret')
username = os.environ.get('username')
password = os.environ.get('password')
user_agent = os.environ.get('user_agent')

subreddit = 'NewsSteady'
query = 'Parkland AND school AND shooting'
limit = 1000  # Keep this low for testing
comment_score_min = 5   # Score threshold
output_csv = 'reddit_posts_with_comments.csv'

# --- Step 1: OAuth2 Authentication ---
# --- Step 1: OAuth2 Token ---
auth = requests.auth.HTTPBasicAuth(client_id, client_secret)
data = {'grant_type': 'password', 'username': username, 'password': password}
headers = {'User-Agent': user_agent}

res = requests.post('https://www.reddit.com/api/v1/access_token', auth=auth, data=data, headers=headers)
token = res.json()['access_token']
headers['Authorization'] = f'bearer {token}'

# --- Step 2: Search Subreddit Posts ---
search_url = f'https://oauth.reddit.com/r/{subreddit}/search'
params = {
    'q': query,
    'limit': limit,
    'sort': 'relevance',
    'restrict_sr': True
}
resp = requests.get(search_url, headers=headers, params=params)
posts = resp.json()['data']['children']

# --- Helper: Recursive Comment Extractor ---
def extract_comments(children, threshold):
    results = []
    for child in children:
        kind = child.get('kind')
        data = child.get('data', {})
        if kind != 't1':
            continue
        score = data.get('score', 0)
        body = data.get('body', '')
        if score >= threshold and not body.lower().startswith('[deleted') and body.strip():
            results.append({
                'author': data.get('author'),
                'score': score,
                'body': body,
                'created_utc': datetime.utcfromtimestamp(data['created_utc']).isoformat()
            })
        replies = data.get('replies')
        if replies and isinstance(replies, dict):
            results.extend(extract_comments(replies['data']['children'], threshold))
    return results

# --- Step 3: Fetch Comments & Save to CSV ---
output_json = 'reddit_posts_with_comments.json'
all_data = []

for post in posts:
    data = post['data']
    post_id = data['id']
    title = data['title']
    selftext = data.get('selftext', '')
    score = data['score']
    author = data.get('author', '[deleted]')
    created_utc = datetime.utcfromtimestamp(data['created_utc']).isoformat()
    num_comments = data['num_comments']

    # Fetch and filter comments
    comment_url = f'https://oauth.reddit.com/comments/{post_id}.json'
    try:
        response = requests.get(comment_url, headers=headers, params={'depth': 10, 'limit': 500})
        comment_blob = response.json()[1]['data']['children']
        high_comments = extract_comments(comment_blob, comment_score_min)
    except Exception as e:
        print(f"⚠️ Error fetching comments for post {post_id}: {e}")
        high_comments = []

    # Build JSON record
    post_record = {
        'post_id': post_id,
        'title': title,
        'author': author,
        'score': score,
        'created_utc': created_utc,
        'selftext': selftext,
        'num_comments': num_comments,
        'high_score_comments': high_comments
    }

    all_data.append(post_record)
    print(f"✅ Collected {len(high_comments)} comments for post: {post_id}")
    time.sleep(0.1)

# Write everything to JSON
with open(output_json, 'w', encoding='utf-8') as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print(f"\n🎉 Done! Saved {len(all_data)} posts to '{output_json}'")