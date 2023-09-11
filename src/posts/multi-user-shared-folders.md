---
id: multi-user-shared-folders
uuid: 07b39aed-c9e4-41f8-8cb2-79c70579267c
title: 'Setting up shared folders in Linux'
author: Juan Antonio Nepormoseno Rosales
category: tech
date: 2023-09-11T22:22:00Z
last-update: 2023-09-11T22:22:00Z
abstract: Recently I found an article that advocated having separate work and personal users in your laptop to avoid this case. Here's how to set up shared folders for those users.

---

I find it difficult to concentrate on personal projects when I'm working on my PC. I go to search some documentation online and I see social networks tabs, videos and articles with interesting topics I saved for later... and I lose my focus.

Recently I found an article that advocated having separate work and personal users in your laptop to avoid this case. That sounds like a great idea, but I have my Obsidian second brain in my personal user folder and I have Syncthing to share it with other devices. So I need to update it to be accessible for both users.

## Design
I want to create a folder that Syncthing can read and write to. Both personal and work users must be able to read and write to that folder as well. For that, we will use a **user group** shared by Syncthing and the other users.

![]($BASE_URL$/imgs/multi-user-shared-folders/syncthing_shared_folder.png)

Existing files and folders will need to have its **group and permissions updated** to be readable and writable for that user group.

We will also need **new files and folders** to be created with specific permissions:
- They must be added to the `syncthing` group.
- They must have the read and write permissions for the group.

Are there easier ways to do this? Probably, but this is the way I wanted to do this.

## Setting it up
Just FYI, you will probably need to use `sudo` for most of the commands. I removed it to make the code less verbose and redundant. Just use your common sense: if you're updating permissions for a file/folder not owned by you or you're creating and assigning groups to users, use `sudo`.

### Create group
With these commands you create a user group called `syncthing` and add `personal` and `work` users to it.
```bash
groupadd syncthing
usermod -a -G syncthing personal
usermod -a -G syncthing work
```

At this point, you must reboot your computer for these changes to apply. You can verify your user was added to the group when you login with these commands:
```bash
groups
id
```

### Permission for existing files
Make the entire folder be owned by the group you just created with:
```bash
chgrp -R syncthing /srv/syncthing
```

Then update the existing files and folders to have read and write permissions for the group:
```bash
find /srv/syncthing -exec chmod 775 {} +
```

### Default group permissions for new files and folders
By default, your system might create new files and folders with the write permission for the group disabled. In order to change that, you need to use Access Control Lists (ACLs). They seem complicated and 
```bash
# Force new files and folders to have the same group as the parent folder
chmod g+s /srv/syncthing
find /var/www -type d -exec chmod g+s {} + # for subdirectories

# Force new files and folders to have the group permissions set to read and write
setfacl -m "default:group::rw" /srv/syncthing
find /srv/syncthing -type d -exec setfacl -m d:g::rw {} + # for subdirectories
```

And that should be it.

## Testing it
In my case I just removed the original folder from Syncthing and re-synced again in the new location: `/srv/syncthing/Obsidian`.

After that, I logged in with my personal user, set up Obsidian to use that folder and I can open and write in files. Do the same for the other user and it works too ✅
