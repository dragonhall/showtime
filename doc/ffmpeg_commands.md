Stream Monoszkop
----------------

```
ffmpeg -y -loglevel 0 -re -stream_loop -1 -i Music.mp3 -f mp3 - | ffmpeg -y -re -i pipe:0 -loop 1 -i DHTV_monoszkop.png -f flv rtmp://127.0.0.1:1935/live/dragonhall
```
