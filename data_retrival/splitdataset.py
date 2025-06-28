import pandas as pd

comments_youtube = pd.read_csv("youtube_database/comments_youtube.csv")

def split_dataset(dataset):
    midpoint = len(dataset) // 2
    dataset_1 = dataset.iloc[:midpoint]
    dataset_2 = dataset.iloc[midpoint:]
    return dataset_1, dataset_2

comments_youtube_pt1, comments_youtube_pt2  = split_dataset(comments_youtube)

comments_youtube_pt1.to_csv("comments_youtube_pt1.csv", index=False)
comments_youtube_pt2.to_csv("comments_youtube_pt2.csv", index=False)



