# Open WebUI → ComfyUI configuration
# These are set via environment variables in docker-compose.yml
# No additional config needed — Open WebUI auto-detects ComfyUI
# when COMFYUI_BASE_URL is set.

ENABLE_IMAGE_GENERATION=true
IMAGE_GENERATION_ENGINE=comfyui
COMFYUI_BASE_URL=http://comfyui:8188
IMAGE_SIZE=1024x1024
IMAGE_STEPS=30
ENABLE_IMAGE_PROMPT_GENERATION=true
USER_PERMISSIONS_FEATURES_IMAGE_GENERATION=true
