import requests
import pandas as pd

BEARER_TOKEN = 'AAAAAAAAAAAAAAAAAAAAAOQn2wEAAAAA8zWU35T3BlxWG2MfYoaBgcN0Bt8%3D8JdzkMB3WXtlLOuG4mvmIqQF9csnvdrHy5HCk3qWk1RBDf4pED'

query = (
    '("Parkland shooting" OR #SchoolShooting OR #PrayForStonemanDouglas '
    'OR #GunControlNow OR #Parkland OR #ParklandShooting OR #FloridaSchoolShooting '
    'OR #StonemanDouglas OR #RIP OR #NeverForget OR #NeverAgain) '
    'lang:en'
)

url = 'https://api.twitter.com/2/tweets/search/all'

headers = {
    "Authorization": f"Bearer {BEARER_TOKEN}",
    "Content-Type": "application/json"
}

params = {
    "query": query,
    "max_results": 10,
    "tweet.fields": "created_at,text,author_id,public_metrics,referenced_tweets,geo",
    "expansions": "author_id,geo.place_id",
    "user.fields": "username,location",
    "place.fields": "full_name,country",

}

response = requests.get(url, headers=headers, params=params)

if response.status_code == 200:
    result = response.json()
    tweets_data = result.get("data", [])
    includes = result.get("includes", {})
    users = {u["id"]: u for u in includes.get("users", [])}
    places = {p["id"]: p for p in includes.get("places", [])}

    tweets = []
    for tweet in tweets_data:
        user = users.get(tweet["author_id"], {})
        place = places.get(tweet.get("geo", {}).get("place_id", ""), {})
        metrics = tweet.get("public_metrics", {})

        # 🔁 Controlla se è retweet, reply o quote
        referenced = tweet.get("referenced_tweets", [])
        original_id = None
        reference_type = None
        if referenced:
            for ref in referenced:
                original_id = ref.get("id")
                reference_type = ref.get("type")

        tweets.append({
            "tweet_id": tweet["id"],
            "created_at": tweet["created_at"],
            "text": tweet["text"],
            "author_id": tweet["author_id"],
            "username": user.get("username", ""),
            "user_location": user.get("location", ""),
            "likes": metrics.get("like_count", 0),
            "retweets": metrics.get("retweet_count", 0),
            "replies": metrics.get("reply_count", 0),
            "quotes": metrics.get("quote_count", 0),
            "reference_type": reference_type,            # ← tipo (retweeted / replied_to / quoted)
            "original_tweet_id": original_id,            # ← id del tweet originale
            "place_name": place.get("full_name", ""),
            "country": place.get("country", "")
        })

    df = pd.DataFrame(tweets)
    df.to_csv("tweets_parkland.csv", index=False)
    print(f"✅ Salvati {len(df)} tweet in 'tweets_parkland.csv'")
else:
    print(f"❌ Errore {response.status_code}: {response.text}")

