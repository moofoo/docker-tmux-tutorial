Assuming you've installed both `TMUX` and `tmuxinator`, you can run

```bash
tmuxinator start
```

To star the docker compose project and open the TMUX dashboard.

# Docker basics: Using TMUX and tmuxinator for a better docker compose experience

This tutorial provides a practical introduction to [TMUX](https://github.com/tmux/tmux/wiki) and how you can use [tmuxinator](https://github.com/tmuxinator/tmuxinator) to easily set up terminal dashboards with logs and shell sessions for your docker compose projects.

After a (very) brief overview of basic TMUX commands, we'll look at using tmuxinator to more easily configure TMUX with [YAML](https://en.wikipedia.org/wiki/YAML) configuration files, and at the end we'll go over how to install and use TMUX plugins.

This tutorial was written for Linux or WSL users (I'm running Ubuntu).

### Article Index

- [Install Packages](#packages)
- [Basic TMUX Commands](#commands)
- [Configuring TMUX (~/.tmux.config)](#config)
- [Tmuxinator (.tmuxinator.yml)](#tmuxinator)
- [TMUX plugins](#plugins)
- [Resources and Links](#resources)
- [Extra: Issues with Docker Compose 'Watch'](#watch)

## <u>Install necessary packages</u> <a name="packages"></a>

- TMUX
  - `sudo apt update && sudo apt install tmux`

- tmuxinator
  - To install the latest version of tmuxinator:
    - Use [Homebrew](https://brew.sh/): `brew install tmuxinator`
    - Or use [RubyGems](https://rubygems.org/): `gem install tmuxinator`

  - To install a usually slightly-out-of-date version of tmuxinator (which is probably just fine for this tutorial):
    - `sudo apt update && sudo apt install tmuxinator`

## <u>TMUX command basics</u> <a name="commands"></a>

As the end-goal here is to show how to use tmuxinator .yaml configs to create bespoke dashboards for docker compose projects, I'm only going to go over the following:

1. The TMUX prefix combo + keybinding system
2. How to show the list of TMUX keybindings within TMUX
3. How to detach from a TMUX session (leaving the session running)
4. How to kill a TMUX session

---

The first thing to know about TMUX is that the standard commands all follow a "prefix" key combination.

The default prefix is `Ctrl + b`, but when we get to configuring TMUX with the `~/.tmux.config file`, we'll be changing this to the more conveniet combo 'Ctrl + a'.

If you want to follow along for the rest of this section, run `tmux` in your terminal to start a session.

#### How to show the list of TMUX keybindings

Enter the prefix `Ctrl + b`, and then press `?` (shift key is necessary) to see the list of keybindings.

Press `ESC` to close the list.

#### How to detach from a TMUX session

Enter the prefix `Ctrl + b`, and then enter `d`. This will detach the current TMUX session and return you to the command line.

To see a list of running TMUX sessions (from the command line), enter `tmux ls`.

To stop the currently running TMUX session, type `tmux kill-session`

#### How to open the 'command prompt' in TMUX and kill the current session and exit TMUX

Back in TMUX, enter the prefix `Ctrl + b` and then `:` (shift key necessary).

This opens a command prompt at the bottom of the screen, where you can run TMUX cli commands (like 'kill-session', for example).

Pressing 'ESC" will close the command prompt.

## <u>Configuring TMUX with the ~/.tmux.config file</u> <a name="config"></a>

Assuming you don't already have a tmux config file, create a file named `.tmux.config` in your home directory and paste the following into it:

```bash
# Turn on mouse input
set -g mouse on

# Increase the scrollback limit from 2000 to 10000
set -g history-limit 10000

# Change TMUX prefix key combo from 'Ctrl + b' to 'Ctrl + a'
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Add keybinding to change the currently focused pane with Alt + direction key
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Add keybinding to select windows with 'Alt + Shift + Right' (next window) or 'Alt + Shift + Left' (previous window).
bind -n S-M-Right select-window -n
bind -n S-M-Left select-window -p

# Add Keybinding to kill the current tmux session and exit tmux with 'Ctrl + Shift + x'
bind -n C-S-x kill-session

# Add keybinding to clear focused pane (that is, the whole scrollback history) with 'Ctrl + Shift + k'
bind -n C-S-k send-keys -R \; clear-history

# Minor futzing around with the layout
set -g status-position bottom
set -g status-justify left

# Set what appears in the lower left
set -g status-left ''
set -g status-left-length 15

# Set what appears in the lower right
set -g status-right '%Y-%m-%d %H:%M '
set -g status-right-length 50

# Give windows reasonable titles
setw -g window-status-current-format ' #I #W #F '

# Give panes reasonable titles
set -g pane-border-status top
set -g pane-border-format '#[bold]#{pane_title}#[default]'
```

#### Summary

1. Mouse mode\* is turned on
2. Scrollback (history) limit is increased
3. The TMUX prefix is changed from `Ctrl + b` to `Ctrl + a`

- (you do not need to enter prefix before the following shortcuts:)

3. Alt + Direction Key -- changes panes
4. Alt + Shift + Left/Right Key -- changes windows
5. Ctrl + Shift + x -- kills the current session, exiting TMUX
6. Ctrl + Shift + k -- Clears the currently activce pane (as well as scrollback history)

\* Mouse mode gives you

- Mouse-wheel vertical scrolling
- Select Panes by clicking on them
- Resize Panes by click-dragging their borders
- Select Windows by clicking their name in the bottom left of the status bar
- A right-click menu with some common pane actions.
- You can also copy text to the clipboard by click-dragging to select, but it's a little wonky.

## <u>Configuring TMUX in .yaml with tmuxinator</u> <a name="tmuxinator"></a>

For the remainder of this article I will be referring to this example repo: [docker-tmux-tutorial](https://github.com/moofoo/docker-tmux-tutorial)

If you clone the repo and CD into the directory like so

```bash
$ git clone https://github.com/moofoo/docker-tmux-tutorial.git && cd docker-tmux-tutorial
```

You should see the following files/directories:

```bash
|- apps
|  |- web
|  |- api
|- db
|  |- 01_schema.sql
|  |- 02_data.sql
|- .tmuxinator.watch.yml
|- .tmuxinator.yml
|- docker-compose.watch.yml
|- docker-compose.yml
|- Dockerfile
|- README.md
|- tmux.config.example
|- tmux.sh
```

If you then run (in the repo directory)

```bash
$ tmuxinator start
```

the docker compose project will build (if it needs to) and TMUX will open showing windows and panes per the `./tmuxinator.yml` config file.

Let's look at `./tmuxinator.yml` now:

```yaml
# ./.tmuxinator.yml

name: tmuxinator_tut
root: ./

on_project_start: docker compose up --wait -d

on_project_exit: docker compose stop

windows:
  - logs:
      panes:
        - web: clear && docker compose logs --since=1s -f web

        - api: clear && docker compose logs --since=1s -f api

        - db: clear && docker compose logs --since=15s -f db

        - red: clear && docker compose logs --since=15s -f redis

  - shell:
      panes:
        - web: clear && docker compose exec -w /usr/src/app web sh

        - api: clear && docker compose exec -w /usr/src/app api sh

        - psql: clear && docker compose exec db psql -U postgres -d tutorial_db

        - nestjs_repl: clear && docker compose exec -w /usr/src/app api npm run repl

  - home:
      layout: main-vertical
      panes:
        - home: clear
```

#### Going over each section of this config file from the top:

```yml
name: tmuxinator_tut
root: ./
```

The fields above set the tmux session name and tells tmuxinator to run commands in the current directory.

```yml
on_project_start: docker compose up --wait -d

on_project_exit: docker compose stop
```

The "on_project_start" config tells tmuxinator to run [`docker compose up`](https://docs.docker.com/reference/cli/docker/compose/up/) in detached mode when it starts.

The "on project\*exit" config tells it to run `docker compose stop` **_when the session ends_**. (In other words, if you enter the `"Ctrl + Shift + x"` shortcut combo we previously configured in `~/.tmux.config`, it will end the TMUX session and stop the docker compose project).

```yml
windows:
...rest
```

The `windows:` option starts the block where you define the windows and panes you want in the TMUX session.

Here's the first window from the example:

```yml
- logs:
    panes:
      - web: clear && docker compose logs --since=1s -f web

      - api: clear && docker compose logs --since=1s -f api

      - db: clear && docker compose logs --since=15s -f db

      - red: clear && docker compose logs --since=15s -f redis
```

This window definition creates a window named "logs", which has four panes showing the result of running [`docker compose logs`](https://docs.docker.com/reference/cli/docker/compose/logs/) for the web, api, db, and redis services.

```yml
- shell:
    panes:
      - web: clear && docker compose exec -w /usr/src/app web sh

      - api: clear && docker compose exec -w /usr/src/app api sh

      - psql: clear && docker compose exec db psql -U postgres -d tutorial_db

      - nestjs_repl: clear && docker compose exec -w /usr/src/app api npm run repl
```

This window definition creates a window named "shell", with the following panes making use of [`docker compose exec`](https://docs.docker.com/reference/cli/docker/compose/exec/):

1. "web": Opens a shell to the working_dir of the "web" service.
2. "api": Opens a shell to the working_dir of the "api" service.
3. "psql": Starts a [PSQL](https://www.postgresql.org/docs/current/app-psql.html) terminal session in the "db" service.
4. "nestjs_repl": Starts the [NestJS REPL](https://docs.nestjs.com/recipes/repl) for the NestJS server running in the "api" service.

```yml
- home:
    layout: main-vertical
    panes:
      - home: clear
```

Just for convenience, this window definition opens your command line on the current (actual) directory.

If you want to see how this dashboard would be created with TMUX commands, check out the [tmux.sh script](https://github.com/moofoo/docker-tmux-tutorial/blob/main/tmux.sh)

## <u>Extending TMUX with the Tmux Plugin Manager</u> <a name="plugins"></a>

The [TMUX Plugin Manager](https://github.com/tmux-plugins/tpm) provides a (relatively) painless way to extend TMUX functionality.

The following instructions will walk you through setting up TPM and installing/configuring the [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight) plugin, which simply lets you display an indicator after you press the TMUX prefix combo.

#### 1. Install the Tmux Plugin Manager

Run git clone as below to create the necessary files in your $HOME directory:

```shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### 2. Edit your ~/.tmux.config file to use the plugin

At the top of the `~/.tmux.config` before anything else, add the line:

```bash
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
```

(follow the above pattern for all plugins)

Then, at the very bottom of `~/.tmux.config` (after everything else), add the line:

```bash
run '~/.tmux/plugins/tpm/tpm'
```

#### 2. Configure/use the plugin

This plugin gives TMUX a new template string, `#{prefix_highlight}`. Assuming you've been following this tutorial, change the following line (35 for me) from

```bash
set -g status-left ''
```

to

```bash
set -g status-left '#{prefix_highlight}'
```

You can also add the following lines anywhere before the first and last lines in the file to also show an indicator when you're in "Copy mode":

```bash
# Tmux prefix highlight settings
set -g @prefix_highlight_show_copy_mode 'on'
```

After making all the changes listed above, your `~/.tmux.config` file should look something like this:

```bash
# Install Plugins
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'

# Tmux prefix highlight settings
set -g @prefix_highlight_show_copy_mode 'on'

# Turn on mouse input
set -g mouse on

# Change TMUX prefix key combo from Ctrl-b to Ctrl-a
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Add keybinding to change the focused pane with Alt + direction key
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Add keybinding to select windows with Alt+Shift+Right (next window) or Alt+Shift+Left (previous window).
bind -n S-M-Right select-window -n
bind -n S-M-Left select-window -p

# Add Keybinding to kill the current tmux session and exit tmux with Ctrl+Shift+x
bind -n C-S-x kill-session

# Add keybinding to clear the focused pane with Ctrl+Shift+k
bind -n C-S-k send-keys -R \; clear-history

# Minor futzing around with the layout
set -g status-position bottom
set -g status-justify left

# Set what appears in the lower left
set -g status-left '#{prefix_highlight}'
set -g status-left-length 15

# Set what appears in the lower right
set -g status-right '#[bold]%Y-%m-%d %H:%M#[default] '
set -g status-right-length 50

# Give windows reasonable titles
setw -g window-status-current-format ' #[bold]#I #W #F#[default] '

# Give panes reasonable titles
set -g pane-border-status top
set -g pane-border-format '#[bold]#{pane_title}#[default]'

# Run TMUX with the installed plugins
run '~/.tmux/plugins/tpm/tpm'
```

## <u>Resources and Links</u> <a name="resources"></a>

#### TMUX Cheat sheets

[tmuxcheatsheet.com](https://tmuxcheatsheet.com/?source=post_page)

[tmux-cheatsheet.markdown](https://gist.github.com/MohamedAlaa/2961058)

[TMUX Cheatsheet](https://linuxize.com/cheatsheet/tmux/)

#### Plugins

[TMUX Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm)

[List of TPM plugins](https://github.com/tmux-plugins/list)

#### Docs and Other

[TMUX Man Page](https://man7.org/linux/man-pages/man1/tmux.1.html)

[TMUX Wiki - Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)

[Awesome Tmux](https://github.com/rothgar/awesome-tmux?tab=readme-ov-file)

[A guide to customizing your TMUX config](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/)

## <u>Extra: Considerations when using docker compose develop 'watch' functionality</u> <a name="watch"></a>

If you're making use of ["Compose Watch"](https://docs.docker.com/compose/how-tos/file-watch/) functionality in your docker-compose.yml file, you'll need to change your `.tmuxinator.yml` configuration. This is because `docker compose up` cannot run detached while in 'watch' mode.

See [`docker-compose.watch.yml`](https://github.com/moofoo/docker-tmux-tutorial/docker-compose.watch.yml) and [`.tmuxinator.watch.yml`](https://github.com/moofoo/docker-tmux-tutorial/.tmuxinator.watch.yml) in the example [repo](https://github.com/moofoo/docker-tmux-tutorial).

You can try out the 'watch' docker compose/tmuxinator config by running

```bash
tmuxinator start -p .tmuxinator.watch.yml
```

```yaml
# ./.tmuxinator.watch.yml

name: tmuxinator_watch_tut
root: ./

# Don't run docker compose up on_project_start
# on_project_start: docker compose up --wait -d

on_project_exit: docker compose stop

windows:
  - logs:
      panes:
        # Need to sleep before running docker compose commands, so they run after `docker compose up --watch`
        - web:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml logs --since=1s -f watch_web
        - api:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml logs --since=1s -f watch_api
        - db:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml logs --since=15s -f watch_db
        - redis:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml logs --since=15s -f watch_redis
  - shell:
      panes:
        - web:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml exec -w /usr/src/app watch_web sh
        - api:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml exec -w /usr/src/app watch_api sh
        - psql:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml exec watch_db psql -U postgres -d tutorial_db
        - nestjs_repl:
            - sleep 1
            - clear && docker compose -f docker-compose.watch.yml exec -w /usr/src/app watch_api npm run repl

  - home:
      layout: main-vertical
      panes:
        - home: clear

    # Run docker compose up --watch in its own window
  - watch:
      layout: main-vertical
      panes:
        - watch: docker compose up --watch
```

To Summarize:

- Instead of running `docker compose up` in detached mode on_project_start, it's run in watch mode in its own window.
- Because of the above change, `docker compose logs/exec` commands need to be delayed so that they run after the `docker compose up --watch` command.
