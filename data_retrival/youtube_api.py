import requests
import pandas as pd
from tqdm import tqdm
from dotenv import load_dotenv
import os

# Carica API segreta
load_dotenv()
API_KEY = os.getenv("YOUTUBE_API_KEY")

# Directory
os.makedirs("data_retrival/youtube_database", exist_ok=True)
youtube_dir = "data_retrival/youtube_database"


def get_top_videos(topic, max_total_results=50):
    search_url = "https://www.googleapis.com/youtube/v3/search"
    videos = []
    next_page_token = None

    with tqdm(total=max_total_results, desc="Scaricamento video", unit="video") as pbar:
        while len(videos) < max_total_results:
            remaining = max_total_results - len(videos)
            max_results = min(50, remaining)

            params = {
                "part": "snippet",
                "q": topic,
                "type": "video",
                "maxResults": max_results,
                "order": "relevance",
                "key": API_KEY
            }
            if next_page_token:
                params["pageToken"] = next_page_token

            res = requests.get(search_url, params=params).json()
            items = res.get("items", [])
            videos.extend([item['id']['videoId'] for item in items])
            pbar.update(len(items))

            next_page_token = res.get("nextPageToken")
            if not next_page_token:
                break

    return videos

# Ottiene i video con più visualizzazioni
def get_video_details(video_ids):
    videos_url = "https://www.googleapis.com/youtube/v3/videos"
    params = {
        "part": "snippet,contentDetails,statistics,topicDetails,status",
        "id": ','.join(video_ids),
        "key": API_KEY
    }
    response = requests.get(videos_url, params=params).json()
    items = response.get('items', [])

    videos_data = []
    for item in items:
        snippet = item.get("snippet", {})
        stats = item.get("statistics", {})
        videos_data.append({
            "video_id": item["id"],
            "title": snippet.get("title"),
            "description": snippet.get("description"),
            "published_at": snippet.get("publishedAt"),
            "channel_title": snippet.get("channelTitle"),
            "view_count": stats.get("viewCount"),
            "like_count": stats.get("likeCount"),
            "comment_count": stats.get("commentCount")
        })
    return videos_data

# Ottiene i commenti per ogni video_id
def get_all_comments(video_id):
    comments = []
    url = "https://www.googleapis.com/youtube/v3/commentThreads"
    params = {
        "part": "snippet",
        "videoId": video_id,
        "maxResults": 100,
        "textFormat": "plainText",
        "key": API_KEY
    }

    with tqdm(desc=f"Commenti video {video_id}", unit="comm") as pbar:
        while True:
            res = requests.get(url, params=params).json()
            for item in res.get("items", []):
                snippet = item["snippet"]["topLevelComment"]["snippet"]
                comments.append({
                    "video_id": video_id,
                    "comment_id": item["id"],
                    "author": snippet.get("authorDisplayName"),
                    "text": snippet.get("textDisplay"),
                    "published_at": snippet.get("publishedAt"),
                    "like_count": snippet.get("likeCount")
                })
                pbar.update(1)

            next_page = res.get("nextPageToken")
            if not next_page:
                break
            params["pageToken"] = next_page
    return comments

def get_video_id(link):
    return link.split("v=")[-1]


def run():
    topic = "parkland school shooting"
    video_ids = get_top_videos(topic)
    details = get_video_details(video_ids)

    # Salvataggio dettagli video in CSV
    video_df = pd.DataFrame(details)
    video_df.to_csv(os.path.join(youtube_dir,"video.csv"), index=False)
    print(f"Salvati dettagli di {len(video_df)} video in 'video_details.csv'")

    # Scarica tutti i commenti in un'unica lista
    all_comments = []

    for video in details:
        vid = video["video_id"]
        comments = get_all_comments(vid)
        if comments:
            all_comments.extend(comments)
            print(f"Aggiunti {len(comments)} commenti dal video {vid}")
        else:
            print(f"Nessun commento trovato per il video {vid}")

    # Salva tutto in un unico CSV
    if all_comments:
        df = pd.DataFrame(all_comments)
        df.to_csv(os.path.join(youtube_dir,"comments_youtube.csv"), index=False)
        print(f"Salvati {len(df)} commenti totali in 'comments_youtube.csv'")


if __name__ == "__main__":
    run()
