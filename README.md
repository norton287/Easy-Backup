# 🚀 Awesome Backup & Cleanup Script 🚀

Tired of tedious backups and cluttered file systems? This Bash script is your **one-stop shop** for streamlined data management!

## 💥 What It Does 💥

This powerhouse script **automates** two crucial tasks:

1. **Seamless Backups:** Effortlessly copies all files and subdirectories from your designated backup location to a secure target directory. It's smart enough to **skip existing files** to save you time.
2. **Intelligent Cleanup:**  Automatically purges old files from your backup directory that are older than a specified number of days, keeping your system lean and efficient.

## 🌟 Why You'll Love It 🌟

- **Simplicity:**  No more complex commands or manual file juggling! This script does the heavy lifting for you.
- **Efficiency:** Rsync ensures lightning-fast, incremental backups that only transfer what's changed.
- **Customizable:**  Easily tailor the script to your specific backup locations and cleanup preferences.
- **Reliability:**  Keep your data safe and organized without breaking a sweat.

## 🚀 Getting Started 🚀

1. **Download:** Grab the `do_backup.sh` script and save it to your preferred location.
2. **Customize:**  Open the script in your favorite text editor and modify the `BACKUP_DIR` and `SHARE_DIR` variables to match your directories. You can also adjust the `-mtime` value to control how many days old files must be before they're deleted.
3. **Permissions:**  Make the script executable: `chmod +x do_backup.sh`
4. **Run:** Execute the script: `./do_backup.sh`
5. **Automate:**  (Optional) Use `cron` to schedule automatic backups and cleanup at regular intervals.

## 💪 Pro Tips 💪

- **Test:** Before relying on this script for critical backups, always test it thoroughly on non-essential data.
- **Monitor:** Keep an eye on your backups and cleanup logs to ensure everything is running smoothly.
- **Customize:**  Feel free to expand the script with additional features like error handling, email notifications, or even cloud integration!

## 🤝 Contribute 🤝

Got a great idea or improvement? We welcome contributions! Fork the repository, make your changes, and submit a pull request.

## 🎉 Enjoy Hassle-Free Backups and a Clean System! 🎉

