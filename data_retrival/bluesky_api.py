import os
import time
import pandas as pd
from dotenv import load_dotenv
from datetime import datetime, timezone
from atproto import Client

# 🔐 Carica le credenziali dal file .env
load_dotenv()
username = os.getenv("BLUESKY_USERNAME")
password = os.getenv("BLUESKY_PASSWORD")

# 📡 Login al client Bluesky
client = Client()
client.login(username, password)

# 🔍 Parole chiave da cercare
keywords = [
    "Robb Elementary School shooting",
    #"#NeverAgain",
    #"#GunControlNow",
    #"#PrayForStonemanDouglas"
]

# 📅 Intervallo temporale desiderato (UTC)
start_date = datetime(2022, 5, 24, tzinfo=timezone.utc)
end_date = datetime(2022, 5, 25, tzinfo=timezone.utc)

# 📦 Lista per salvare i post raccolti
posts = []

# 🔁 Per ogni parola chiave, esegui la ricerca con paginazione
for keyword in keywords:
    cursor = None
    print(f"🔍 Cercando per keyword: {keyword}")
    while True:
        params = {"q": keyword, "limit": 1}
        if cursor:
            params["cursor"] = cursor

        results = client.app.bsky.feed.search_posts(params)
        batch = results.posts
        if not batch:
            break

        stop_paging = False
        for item in batch:
            record = item.record
            author = item.author

            # Parse della data con timezone UTC
            created = datetime.fromisoformat(record.created_at.replace("Z", "+00:00")).astimezone(timezone.utc)

            # Interrompi se sei oltre l’intervallo
            if created < start_date:
                stop_paging = True
                break

            if start_date <= created <= end_date:
                posts.append({
                    "keyword": keyword,
                    "post_uri": item.uri,
                    "handle": author.handle,
                    "display_name": getattr(author, 'display_name', ''),
                    "text": record.text,
                    "created_at": record.created_at,
                    "author_did": author.did
                })

        if stop_paging:
            break

        cursor = getattr(results, "cursor", None)
        if not cursor:
            break

        time.sleep(1)  # ⏳ Rispetta i rate limit

# 💾 Salvataggio finale in CSV
df = pd.DataFrame(posts)
df.to_csv("bluesky_filtered_2022_2023.csv", index=False)
print(f"✅ Salvati {len(df)} post in 'bluesky_filtered_2022_2023.csv'")
