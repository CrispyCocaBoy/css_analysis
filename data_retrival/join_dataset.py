import pandas as pd
df1 = pd.read_csv("youtube_database/comments_youtube.csv")
df2 = pd.read_csv("youtube_database/comments_youtube_x_viz.csv")



df_unito = pd.concat([df1, df2], ignore_index=True)
df_unito = df_unito.drop_duplicates()

df_unito.to_csv("comments_youtube_final.csv", index=False)

import pandas as pd
df1 = pd.read_csv("youtube_database/video.csv")
df2 = pd.read_csv("youtube_database/video_details_x_viz.csv")



df_unito = pd.concat([df1, df2], ignore_index=True)
df_unito = df_unito.drop_duplicates()

df_unito.to_csv("video_details_final.csv", index=False)