# Stable Diffusion with Nix

Quickly get up and running using Stable Diffusion with Nix flakes.

## Setup

1. Enable flakes by editing either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add
```
experimental-features = nix-command flakes
```

2. Use `nix run --impure .#jupyterLab` to spawn a Jupyter Lab instance. The `--impure` flag allows nixGL to find your Nvidia drivers on non-nixos systems.

3. Replace `YOUR_TOKEN_HERE` with your HuggingFace token and make sure to accept the [License Agreement](https://huggingface.co/CompVis/stable-diffusion-v1-4) for Stable Diffusion.

4. Execute the cells in `stable-diff.ipynb` to generate images.

Enjoy!


![image](https://i.imgur.com/hgbzBEw.png)
