import json
import os
import csv
import datetime

def json_to_csv() -> None:
    first = True
    print(list(os.walk('../results')))
    for file in list(os.walk('../results'))[0][2]:
        if file.endswith('.json'):
            with open(f'../results/{file}') as f:
                read = json.load(f)
        else:
           continue
        
        for k in range(len(read)):
            if first:
               with open('reddit_results.csv', 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['post_id', 'title', 'text', 'score', 'author', 'created_utc', 'url', 'permalink', 'reference']) 
                post_id = read[k]['post_id']
                writer.writerow([
                    post_id,
            read[k]['title'],
            read[k]['score'],
            read[k].get('author', '[deleted]'),
            datetime.utcfromtimestamp(read[k]['created_utc']).isoformat(),
            read[k].get('url', ''),
            f"https://www.reddit.com{read[k]['permalink']}",
            None
        ]) 
                for i in range(len(read[k]['high_score_comments'])):
                   with open('reddit_results.csv', 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(['post_id', 'title', 'text', 'score', 'author', 'created_utc', 'url', 'permalink', 'reference']) 
                    writer.writerow([
                        post_id,
                        None,
                        read[k]['high_score_comments']['body'],
                        read[k]['high_score_comments']['score'],
                        read[k]['high_score_comments'].get('author', '[deleted]'),
                        datetime.utcfromtimestamp(read[k]['high_score_comments']['created_utc']).isoformat(),
                        None,
                        None,
                        post_id
                        
                    ])
                    first = False
            else:
               with open('reddit_results.csv', 'a', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['post_id', 'title', 'text', 'score', 'author', 'created_utc', 'url', 'permalink', 'reference']) 
                post_id = read[k]['post_id']
                writer.writerow([
                    post_id,
            read[k]['title'],
            read[k]['score'],
            read[k].get('author', '[deleted]'),
            datetime.utcfromtimestamp(read[k]['created_utc']).isoformat(),
            read[k].get('url', ''),
            f"https://www.reddit.com{read[k]['permalink']}",
            None
        ]) 
                for i in range(len(read[k]['high_score_comments'])):
                   with open('reddit_results.csv', 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(['post_id', 'title', 'text', 'score', 'author', 'created_utc', 'url', 'permalink', 'reference']) 
                    writer.writerow([
                        post_id,
                        None,
                        read[k]['high_score_comments']['body'],
                        read[k]['high_score_comments']['score'],
                        read[k]['high_score_comments'].get('author', '[deleted]'),
                        datetime.utcfromtimestamp(read[k]['high_score_comments']['created_utc']).isoformat(),
                        None,
                        None,
                        post_id
                        
                    ])

json_to_csv()
