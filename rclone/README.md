# rclone - Google Drive Bidirectional Sync

Local mirror of Google Drive using `rclone bisync`. Files live at `~/gdrive` as real local files and sync bidirectionally with Google Drive every 5 minutes via a systemd timer.

## Features

- **Local files** — no FUSE mount, no network latency to open files
- **Bidirectional sync** — changes made locally or on Google Drive are synced both ways
- **Offline access** — all files are always available locally
- **Local backup** — full copy of Google Drive on disk
- **Conflict resolution** — newest edit wins; the older version is kept with a `.conflict` suffix (nothing is lost)
- **Safety guardrail** — aborts if more than 50 files would be deleted in a single sync (prevents accidental mass deletion)
- **Auto-recovery** — recovers from interrupted syncs and transient network errors without manual intervention
- **Low priority** — runs at nice 10 with idle I/O scheduling so it doesn't interfere with interactive use

## Files

| File | Install location |
|---|---|
| `rclone-bisync.service` | `~/.config/systemd/user/rclone-bisync.service` |
| `rclone-bisync.timer` | `~/.config/systemd/user/rclone-bisync.timer` |

## Setup

### Prerequisites

```bash
# Install rclone
sudo dnf install rclone

# Configure the Google Drive remote (follow the interactive prompts)
rclone config
# Create a remote named "gdrive" with type "drive" and scope "drive"
```

### Install

```bash
# Create the log directory
mkdir -p ~/.local/share/rclone

# Copy the unit files
cp rclone-bisync.service ~/.config/systemd/user/
cp rclone-bisync.timer ~/.config/systemd/user/

# Initial sync (downloads everything from Google Drive — takes a while)
rclone bisync ~/gdrive gdrive: \
  --resync \
  --resync-mode path2 \
  --transfers 8 \
  --checkers 16 \
  --create-empty-src-dirs \
  --fix-case

# Enable and start the timer
systemctl --user daemon-reload
systemctl --user enable --now rclone-bisync.timer
```

## Useful Commands

```bash
# Trigger an immediate sync
systemctl --user start rclone-bisync.service

# Check sync status
systemctl --user status rclone-bisync.service

# View the timer schedule
systemctl --user list-timers | grep bisync

# View sync logs
tail -50 ~/.local/share/rclone/bisync.log

# Check Google Drive storage usage
rclone about gdrive:

# Force sync when more than 50 deletions are needed (e.g. bulk cleanup)
rclone bisync ~/gdrive gdrive: --force --resync

# Full re-sync from scratch (if state gets corrupted)
rclone bisync ~/gdrive gdrive: \
  --resync \
  --resync-mode path2 \
  --transfers 8 \
  --checkers 16 \
  --create-empty-src-dirs \
  --fix-case
```

## How It Works

- `rclone-bisync.timer` fires every 5 minutes (2 min delay after boot)
- It triggers `rclone-bisync.service`, which runs `rclone bisync` as a oneshot
- rclone compares file listings from both sides against the previous sync state to detect changes
- New/modified files are copied in the appropriate direction; deletions are propagated
- Bisync state is stored in `~/.cache/rclone/bisync/`
- If a file is modified on both sides between syncs, the newer version wins and the older is renamed with a `.conflict` suffix

## Notes

- Deleted files are recoverable from Google Drive's trash for 30 days
- Google Docs/Sheets/Slides are exported as .docx/.xlsx/.pptx locally
- The `--max-delete 50` limit can be overridden with `--force` for intentional bulk operations
