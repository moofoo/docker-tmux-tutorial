#!/bin/bash

tmux kill-server

# Start docker compose project in detached mode
docker compose up --wait -d

# Begin a new tmux session with the -d (detached) flag, which lets us configure windows/panels before actually
# opening the tmux session in the terminal
tmux new-session -d -s tmux_tut

#### Configure window for service logs ("C-m" outputs 'Enter')
tmux rename-window 'logs'

tmux select-pane -t 0 -T 'web'
tmux send-keys "clear && docker compose logs --since=1s -f web" C-m
tmux split-window -h

tmux select-pane -t 1 -T 'api'
tmux send-keys "clear && docker compose logs --since=1s -f api" C-m
tmux split-window -fv

tmux select-pane -t 2 -T 'db'
tmux send-keys "clear && docker compose logs --since=15s -f db" C-m
tmux split-window -h

tmux select-pane -t 3 -T 'redis'
tmux send-keys "clear && docker compose logs --since=15s -f redis" C-m

tmux select-pane -t 0
####

# Configure window for service shells/psql/repl
tmux new-window -n 'shells'

tmux select-pane -t 0 -T 'web'
tmux send-keys "clear && docker compose exec -w /usr/src/app web sh" C-m
tmux split-window -h

tmux select-pane -t 1 -T 'api'
tmux send-keys "clear && docker compose exec -w /usr/src/app api sh" C-m
tmux split-window -fv -l 70%

tmux select-pane -t 2 -T 'psql'
tmux send-keys "clear && docker compose exec db psql -U postgres -d tutorial_db" C-m
tmux split-window -h

tmux select-pane -t 3 -T 'nestjs-repl'
tmux send-keys "docker compose exec -w /usr/src/app api npm run repl" C-m

tmux select-pane -t 0
####

# Window showing (actual) command line in current directory
tmux new-window -n 'home'

# Tell tmux to open to the first window (logs)
tmux select-window -t logs

# Attach the terminal to the detached tmux session
tmux -2 attach-session -t tmux_tut

# When Tmux exits, call docker compose stop
docker compose stop
