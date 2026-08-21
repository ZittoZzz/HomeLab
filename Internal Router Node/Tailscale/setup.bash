#1.install tailscale
sudo apt install tailscale -y

#2. login to tailscale
sudo tailscale up

#3. go into tailscale admin console and set the node as an exit node if you want to route all traffic through it.

#4. check the status of tailscale
sudo tailscale status

