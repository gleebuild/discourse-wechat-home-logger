# discourse-wechat-home-logger

Logs each homepage full-page load (GET for '/', '/latest', '/categories', '/top', '/new', or '/hot')
into `/var/www/discourse/log/wechat.log` as a line like:

```
2025-08-21 10:00:00 +0000 | page load
```

## Install (Docker / official image)
1. Copy this folder into the host at `/var/discourse/plugins/discourse-wechat-home-logger` (or unzip there).
2. Rebuild Discourse:  
   ```bash
   cd /var/discourse
   ./launcher rebuild app
   ```

## Verify
```bash
# inside the running container after rebuild:
docker exec -it app bash
tail -f /var/www/discourse/log/wechat.log
```
Refresh the forum homepage (`/` or `/latest`) and you should see a new "page load" line.

## Notes
- Only logs when the server serves an **HTML** page (not JSON/API calls), to avoid noise.
- If `/var/www/discourse/log` doesn't exist, the plugin will create it.
